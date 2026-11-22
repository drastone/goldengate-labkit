#!/bin/bash
set -euo pipefail
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

test "$(cat /etc/hostname)" = "DESKTOP-NAFTHH1"

CONTAINER=demo_oggbd_mongo_trg
DEPLOYMENT=OGGBDTRG
SRC_URI='mongodb://oggadmin:WElcome1234%23%23@localhost:27017/admin?replicaSet=rs_src&authSource=admin'

run_admin() {
  docker exec -i -u ogg "$CONTAINER" \
    bash -lc 'cd /u01/ogg && ./bin/adminclient'
}

docker cp /tmp/id7_mrc01.prm \
  "$CONTAINER":/u02/Deployment/etc/conf/ogg/mrc01.prm
docker exec -u 0 "$CONTAINER" sh -lc '
  chown ogg:ogg /u02/Deployment/etc/conf/ogg/mrc01.prm
  chmod 600 /u02/Deployment/etc/conf/ogg/mrc01.prm
'

echo '==> Configure the remote MongoDB credential alias'
printf '%s\n' \
  "connect http://localhost:9011 deployment $DEPLOYMENT as oggadmin password WElcome1234## !" \
  'add credentialstore' \
  'exit' | run_admin >/tmp/id7_mrc01_add_store.out 2>&1 || true

printf '%s\n' \
  "connect http://localhost:9011 deployment $DEPLOYMENT as oggadmin password WElcome1234## !" \
  'alter credentialstore delete user "mongodb://oggadmin@demo_mongo_src:27017/admin?replicaSet=rs_src&authSource=admin" alias mongo_src_remote' \
  'exit' | run_admin >/tmp/id7_mrc01_delete_alias.out 2>&1 || true

printf '%s\n' \
  "connect http://localhost:9011 deployment $DEPLOYMENT as oggadmin password WElcome1234## !" \
  'alter credentialstore add user "mongodb://oggadmin@demo_mongo_src:27017/admin?replicaSet=rs_src&authSource=admin" password WElcome1234## alias mongo_src_remote' \
  'dblogin useridalias mongo_src_remote' \
  'list tables remote_capture.*' \
  'exit' | run_admin | tee /tmp/id7_mrc01_credential.out

grep -q 'Successfully logged into database' /tmp/id7_mrc01_credential.out
grep -q '"remote_capture"."events"' /tmp/id7_mrc01_credential.out

echo '==> Create/start MRC01 when needed'
printf '%s\n' \
  "connect http://localhost:9011 deployment $DEPLOYMENT as oggadmin password WElcome1234## !" \
  'info extract mrc01' \
  'exit' | run_admin > /tmp/id7_mrc01_info_before.out 2>&1 || true

if grep -Eq 'does not exist|No Extract groups exist' /tmp/id7_mrc01_info_before.out; then
  printf '%s\n' \
    "connect http://localhost:9011 deployment $DEPLOYMENT as oggadmin password WElcome1234## !" \
    'add extract mrc01, tranlog, begin now' \
    'add exttrail rc, extract mrc01' \
    'start extract mrc01' \
    'exit' | run_admin | tee /tmp/id7_mrc01_create.out
else
  printf '%s\n' \
    "connect http://localhost:9011 deployment $DEPLOYMENT as oggadmin password WElcome1234## !" \
    'start extract mrc01' \
    'exit' | run_admin > /tmp/id7_mrc01_start.out 2>&1 || true
fi

running=N
for attempt in $(seq 1 30); do
  printf '%s\n' \
    "connect http://localhost:9011 deployment $DEPLOYMENT as oggadmin password WElcome1234## !" \
    'info extract mrc01' \
    'exit' | run_admin > /tmp/id7_mrc01_status.out 2>&1 || true
  if grep -q 'Status RUNNING' /tmp/id7_mrc01_status.out; then
    running=Y
    break
  fi
  if grep -q 'Status ABENDED' /tmp/id7_mrc01_status.out; then
    cat /tmp/id7_mrc01_status.out
    docker exec "$CONTAINER" tail -n 120 /u02/Deployment/var/lib/report/MRC01.rpt
    exit 1
  fi
  sleep 2
done
test "$running" = Y

echo '==> Generate one source document after MRC01 start'
test_id="id7-remote-$(date +%Y%m%d%H%M%S)"
docker exec demo_mongo_src mongosh "$SRC_URI" --quiet --eval "
  const c = db.getSiblingDB('remote_capture').events;
  c.insertOne({test_id:'$test_id', memo:'captured remotely by id7 target-side OGGBD', created_at:new Date()});
  printjson(c.findOne({test_id:'$test_id'}));
"

sleep 8

echo '==> Verify MRC01 status and capture statistics'
printf '%s\n' \
  "connect http://localhost:9011 deployment $DEPLOYMENT as oggadmin password WElcome1234## !" \
  'info extract mrc01' \
  'stats extract mrc01 totalsonly remote_capture.*' \
  'exit' | run_admin | tee /tmp/id7_mrc01_verify.out

grep -q 'Status RUNNING' /tmp/id7_mrc01_verify.out
grep -Eq 'Total inserts[[:space:]]+1\.00|Total operations[[:space:]]+1\.00' /tmp/id7_mrc01_verify.out

echo '==> Verify report and internal-only exposure'
if docker exec "$CONTAINER" tail -n 160 /u02/Deployment/var/lib/report/MRC01.rpt \
  | grep -Eq '[[:space:]]ERROR[[:space:]]|Exception|ABENDED'; then
  echo 'ERROR: MRC01 report contains an error marker.' >&2
  exit 1
fi
test -z "$(docker port "$CONTAINER")"
test -z "$(docker port demo_mongo_src)"
test -z "$(docker port demo_mongo_trg)"

echo 'OK: id7 target-side MongoDB remote capture is running.'
echo 'OK: deployment=OGGBDTRG extract=MRC01 trail=rc source=demo_mongo_src:27017'
