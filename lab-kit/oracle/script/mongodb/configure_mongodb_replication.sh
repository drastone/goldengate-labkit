#!/usr/bin/env bash
set -Eeuo pipefail

OGG_CONTAINER=demo_oggbd_23ai
SOURCE_CONTAINER=demo_mongo_src
TARGET_CONTAINER=demo_mongo_trg
OGG_PASSWORD='WElcome1234##'
SOURCE_URI='mongodb://oggadmin:WElcome1234%23%23@localhost:27017/admin?directConnection=true&authSource=admin'
TARGET_URI='mongodb://oggapply:WElcome1234_@localhost:27017/admin?directConnection=true&authSource=admin'

require_running() {
  local name=$1
  if [ "$(docker inspect -f '{{.State.Running}}' "${name}" 2>/dev/null || true)" != true ]; then
    echo "ERROR: required container is not running: ${name}" >&2
    exit 1
  fi
}

run_admin() {
  docker exec -i -u ogg "${OGG_CONTAINER}" adminclient
}

for container in "${SOURCE_CONTAINER}" "${TARGET_CONTAINER}" "${OGG_CONTAINER}"; do
  require_running "${container}"
done

echo "Configure GoldenGate MongoDB credentials."
printf '%s\n' \
  "connect http://localhost as oggadmin password ${OGG_PASSWORD}" \
  'add credentialstore' \
  'alter credentialstore delete user mongo_src_lab13 domain OracleGoldenGate' \
  'alter credentialstore delete user mongo_trg_lab13 domain OracleGoldenGate' \
  'alter credentialstore add user "mongodb://oggadmin@demo_mongo_src:27017/admin?replicaSet=rs_src&authSource=admin" password WElcome1234## alias mongo_src_lab13 domain OracleGoldenGate' \
  'alter credentialstore add user "mongodb://oggapply@demo_mongo_trg:27017/admin?replicaSet=rs_trg&authSource=admin" password WElcome1234_ alias mongo_trg_lab13 domain OracleGoldenGate' \
  'dblogin useridalias mongo_src_lab13 domain OracleGoldenGate' \
  'list tables remote_capture.*' \
  'dblogin useridalias mongo_trg_lab13 domain OracleGoldenGate' \
  'exit' | run_admin > /tmp/lab13-mongodb-credentials.log

if [ "$(grep -c 'Successfully logged into database' /tmp/lab13-mongodb-credentials.log)" -lt 2 ]; then
  cat /tmp/lab13-mongodb-credentials.log
  echo "ERROR: GoldenGate MongoDB credential validation failed." >&2
  exit 1
fi

echo "Reset the Chapter 13 MongoDB capture/apply path."
printf '%s\n' \
  "connect http://localhost as oggadmin password ${OGG_PASSWORD}" \
  'stop replicat MRR01 !' \
  'delete replicat MRR01 !' \
  'stop extract MRC01 !' \
  'delete extract MRC01 !' \
  'exit' | run_admin >/tmp/lab13-mongodb-reset.log 2>&1 || true
docker exec -u 0 "${OGG_CONTAINER}" sh -lc \
  "find /u02/Deployment/var/lib/data -maxdepth 1 -type f -name 'rc*' -delete"

docker exec "${TARGET_CONTAINER}" mongosh "${TARGET_URI}" --quiet --eval \
  'db.getSiblingDB("remote_capture").events.deleteMany({})' >/dev/null
start_lsn="$(docker exec "${SOURCE_CONTAINER}" mongosh "${SOURCE_URI}" --quiet --eval \
  'const x=db.getSiblingDB("local").getCollection("oplog.rs").find().sort({$natural:-1}).limit(1).next(); print(x.ts.getHighBits()+"."+x.ts.getLowBits());')"

tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT
cat > "${tmpdir}/mrc01.prm" <<'EOF'
EXTRACT MRC01
JVMOPTIONS CLASSPATH ggjava/ggjava.jar:/u02/Deployment/etc/conf/ogg/mongodb/lib/*
SOURCEDB USERIDALIAS mongo_src_lab13
EXTTRAIL rc
NO_ABEND_ON_DDL
BINARY_JSON_FORMAT
TABLE remote_capture.events;
EOF
cat > "${tmpdir}/mrr01.prm" <<'EOF'
REPLICAT MRR01
TARGETDB LIBFILE libggjava.so SET property=/u02/Deployment/etc/conf/ogg/mrr01.props
REPORTCOUNT EVERY 1 MINUTES, RATE
GROUPTRANSOPS 1000
MAP remote_capture.events, TARGET remote_capture.events;
EOF
cat > "${tmpdir}/mrr01.props" <<EOF
gg.handlerlist=mongodb
gg.handler.mongodb.type=mongodb
gg.handler.mongodb.clientURI=mongodb://oggapply:WElcome1234_@demo_mongo_trg:27017/admin?replicaSet=rs_trg&authSource=admin
gg.handler.mongodb.bulkWrite=true
gg.handler.mongodb.enableTransactions=true
gg.handler.mongodb.CheckMaxRowSizeLimit=true
gg.handler.mongodb.oplogReplayLastLsn=${start_lsn}
gg.classpath=/u02/Deployment/etc/conf/ogg/mongodb/lib/*
jvm.bootoptions=-Xms32m -Xmx384m
EOF
for file in mrc01.prm mrr01.prm mrr01.props; do
  docker cp "${tmpdir}/${file}" "${OGG_CONTAINER}:/u02/Deployment/etc/conf/ogg/${file}"
done
docker exec -u 0 "${OGG_CONTAINER}" sh -lc \
  'chown ogg:ogg /u02/Deployment/etc/conf/ogg/mrc01.prm /u02/Deployment/etc/conf/ogg/mrr01.prm /u02/Deployment/etc/conf/ogg/mrr01.props && chmod 600 /u02/Deployment/etc/conf/ogg/mrc01.prm /u02/Deployment/etc/conf/ogg/mrr01.prm /u02/Deployment/etc/conf/ogg/mrr01.props'

echo "Start MRC01 and MRR01 at MongoDB LSN ${start_lsn}."
printf '%s\n' \
  "connect http://localhost as oggadmin password ${OGG_PASSWORD}" \
  'dblogin useridalias mongo_src_lab13 domain OracleGoldenGate' \
  "add extract MRC01, tranlog, lsn \"${start_lsn}\"" \
  'add exttrail rc, extract MRC01, megabytes 50' \
  'start extract MRC01' \
  'dblogin useridalias mongo_trg_lab13 domain OracleGoldenGate' \
  'add replicat MRR01, exttrail rc' \
  'start replicat MRR01' \
  'info all' \
  'exit' | run_admin | tee /tmp/lab13-mongodb-start.log

for attempt in $(seq 1 60); do
  printf '%s\n' "connect http://localhost as oggadmin password ${OGG_PASSWORD}" \
    'info all' 'exit' | run_admin > /tmp/lab13-mongodb-status.log
  if grep -Eq 'EXTRACT[[:space:]]+RUNNING[[:space:]]+MRC01' /tmp/lab13-mongodb-status.log \
     && grep -Eq 'REPLICAT[[:space:]]+RUNNING[[:space:]]+MRR01' /tmp/lab13-mongodb-status.log; then
    break
  fi
  if grep -Eq 'ABENDED.*(MRC01|MRR01)' /tmp/lab13-mongodb-status.log; then
    cat /tmp/lab13-mongodb-status.log
    echo "ERROR: MongoDB GoldenGate process abended." >&2
    exit 1
  fi
  sleep 2
done
grep -Eq 'EXTRACT[[:space:]]+RUNNING[[:space:]]+MRC01' /tmp/lab13-mongodb-status.log
grep -Eq 'REPLICAT[[:space:]]+RUNNING[[:space:]]+MRR01' /tmp/lab13-mongodb-status.log

test_id="lab13-$(date +%Y%m%d%H%M%S)"
docker exec "${SOURCE_CONTAINER}" mongosh "${SOURCE_URI}" --quiet --eval \
  "db.getSiblingDB('remote_capture').events.insertOne({test_id:'${test_id}', memo:'Lab 13 GoldenGate MongoDB verification', created_at:new Date()})" >/dev/null
for attempt in $(seq 1 60); do
  applied="$(docker exec "${TARGET_CONTAINER}" mongosh "${TARGET_URI}" --quiet --eval \
    "print(db.getSiblingDB('remote_capture').events.countDocuments({test_id:'${test_id}'}))")"
  [ "${applied}" = 1 ] && break
  sleep 2
done
if [ "${applied:-0}" != 1 ]; then
  echo "ERROR: MRR01 did not apply the verification document." >&2
  exit 1
fi

echo "OK: MRC01 and MRR01 are running."
echo "OK: MongoDB verification document reached demo_mongo_trg."
