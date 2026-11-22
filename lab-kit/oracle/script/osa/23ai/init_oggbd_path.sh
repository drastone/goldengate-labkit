#!/bin/bash
set -euo pipefail

OGG_HUB_CONTAINER="${OGG_HUB_CONTAINER:-demo_ogg_23ai}"
OGGBD_CONTAINER="${OGGBD_CONTAINER:-demo_oggbd_23ai}"
OGG_USER="${OGG_USER:-oggadmin}"
OGG_PASS="${OGG_PASS:-WElcome1234##}"

EXTRACT_NAME="${EXTRACT_NAME:-C01}"
ORACLE_REPLICAT_NAME="${ORACLE_REPLICAT_NAME:-D01}"
DISTPATH_NAME="${DISTPATH_NAME:-dpkaf01}"
REPLICAT_NAME="${REPLICAT_NAME:-KAF01}"
SOURCE_TRAIL="${SOURCE_TRAIL:-ca}"
TARGET_TRAIL="${TARGET_TRAIL:-da}"
TARGET_TRAIL_SIZE_MB="${TARGET_TRAIL_SIZE_MB:-100}"
TARGET_ALIAS="${TARGET_ALIAS:-BigData}"
PROCESS_WAIT_ATTEMPTS="${PROCESS_WAIT_ATTEMPTS:-12}"
PROCESS_WAIT_SECONDS="${PROCESS_WAIT_SECONDS:-5}"
RESET_SETTLE_SECONDS="${RESET_SETTLE_SECONDS:-5}"

OGGHUB_BACKUP_BASE="${OGGHUB_BACKUP_BASE:-/u02/Deployment/var/lib/backup}"
OGGBD_PROPS="${OGGBD_PROPS:-/u02/Deployment/etc/conf/ogg/kaf01.props}"
OGGBD_BACKUP_BASE="${OGGBD_BACKUP_BASE:-/u02/Deployment/var/lib/backup}"
RUN_ID="$(date +%Y%m%d_%H%M%S)"
OGGHUB_BACKUP_DIR="${OGGHUB_BACKUP_BASE}/osa_stream_reset_${RUN_ID}"
BACKUP_DIR="${OGGBD_BACKUP_BASE}/kaf01_reset_${RUN_ID}"

START_EPOCH="$(date +%s)"
START_TIME="$(date '+%Y-%m-%d %H:%M:%S')"

echo "Initializing OGGBD path for OSA sample stream..."
echo "Start time: ${START_TIME}"
echo "OGGHUB backup directory: ${OGG_HUB_CONTAINER}:${OGGHUB_BACKUP_DIR}"
echo "Backup directory: ${OGGBD_CONTAINER}:${BACKUP_DIR}"

run_ogg_admin() {
  local container="$1"
  local commands="$2"

  docker exec "${container}" bash -lc \
    "printf '%s\n' 'connect http://localhost as ${OGG_USER} password ${OGG_PASS}' ${commands} 'exit' | adminclient 2>/dev/null"
}

wait_not_running() {
  local container="$1"
  local process_type="$2"
  local process_name="$3"
  local attempt=1
  local status_text=""

  while [ "${attempt}" -le "${PROCESS_WAIT_ATTEMPTS}" ]; do
    status_text="$(run_ogg_admin "${container}" "'info ${process_type} ${process_name}'" 2>&1 || true)"
    if ! printf '%s\n' "${status_text}" | grep -Eiq 'Status RUNNING|RUNNING'; then
      echo "OK: ${process_type} ${process_name} is not running."
      return 0
    fi
    echo "... waiting for ${process_type} ${process_name} to stop (${attempt}/${PROCESS_WAIT_ATTEMPTS})."
    sleep "${PROCESS_WAIT_SECONDS}"
    attempt=$((attempt + 1))
  done

  echo "ERROR: ${process_type} ${process_name} is still running." >&2
  return 1
}

verify_group_absent() {
  local container="$1"
  local group_name="$2"
  local status_text=""

  if ! status_text="$(run_ogg_admin "${container}" "'info all'" 2>&1)"; then
    echo "ERROR: could not verify that ${group_name} was removed from ${container}." >&2
    return 1
  fi
  if printf '%s\n' "${status_text}" | grep -Eq "(EXTRACT|REPLICAT)[[:space:]]+[[:upper:]]+[[:space:]]+${group_name}([[:space:]]|$)"; then
    printf '%s\n' "${status_text}" >&2
    echo "ERROR: ${group_name} remains registered in ${container}; refusing to remove its trail." >&2
    return 1
  fi
  echo "OK: ${group_name} is no longer registered in ${container}."
}

verify_distpath_absent() {
  local status_text=""

  if ! status_text="$(run_ogg_admin "${OGG_HUB_CONTAINER}" "'info distpath all'" 2>&1)"; then
    echo "ERROR: could not verify that Distribution Path ${DISTPATH_NAME} was removed." >&2
    return 1
  fi
  if printf '%s\n' "${status_text}" | grep -Eq "(^|[[:space:]])${DISTPATH_NAME}([[:space:]]|$)"; then
    printf '%s\n' "${status_text}" >&2
    echo "ERROR: Distribution Path ${DISTPATH_NAME} remains registered; refusing to remove its trail." >&2
    return 1
  fi
  echo "OK: Distribution Path ${DISTPATH_NAME} is no longer registered."
}

echo "==> Stop Extract ${EXTRACT_NAME} and Replicat ${ORACLE_REPLICAT_NAME}"
run_ogg_admin "${OGG_HUB_CONTAINER}" "'stop ${EXTRACT_NAME}!' 'stop ${ORACLE_REPLICAT_NAME}!'" || true

echo "==> Stop Distribution Path ${DISTPATH_NAME}"
run_ogg_admin "${OGG_HUB_CONTAINER}" "'stop distpath ${DISTPATH_NAME}!'" || true

echo "==> Stop Replicat ${REPLICAT_NAME}"
run_ogg_admin "${OGGBD_CONTAINER}" "'stop ${REPLICAT_NAME}!'" || true

wait_not_running "${OGG_HUB_CONTAINER}" extract "${EXTRACT_NAME}"
wait_not_running "${OGG_HUB_CONTAINER}" replicat "${ORACLE_REPLICAT_NAME}"
wait_not_running "${OGG_HUB_CONTAINER}" distpath "${DISTPATH_NAME}"
wait_not_running "${OGGBD_CONTAINER}" replicat "${REPLICAT_NAME}"

echo "==> Backup OGGHUB source trail and checkpoints"
docker exec "${OGG_HUB_CONTAINER}" bash -lc "
  set -euo pipefail
  mkdir -p '${OGGHUB_BACKUP_DIR}'
  shopt -s nullglob
  cp -p /u02/Deployment/var/lib/data/${SOURCE_TRAIL}* '${OGGHUB_BACKUP_DIR}/' 2>/dev/null || true
  cp -p /u02/Deployment/var/lib/checkpt/${EXTRACT_NAME}.* '${OGGHUB_BACKUP_DIR}/' 2>/dev/null || true
  cp -p /u02/Deployment/var/lib/checkpt/${ORACLE_REPLICAT_NAME}.* '${OGGHUB_BACKUP_DIR}/' 2>/dev/null || true
  cp -p /u02/Deployment/var/lib/checkpt/${DISTPATH_NAME}.cpd '${OGGHUB_BACKUP_DIR}/' 2>/dev/null || true
  ls -ltr '${OGGHUB_BACKUP_DIR}'
"

echo "==> Backup OGGBD remote trail and Replicat metadata"
docker exec "${OGGBD_CONTAINER}" bash -lc "
  set -euo pipefail
  mkdir -p '${BACKUP_DIR}'
  shopt -s nullglob
  cp -p /u02/Deployment/var/lib/data/${TARGET_TRAIL}* '${BACKUP_DIR}/' 2>/dev/null || true
  cp -p /u02/Deployment/var/lib/checkpt/${REPLICAT_NAME}.* '${BACKUP_DIR}/' 2>/dev/null || true
  cp -p /u02/Deployment/etc/conf/ogg/kaf01.* '${BACKUP_DIR}/' 2>/dev/null || true
  curl -k -sS -u '${OGG_USER}:${OGG_PASS}' \
    http://localhost/services/OGGBD/adminsrvr/v2/replicats/${REPLICAT_NAME} \
    > '${BACKUP_DIR}/${REPLICAT_NAME}.rest.json' || true
  ls -ltr '${BACKUP_DIR}'
"

echo "==> Delete Replicat ${REPLICAT_NAME}"
run_ogg_admin "${OGGBD_CONTAINER}" "'delete replicat ${REPLICAT_NAME}!'" || true

echo "==> Delete Distribution Path ${DISTPATH_NAME}"
docker exec "${OGG_HUB_CONTAINER}" bash -lc "
  curl -k -sS -u '${OGG_USER}:${OGG_PASS}' \
    -X DELETE \
    http://localhost/services/OGGHUB/distsrvr/v2/sources/${DISTPATH_NAME} \
  | python3 -m json.tool || true
"

echo "==> Delete Extract ${EXTRACT_NAME}"
docker exec "${OGG_HUB_CONTAINER}" bash -lc "
  curl -k -sS -u '${OGG_USER}:${OGG_PASS}' \
    -X DELETE \
    http://localhost/services/OGGHUB/adminsrvr/v2/extracts/${EXTRACT_NAME} \
  | python3 -m json.tool || true
"

verify_group_absent "${OGGBD_CONTAINER}" "${REPLICAT_NAME}"
verify_distpath_absent
verify_group_absent "${OGG_HUB_CONTAINER}" "${EXTRACT_NAME}"

echo "==> Clear OGGHUB source trail ${SOURCE_TRAIL}*"
echo "Sleeping ${RESET_SETTLE_SECONDS} seconds before removing trail files..."
sleep "${RESET_SETTLE_SECONDS}"
docker exec "${OGG_HUB_CONTAINER}" bash -lc "
  rm -f /u02/Deployment/var/lib/data/${SOURCE_TRAIL}*
"

echo "==> Clear OGGBD remote trail ${TARGET_TRAIL}*"
docker exec "${OGGBD_CONTAINER}" bash -lc "
  rm -f /u02/Deployment/var/lib/data/${TARGET_TRAIL}*
"

echo "==> Recreate Extract ${EXTRACT_NAME}"
docker exec "${OGG_HUB_CONTAINER}" bash -lc "
  set -euo pipefail
  cat > /tmp/create_${EXTRACT_NAME}.json <<'JSON'
{
  \"\$schema\": \"ogg:extract\",
  \"description\": \"capture for OSA sample stream\",
  \"credentials\": {
    \"alias\": \"src_ogg\",
    \"domain\": \"OracleGoldenGate\"
  },
  \"begin\": \"now\",
  \"source\": \"tranlogs\",
  \"targets\": [
    {
      \"name\": \"${SOURCE_TRAIL}\",
      \"sizeMB\": 100
    }
  ],
  \"managedProcessSettings\": \"ogg:managedProcessSettings:Default\",
  \"config\": [
    \"EXTRACT ${EXTRACT_NAME}\",
    \"USERIDALIAS src_ogg DOMAIN OracleGoldenGate\",
    \"TRANLOGOPTIONS INTEGRATEDPARAMS (MAX_SGA_SIZE 100)\",
    \"TRANLOGOPTIONS _VALIDATEPKUPDATE\",
    \"eofdelaycsecs 10\",
    \"cachemgr cachesize 128M\",
    \"LOGALLSUPCOLS\",
    \"UPDATERECORDFORMAT COMPACT\",
    \"DDL INCLUDE ALL\",
    \"EXTTRAIL ${SOURCE_TRAIL}\",
    \"TABLE SOE.*;\"
  ]
}
JSON
  curl -k -sS -u '${OGG_USER}:${OGG_PASS}' \
    -H 'Content-Type: application/json' \
    -X POST \
    -d @/tmp/create_${EXTRACT_NAME}.json \
    http://localhost/services/OGGHUB/adminsrvr/v2/extracts/${EXTRACT_NAME} \
  | python3 -m json.tool
  curl -k -sS -u '${OGG_USER}:${OGG_PASS}' \
    -H 'Content-Type: application/json' \
    -X PATCH \
    -d '{\"registration\":{\"share\":true}}' \
    http://localhost/services/OGGHUB/adminsrvr/v2/extracts/${EXTRACT_NAME} \
  | python3 -m json.tool
"

echo "==> Start Extract ${EXTRACT_NAME} / Replicat ${ORACLE_REPLICAT_NAME}"
run_ogg_admin "${OGG_HUB_CONTAINER}" \
  "'alter replicat ${ORACLE_REPLICAT_NAME} extseqno 0 extrba 0' 'start ${EXTRACT_NAME}' 'start ${ORACLE_REPLICAT_NAME}' 'info all'"

echo "==> Recreate Distribution Path ${DISTPATH_NAME}"
docker exec "${OGG_HUB_CONTAINER}" bash -lc "
  set -euo pipefail
  cat > /tmp/create_${DISTPATH_NAME}.json <<'JSON'
{
  \"\$schema\": \"ogg:distPath\",
  \"source\": {
    \"uri\": \"trail://localhost:9013/services/v2/source?trail=${SOURCE_TRAIL}\"
  },
  \"target\": {
    \"uri\": \"ogg://${OGGBD_CONTAINER}:9014/services/v2/targets?trail=${TARGET_TRAIL}\",
    \"authenticationMethod\": {
      \"alias\": \"oggbd_admin\",
      \"domain\": \"OracleGoldenGate\"
    },
    \"isDynamicOggPort\": false,
    \"details\": {
      \"trail\": {
        \"sizeMB\": ${TARGET_TRAIL_SIZE_MB}
      }
    }
  },
  \"name\": \"${DISTPATH_NAME}\",
  \"begin\": {
    \"sequence\": 0,
    \"offset\": 0
  },
  \"encryptionProfile\": \"LocalWallet\"
}
JSON
  curl -k -sS -u '${OGG_USER}:${OGG_PASS}' \
    -H 'Content-Type: application/json' \
    -X POST \
    -d @/tmp/create_${DISTPATH_NAME}.json \
    http://localhost/services/OGGHUB/distsrvr/v2/sources/${DISTPATH_NAME} \
  | python3 -m json.tool
"

echo "==> Start Distribution Path ${DISTPATH_NAME}"
run_ogg_admin "${OGG_HUB_CONTAINER}" \
  "'start distpath ${DISTPATH_NAME}' 'stats distpath ${DISTPATH_NAME}'"

docker exec "${OGGBD_CONTAINER}" bash -lc "
  echo 'Current OGGBD remote trail files:'
  find /u02/Deployment/var/lib/data -maxdepth 1 -type f -name '${TARGET_TRAIL}*' \
    -printf '%TY-%Tm-%Td %TH:%TM:%TS %s %f\n' | sort
"

echo "==> Recreate Replicat ${REPLICAT_NAME}"
docker exec "${OGGBD_CONTAINER}" bash -lc "
  set -euo pipefail
  cat > /tmp/create_${REPLICAT_NAME}.json <<'JSON'
{
  \"\$schema\": \"ogg:replicat\",
  \"credentials\": {
    \"alias\": \"${TARGET_ALIAS}\"
  },
  \"begin\": {
    \"sequence\": 0,
    \"offset\": 0
  },
  \"source\": {
    \"name\": \"${TARGET_TRAIL}\"
  },
  \"mode\": {
    \"type\": \"nonintegrated\",
    \"parallel\": false
  },
  \"config\": [
    \"REPLICAT ${REPLICAT_NAME}\",
    \"TARGETDB LIBFILE libggjava.so SET property=${OGGBD_PROPS}\",
    \"REPORTCOUNT EVERY 1 MINUTES, RATE\",
    \"MAP SOE.*, TARGET SOE.*;\"
  ]
}
JSON
  curl -k -sS -u '${OGG_USER}:${OGG_PASS}' \
    -H 'Content-Type: application/json' \
    -X POST \
    -d @/tmp/create_${REPLICAT_NAME}.json \
    http://localhost/services/OGGBD/adminsrvr/v2/replicats/${REPLICAT_NAME} \
  | python3 -m json.tool
"

echo "==> Start Replicat ${REPLICAT_NAME}"
run_ogg_admin "${OGGBD_CONTAINER}" \
  "'start ${REPLICAT_NAME}' 'info all'"

echo "==> Verify Replicat ${REPLICAT_NAME}"
sleep 10
run_ogg_admin "${OGGBD_CONTAINER}" \
  "'info all' 'stats replicat ${REPLICAT_NAME} total'"

END_EPOCH="$(date +%s)"
END_TIME="$(date '+%Y-%m-%d %H:%M:%S')"
ELAPSED="$((END_EPOCH - START_EPOCH))"

echo "End time: ${END_TIME}"
echo "Elapsed time: ${ELAPSED} seconds"
echo "OGGBD path initialized."
