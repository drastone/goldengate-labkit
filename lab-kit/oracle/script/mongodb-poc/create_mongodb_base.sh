#!/bin/bash
set -euo pipefail
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

test "$(cat /etc/hostname)" = "DESKTOP-NAFTHH1"

NETWORK=oracle_ogg_network
IMAGE=mongo:7.0.40
BASE=/home/oracle/oracle/script/mongodb-poc
KEYFILE="$BASE/mongo-keyfile"

mkdir -p "$BASE"
if test ! -s "$KEYFILE"; then
  umask 077
  openssl rand -base64 756 | tr -d '\n' > "$KEYFILE"
fi
chown 999:999 "$KEYFILE"
chmod 400 "$KEYFILE"

create_mongo() {
  name=$1
  replset=$2
  volume=$3
  user=$4
  password=$5

  if docker container inspect "$name" >/dev/null 2>&1; then
    actual_image=$(docker inspect -f '{{.Config.Image}}' "$name")
    if test "$actual_image" != "$IMAGE"; then
      echo "ERROR: $name already exists with image $actual_image; refusing to replace it." >&2
      exit 1
    fi
    echo "INFO: reuse existing $name"
    docker start "$name" >/dev/null
    return
  fi

  docker volume create "$volume" >/dev/null
  docker run -d \
    --name "$name" \
    --hostname "$name" \
    --network "$NETWORK" \
    --memory 1g \
    --label goldengate.lab.role=mongodb-poc \
    -e MONGO_INITDB_ROOT_USERNAME="$user" \
    -e MONGO_INITDB_ROOT_PASSWORD="$password" \
    -v "$volume":/data/db \
    -v "$KEYFILE":/etc/mongo-keyfile/keyfile:ro \
    "$IMAGE" \
    --replSet "$replset" \
    --bind_ip_all \
    --keyFile /etc/mongo-keyfile/keyfile \
    --auth >/dev/null
}

wait_mongo() {
  name=$1
  uri=$2
  ready=N
  for attempt in $(seq 1 60); do
    if docker exec "$name" mongosh "$uri" --quiet \
      --eval 'quit(db.adminCommand({ping:1}).ok ? 0 : 1)' >/dev/null 2>&1; then
      ready=Y
      break
    fi
    if test "$(docker inspect -f '{{.State.Running}}' "$name" 2>/dev/null || true)" != true; then
      docker logs --tail 100 "$name"
      echo "ERROR: $name stopped during initialization." >&2
      exit 1
    fi
    sleep 2
  done
  if test "$ready" != Y; then
    docker logs --tail 100 "$name"
    echo "ERROR: $name did not become ready." >&2
    exit 1
  fi
}

init_replset() {
  name=$1
  replset=$2
  uri=$3
  docker exec "$name" mongosh "$uri" --quiet --eval "
    try {
      const s = rs.status();
      printjson({replicaSet:s.set, state:rs.isMaster().ismaster ? 'PRIMARY' : 'NOT_PRIMARY'});
    } catch (e) {
      printjson(rs.initiate({_id:'$replset', members:[{_id:0, host:'$name:27017'}]}));
    }
  "

  primary=N
  for attempt in $(seq 1 45); do
    if docker exec "$name" mongosh "$uri" --quiet \
      --eval 'quit(db.hello().isWritablePrimary ? 0 : 1)' >/dev/null 2>&1; then
      primary=Y
      break
    fi
    sleep 2
  done
  test "$primary" = Y
}

SRC_URI='mongodb://oggadmin:WElcome1234%23%23@localhost:27017/admin?directConnection=true&authSource=admin'
TRG_URI='mongodb://oggapply:WElcome1234_@localhost:27017/admin?directConnection=true&authSource=admin'

echo '==> Create/start MongoDB source and target'
create_mongo demo_mongo_src rs_src mongo_src_data oggadmin 'WElcome1234##'
create_mongo demo_mongo_trg rs_trg mongo_trg_data oggapply 'WElcome1234_'

echo '==> Wait for authenticated MongoDB endpoints'
wait_mongo demo_mongo_src "$SRC_URI"
wait_mongo demo_mongo_trg "$TRG_URI"

echo '==> Initialize single-node replica sets'
init_replset demo_mongo_src rs_src "$SRC_URI"
init_replset demo_mongo_trg rs_trg "$TRG_URI"

echo '==> Prepare dedicated remote-capture collection'
docker exec demo_mongo_src mongosh "$SRC_URI" --quiet --eval '
  const d = db.getSiblingDB("remote_capture");
  if (!d.getCollectionNames().includes("events")) d.createCollection("events");
  d.events.createIndex({test_id:1}, {unique:true});
  printjson({database:d.getName(), collections:d.getCollectionNames()});
'

echo '==> Verify internal-only exposure'
test -z "$(docker port demo_mongo_src)"
test -z "$(docker port demo_mongo_trg)"
docker ps --filter name=demo_mongo --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'
echo 'OK: id7 MongoDB source/target replica sets are ready.'
