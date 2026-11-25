#!/usr/bin/env bash
set -Eeuo pipefail

NETWORK=oracle_ogg_network
IMAGE='mongo:7.0.40@sha256:b6421fd6d1c5ded6377b397d8983e2f82e2100dc5123332dcfda2065a472be5b'
RUNTIME_DIR=/home/oracle/mongodb/runtime
KEYFILE="${RUNTIME_DIR}/mongo-keyfile"

mkdir -p "${RUNTIME_DIR}"
if [ ! -s "${KEYFILE}" ]; then
  umask 077
  openssl rand -base64 756 | tr -d '\n' > "${KEYFILE}"
fi
chown 999:999 "${KEYFILE}"
chmod 400 "${KEYFILE}"

create_mongo() {
  local name=$1 replset=$2 volume=$3 user=$4 password=$5
  if docker container inspect "${name}" >/dev/null 2>&1; then
    echo "INFO: reuse existing ${name}"
    docker start "${name}" >/dev/null
    return
  fi
  docker volume create "${volume}" >/dev/null
  docker run -d \
    --name "${name}" \
    --hostname "${name}" \
    --network "${NETWORK}" \
    --memory 1g \
    --label goldengate.lab.role=mongodb-migration \
    -e MONGO_INITDB_ROOT_USERNAME="${user}" \
    -e MONGO_INITDB_ROOT_PASSWORD="${password}" \
    -v "${volume}:/data/db" \
    -v "${KEYFILE}:/etc/mongo-keyfile/keyfile:ro" \
    "${IMAGE}" \
    --replSet "${replset}" --bind_ip_all \
    --keyFile /etc/mongo-keyfile/keyfile --auth >/dev/null
}

wait_mongod() {
  local name=$1
  for attempt in $(seq 1 60); do
    if docker exec "${name}" mongosh --quiet --host localhost \
      --eval 'quit(0)' >/dev/null 2>&1; then
      return
    fi
    sleep 2
  done
  docker logs --tail 100 "${name}" || true
  echo "ERROR: ${name} did not start MongoDB." >&2
  exit 1
}

reconcile_admin_user() {
  local name=$1 uri=$2 user=$3 password=$4

  if docker exec "${name}" mongosh "${uri}" --quiet \
    --eval 'quit(db.adminCommand({ping:1}).ok ? 0 : 1)' >/dev/null 2>&1; then
    echo "OK: ${name} canonical administrator is ready."
    return
  fi

  echo "INFO: reconcile ${name} canonical administrator from replica-set keyfile."
  if ! docker exec \
    -e CANONICAL_USER="${user}" \
    -e CANONICAL_PASSWORD="${password}" \
    "${name}" sh -lc '
      keyfile=
      for candidate in \
        /etc/mongo-keyfile/keyfile \
        /run/mongodb-key/mongodb-keyfile; do
        if [ -s "${candidate}" ]; then
          keyfile="${candidate}"
          break
        fi
      done
      [ -n "${keyfile}" ] || exit 2
      internal_password="$(tr -d "\r\n" < "${keyfile}")"
      mongosh --quiet --host localhost \
        --username __system \
        --password "${internal_password}" \
        --authenticationDatabase local \
        --authenticationMechanism SCRAM-SHA-256 \
        --eval '\''
          const admin = db.getSiblingDB("admin");
          const user = process.env.CANONICAL_USER;
          const pwd = process.env.CANONICAL_PASSWORD;
          const roles = [{role: "root", db: "admin"}];
          if (admin.getUser(user)) {
            admin.updateUser(user, {pwd, roles});
          } else {
            admin.createUser({user, pwd, roles});
          }
        '\'' >/dev/null
    '; then
    echo "ERROR: could not reconcile ${name} administrator." >&2
    echo "ERROR: preserve the container and review its replica-set keyfile mount." >&2
    exit 1
  fi

  if ! docker exec "${name}" mongosh "${uri}" --quiet \
    --eval 'quit(db.adminCommand({ping:1}).ok ? 0 : 1)' >/dev/null 2>&1; then
    echo "ERROR: ${name} canonical administrator validation failed after reconciliation." >&2
    exit 1
  fi
  echo "OK: ${name} canonical administrator was reconciled."
}

wait_mongo() {
  local name=$1 uri=$2
  for attempt in $(seq 1 60); do
    if docker exec "${name}" mongosh "${uri}" --quiet \
      --eval 'quit(db.adminCommand({ping:1}).ok ? 0 : 1)' >/dev/null 2>&1; then
      return
    fi
    sleep 2
  done
  docker logs --tail 100 "${name}" || true
  echo "ERROR: ${name} did not become ready." >&2
  exit 1
}

init_replset() {
  local name=$1 replset=$2 uri=$3
  docker exec "${name}" mongosh "${uri}" --quiet --eval "
    try { rs.status(); }
    catch (e) { rs.initiate({_id:'${replset}', members:[{_id:0, host:'${name}:27017'}]}); }
  " >/dev/null
  for attempt in $(seq 1 45); do
    if docker exec "${name}" mongosh "${uri}" --quiet \
      --eval 'quit(db.hello().isWritablePrimary ? 0 : 1)' >/dev/null 2>&1; then
      return
    fi
    sleep 2
  done
  echo "ERROR: ${name} did not become PRIMARY." >&2
  exit 1
}

SRC_URI='mongodb://oggadmin:WElcome1234%23%23@localhost:27017/admin?directConnection=true&authSource=admin'
TRG_URI='mongodb://oggapply:WElcome1234_@localhost:27017/admin?directConnection=true&authSource=admin'

echo "Create/start MongoDB source and target."
create_mongo demo_mongo_src rs_src mongo_src_data oggadmin 'WElcome1234##'
create_mongo demo_mongo_trg rs_trg mongo_trg_data oggapply 'WElcome1234_'
wait_mongod demo_mongo_src
wait_mongod demo_mongo_trg
reconcile_admin_user demo_mongo_src "${SRC_URI}" oggadmin 'WElcome1234##'
reconcile_admin_user demo_mongo_trg "${TRG_URI}" oggapply 'WElcome1234_'
wait_mongo demo_mongo_src "${SRC_URI}"
wait_mongo demo_mongo_trg "${TRG_URI}"
init_replset demo_mongo_src rs_src "${SRC_URI}"
init_replset demo_mongo_trg rs_trg "${TRG_URI}"

docker exec demo_mongo_src mongosh "${SRC_URI}" --quiet --eval '
  const d=db.getSiblingDB("remote_capture");
  if (!d.getCollectionNames().includes("events")) d.createCollection("events");
  d.events.createIndex({test_id:1}, {unique:true});
' >/dev/null

test -z "$(docker port demo_mongo_src)"
test -z "$(docker port demo_mongo_trg)"
echo "OK: MongoDB source and target replica sets are ready."
