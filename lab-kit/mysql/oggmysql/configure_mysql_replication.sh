#!/usr/bin/env bash
set -Eeuo pipefail

OGG_CONTAINER=demo_oggmysql_23ai
SOURCE_CONTAINER=demo_mysql
TARGET_CONTAINER=demo_myheat
OGG_PASSWORD='WElcome1234##'
ROOT_PASSWORD='WElcome1234##'
PARAM_DIR=/home/oracle/mysql/oggmysql/data/Deployment/etc/conf/ogg
TRAIL_DIR=/home/oracle/mysql/oggmysql/data/Deployment/var/lib/data

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

echo "Configure MySQL row metadata required by GoldenGate capture."
docker exec "${SOURCE_CONTAINER}" mysql -uroot -p"${ROOT_PASSWORD}" \
  -e "set global binlog_row_metadata='FULL';"
row_metadata="$(docker exec "${SOURCE_CONTAINER}" mysql -N -B -uroot -p"${ROOT_PASSWORD}" \
  -e 'select @@global.binlog_row_metadata;')"
if [ "${row_metadata}" != FULL ]; then
  echo "ERROR: binlog_row_metadata is ${row_metadata}; expected FULL." >&2
  exit 1
fi

echo "Configure GoldenGate for MySQL credentials."
printf '%s\n' \
  "connect http://localhost as oggadmin password ${OGG_PASSWORD}" \
  'add credentialstore' \
  'alter credentialstore delete user src_mysql domain OracleGoldenGate' \
  'alter credentialstore delete user trg_mysql domain OracleGoldenGate' \
  'alter credentialstore add user mig_reader@demo_mysql:3306/game password WElcome1234## alias src_mysql domain OracleGoldenGate' \
  'alter credentialstore add user mig_loader@demo_myheat:3306/game_hw password WElcome1234## alias trg_mysql domain OracleGoldenGate' \
  'dblogin useridalias src_mysql domain OracleGoldenGate' \
  'list tables game.*' \
  'dblogin useridalias trg_mysql domain OracleGoldenGate' \
  'list tables game_hw.*' \
  'exit' | run_admin > /tmp/lab13-mysql-credentials.log

if [ "$(grep -c 'Successfully logged into database' /tmp/lab13-mysql-credentials.log)" -ne 2 ]; then
  cat /tmp/lab13-mysql-credentials.log
  echo "ERROR: GoldenGate for MySQL credential validation failed." >&2
  exit 1
fi

echo "Reset the Chapter 13 MySQL capture/apply path."
printf '%s\n' \
  "connect http://localhost as oggadmin password ${OGG_PASSWORD}" \
  'stop replicat MR01 !' \
  'delete replicat MR01 !' \
  'stop extract MX01 !' \
  'delete extract MX01 !' \
  'exit' | run_admin >/tmp/lab13-mysql-reset.log 2>&1 || true
find "${TRAIL_DIR}" -maxdepth 1 -type f -name 'mx*' -delete 2>/dev/null || true

echo "Create a consistent target snapshot."
snapshot_gtid="$(docker exec "${SOURCE_CONTAINER}" mysql -N -B -uroot -p"${ROOT_PASSWORD}" -e 'select @@global.gtid_executed')"
docker exec "${TARGET_CONTAINER}" mysql -uroot -p"${ROOT_PASSWORD}" game_hw \
  -e 'set foreign_key_checks=0; drop table if exists purchase_order; drop table if exists player_account; set foreign_key_checks=1;'
docker exec "${SOURCE_CONTAINER}" mysqldump -uroot -p"${ROOT_PASSWORD}" \
  --single-transaction --set-gtid-purged=OFF --no-tablespaces game player_account purchase_order \
  | docker exec -i "${TARGET_CONTAINER}" mysql -uroot -p"${ROOT_PASSWORD}" game_hw

mkdir -p "${PARAM_DIR}" "${TRAIL_DIR}"
cat > "${PARAM_DIR}/mx01.prm" <<'EOF'
EXTRACT MX01
USERIDALIAS src_mysql DOMAIN OracleGoldenGate
SETENV (TZ="UTC")
EXTTRAIL mx
TABLE game.player_account;
TABLE game.purchase_order;
EOF
cat > "${PARAM_DIR}/mr01.prm" <<'EOF'
REPLICAT MR01
USERIDALIAS trg_mysql DOMAIN OracleGoldenGate
MAP game.player_account, TARGET game_hw.player_account;
MAP game.purchase_order, TARGET game_hw.purchase_order;
EOF
docker exec -u 0 "${OGG_CONTAINER}" sh -lc \
  'chown ogg:ogg /u02/Deployment/etc/conf/ogg/mx01.prm /u02/Deployment/etc/conf/ogg/mr01.prm && chmod 640 /u02/Deployment/etc/conf/ogg/mx01.prm /u02/Deployment/etc/conf/ogg/mr01.prm'

echo "Start MX01 and MR01."
printf '%s\n' \
  "connect http://localhost as oggadmin password ${OGG_PASSWORD}" \
  'dblogin useridalias trg_mysql domain OracleGoldenGate' \
  'add checkpointtable game_hw.gg_checkpoint' \
  'exit' | run_admin >/tmp/lab13-mysql-checkpoint.log 2>&1 || true

printf '%s\n' \
  "connect http://localhost as oggadmin password ${OGG_PASSWORD}" \
  'dblogin useridalias src_mysql domain OracleGoldenGate' \
  "add extract MX01, tranlog, GTIDSET \"${snapshot_gtid}\"" \
  'add exttrail mx, extract MX01, megabytes 50' \
  'start extract MX01' \
  'dblogin useridalias trg_mysql domain OracleGoldenGate' \
  'add replicat MR01, exttrail mx, checkpointtable game_hw.gg_checkpoint' \
  'start replicat MR01' \
  'info all' \
  'exit' | run_admin | tee /tmp/lab13-mysql-start.log

for attempt in $(seq 1 45); do
  printf '%s\n' \
    "connect http://localhost as oggadmin password ${OGG_PASSWORD}" \
    'info all' 'exit' | run_admin > /tmp/lab13-mysql-status.log
  if grep -Eq 'EXTRACT[[:space:]]+RUNNING[[:space:]]+MX01' /tmp/lab13-mysql-status.log \
     && grep -Eq 'REPLICAT[[:space:]]+RUNNING[[:space:]]+MR01' /tmp/lab13-mysql-status.log; then
    break
  fi
  if grep -Eq '(MX01|MR01).*ABENDED|ABENDED.*(MX01|MR01)' /tmp/lab13-mysql-status.log; then
    cat /tmp/lab13-mysql-status.log
    echo "ERROR: MySQL GoldenGate process abended." >&2
    exit 1
  fi
  sleep 2
done

grep -Eq 'EXTRACT[[:space:]]+RUNNING[[:space:]]+MX01' /tmp/lab13-mysql-status.log
grep -Eq 'REPLICAT[[:space:]]+RUNNING[[:space:]]+MR01' /tmp/lab13-mysql-status.log

marker="lab13-$(date +%Y%m%d%H%M%S)"
docker exec "${SOURCE_CONTAINER}" mysql -uroot -p"${ROOT_PASSWORD}" game \
  -e "update player_account set email='${marker}@example.com' where player_code='P000001';"
for attempt in $(seq 1 45); do
  applied="$(docker exec "${TARGET_CONTAINER}" mysql -N -B -uroot -p"${ROOT_PASSWORD}" game_hw \
    -e "select count(*) from player_account where player_code='P000001' and email='${marker}@example.com';")"
  [ "${applied}" = 1 ] && break
  sleep 2
done
if [ "${applied:-0}" != 1 ]; then
  echo "ERROR: MR01 did not apply the verification update." >&2
  exit 1
fi

echo "OK: MX01 and MR01 are running."
echo "OK: MySQL verification update reached demo_myheat."
