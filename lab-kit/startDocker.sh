#!/usr/bin/env bash
set -u

# GoldenGate Lab Kit startup/self-healing entry point.
#
# This script is intentionally more than a plain "docker start" wrapper.
# Readers often stop the lab by closing a browser, closing the WSL terminal, or
# rebooting a laptop. The next startup is therefore the best time to repair
# small, repeatable lab issues before the user opens APEX or the OGG Console.
#
# The script only performs startup maintenance that is safe to repeat:
# container start, log/archive cleanup, ORDS static-path checks, demo APEX
# account refresh, OGG Big Data receiver recovery, Kafka/Zookeeper startup,
# optional Lakehouse startup, ORDS restart, and HTTP health checks.
# Destructive actions such as demo data reseed, OGG checkpoint reset, or volume
# recreation must live in separate reset scripts with explicit confirmation.

# Container names can be overridden from the environment when a reader uses
# different names in a WSL/Linux Docker Engine environment.
LAB_HOME="${LAB_HOME:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
SOURCE_DB_CONTAINER="${SOURCE_DB_CONTAINER:-demo_osrc_23ai}"
TARGET_DB_CONTAINER="${TARGET_DB_CONTAINER:-demo_otrg_23ai}"
SOURCE_DB_SERVICE="${SOURCE_DB_SERVICE:-oracle_src_23ai}"
TARGET_DB_SERVICE="${TARGET_DB_SERVICE:-oracle_trg_23ai}"
ORACLE_DB_PORT="${ORACLE_DB_PORT:-1521}"
ORACLE_HOME="${ORACLE_HOME:-/opt/oracle/product/26ai/dbhome_1}"
ORACLE_SID="${ORACLE_SID:-ORCLCDB}"
OGG_CONTAINER="${OGG_CONTAINER:-demo_ogg_23ai}"
OGGBD_CONTAINER="${OGGBD_CONTAINER:-demo_oggbd_23ai}"
BIGDATA_CONTAINER="${BIGDATA_CONTAINER:-demo_centos}"

# The base Lakehouse stack is optional and is kept off by default while the
# core Oracle/GoldenGate and Stream Analytics labs are being verified. Enable
# it only in the Iceberg/Lakehouse chapter so MinIO, Iceberg REST Catalog,
# Trino, and related consumers do not consume memory during earlier labs.
LAKEHOUSE_AUTOSTART="${LAKEHOUSE_AUTOSTART:-N}"
LAKEHOUSE_QUERY_API_AUTOSTART="${LAKEHOUSE_QUERY_API_AUTOSTART:-N}"
LAKEHOUSE_WRITER_AUTOSTART="${LAKEHOUSE_WRITER_AUTOSTART:-N}"
MINIO_CONTAINER="${MINIO_CONTAINER:-demo_minio}"
ICEBERG_CATALOG_CONTAINER="${ICEBERG_CATALOG_CONTAINER:-demo_iceberg_catalog}"
TRINO_CONTAINER="${TRINO_CONTAINER:-demo_trino}"
LAKEHOUSE_REPO_DIR="${LAKEHOUSE_REPO_DIR:-${LAB_HOME}/oracle}"
LAKEHOUSE_QUERY_API_DIR="${LAKEHOUSE_QUERY_API_DIR:-${LAKEHOUSE_REPO_DIR}/script/lakehouse/query-api}"
LAKEHOUSE_WRITER_DIR="${LAKEHOUSE_WRITER_DIR:-${LAKEHOUSE_REPO_DIR}/script/lakehouse/kafka-iceberg-writer}"

# OCI AI/APEX demo workers are intentionally kept out of the default
# GoldenGate/OSA startup path. They poll periodically and can consume CPU while
# readers are working through unrelated CDC, Kafka, or Stream Analytics labs.
# Enable and start them only in the OCI AI chapter.
AI_WORKERS_AUTOSTART="${AI_WORKERS_AUTOSTART:-N}"
AI_WORKER_UNITS="${AI_WORKER_UNITS:-claims-aidp-worker.timer new-business-aidp-worker.timer call-center-oci-speech-worker.timer}"

# ORDS ports and helper locations are kept as variables so the same script can
# be reused on a different notebook, VM, or cloud demo server.
SOURCE_ORDS_ENABLED="${SOURCE_ORDS_ENABLED:-Y}"
TARGET_ORDS_ENABLED="${TARGET_ORDS_ENABLED:-Y}"
SOURCE_ORDS_PORT="${SOURCE_ORDS_PORT:-35080}"
TARGET_ORDS_PORT="${TARGET_ORDS_PORT:-36080}"
ORDS_START_HELPER_SOURCE="${ORDS_START_HELPER_SOURCE:-${LAB_HOME}/oracle/pkg/start_ords.sh}"
ORDS_READY_RETRIES="${ORDS_READY_RETRIES:-3}"
ORDS_READY_RETRY_WAIT_SECONDS="${ORDS_READY_RETRY_WAIT_SECONDS:-15}"
MINIO_API_PORT="${MINIO_API_PORT:-38900}"
ICEBERG_CATALOG_PORT="${ICEBERG_CATALOG_PORT:-38181}"
TRINO_PORT="${TRINO_PORT:-38080}"
LAKEHOUSE_QUERY_API_PORT="${LAKEHOUSE_QUERY_API_PORT:-18080}"
HELPER_DIR="${HELPER_DIR:-${LAB_HOME}/troubleshooting/scripts}"
HOST_STORAGE_CHECK="${HOST_STORAGE_CHECK:-${HELPER_DIR}/check_host_storage.sh}"
OGG_FIELD_KIT_SOURCE="${OGG_FIELD_KIT_SOURCE:-${LAB_HOME}/oracle/script/ogg}"
OGG_FIELD_KIT_TARGET="${OGG_FIELD_KIT_TARGET:-/u01/ogg/scripts/field-kit}"
OGG_OBEY_SOURCE="${OGG_OBEY_SOURCE:-${LAB_HOME}/oracle/script/ogg/obey}"
OGG_OBEY_TARGET="${OGG_OBEY_TARGET:-/u01/ogg/scripts/obey}"
OGG_API_SERVER_SOURCE="${OGG_API_SERVER_SOURCE:-${LAB_HOME}/oracle/ogg_api_server.py}"
OGG_API_SERVER_TARGET="${OGG_API_SERVER_TARGET:-/u01/ogg_api_server.py}"
OGG_API_START_HOOK_OGGHUB_SOURCE="${OGG_API_START_HOOK_OGGHUB_SOURCE:-${LAB_HOME}/oracle/99_start_ogg_api_ogghub.sh}"
OGG_API_START_HOOK_OGGBD_SOURCE="${OGG_API_START_HOOK_OGGBD_SOURCE:-${LAB_HOME}/oracle/99_start_ogg_api_oggbd.sh}"
OGG_API_START_HOOK_TARGET="${OGG_API_START_HOOK_TARGET:-/u01/ogg/scripts/startup/99_start_ogg_api.sh}"
FABRIC_APPLY_SERVICE_SOURCE="${FABRIC_APPLY_SERVICE_SOURCE:-${LAB_HOME}/oracle/fabric_apply_service.py}"
FABRIC_APPLY_SERVICE_TARGET="${FABRIC_APPLY_SERVICE_TARGET:-/u01/ogg/scripts/fabric_apply_service.py}"
FABRIC_APPLY_START_HOOK_SOURCE="${FABRIC_APPLY_START_HOOK_SOURCE:-${LAB_HOME}/oracle/98_start_fabric_apply_service.sh}"
FABRIC_APPLY_START_HOOK_TARGET="${FABRIC_APPLY_START_HOOK_TARGET:-/u01/ogg/scripts/startup/98_start_fabric_apply_service.sh}"
FABRIC_APPLY_PORT="${FABRIC_APPLY_PORT:-18091}"
FABRIC_APPLY_TOKEN="${FABRIC_APPLY_TOKEN:-lab20-fabric-apply-token}"
CHK_PS_SCRIPT="${CHK_PS_SCRIPT:-${LAB_HOME}/chk_ps.sh}"
CHK_ENV_SCRIPT="${CHK_ENV_SCRIPT:-${LAB_HOME}/chk_env.sh}"
STOP_DOCKER_SCRIPT="${STOP_DOCKER_SCRIPT:-${LAB_HOME}/stopDocker.sh}"
LEGACY_OSA_CLEANUP="${LEGACY_OSA_CLEANUP:-${LAB_HOME}/cleanup_legacy_osa_scripts.sh}"
CLEAN_STOP_BEFORE_START="${CLEAN_STOP_BEFORE_START:-Y}"
APEX_PDB_NAME="${APEX_PDB_NAME:-}"
APEX_SCHEMA="${APEX_SCHEMA:-GGADMIN}"
TRAILS_DIRECTORY_NAME="${TRAILS_DIRECTORY_NAME:-TRAILS}"
TRAILS_DIRECTORY_PATH="${TRAILS_DIRECTORY_PATH:-/home/oracle/msa/trails}"
OGG_REST_USER="${OGG_REST_USER:-oggadmin}"
OGG_REST_PASSWORD="${OGG_REST_PASSWORD:-WElcome1234##}"
OGG_PRIVILEGE_SELF_HEAL="${OGG_PRIVILEGE_SELF_HEAL:-N}"

# Retention defaults are deliberately conservative for a laptop lab. Increase
# them when you need to preserve diagnostic files for troubleshooting.
ARCHIVE_RETENTION_DAYS="${ARCHIVE_RETENTION_DAYS:-3}"
LOG_RETENTION_DAYS="${LOG_RETENTION_DAYS:-7}"
MAX_ACTIVE_LISTENER_LOG_MB="${MAX_ACTIVE_LISTENER_LOG_MB:-100}"
KAFKA_START_RETRY_WAIT_SECONDS="${KAFKA_START_RETRY_WAIT_SECONDS:-20}"
OGGBD_RECEIVER_PORT="${OGGBD_RECEIVER_PORT:-9014}"
OGGBD_RECEIVER_READY_RETRIES="${OGGBD_RECEIVER_READY_RETRIES:-3}"
OGGBD_RECEIVER_READY_WAIT_SECONDS="${OGGBD_RECEIVER_READY_WAIT_SECONDS:-20}"

# Accept common yes/no spellings for optional startup switches. Keeping this
# helper tiny makes the script easy to customize in a reader's own environment.
is_enabled() {
  case "${1:-}" in
    1|Y|y|YES|yes|TRUE|true|ON|on) return 0 ;;
    *) return 1 ;;
  esac
}

run_startup_check() {
  local script_path="$1"
  local mode="$2"
  local label="$3"
  local severity="${4:-warn}"

  if [ ! -x "${script_path}" ]; then
    if [ "${severity}" = "fatal" ]; then
      echo "ERROR: required startup check not found or not executable: ${script_path}"
      exit 1
    fi
    echo "INFO: ${label}: ${script_path} not found; skip"
    return 0
  fi

  echo "==> ${label}: ${mode}"
  if "${script_path}" "${mode}"; then
    return 0
  fi

  if [ "${severity}" = "fatal" ]; then
    echo "ERROR: ${label}: ${mode} failed"
    exit 1
  fi

  echo "WARN: ${label}: ${mode} reported issues; continue startup"
}

run_clean_stop_before_start() {
  if ! is_enabled "${CLEAN_STOP_BEFORE_START}"; then
    echo "INFO: CLEAN_STOP_BEFORE_START=${CLEAN_STOP_BEFORE_START}; skip clean stop"
    return 0
  fi

  if [ ! -f "${STOP_DOCKER_SCRIPT}" ]; then
    echo "WARN: stop script not found: ${STOP_DOCKER_SCRIPT}; continue startup"
    return 0
  fi

  echo "==> clean stop before startup"
  CONTAINERS="${BIGDATA_CONTAINER} ${OGGBD_CONTAINER} ${OGG_CONTAINER} ${TARGET_DB_CONTAINER} ${SOURCE_DB_CONTAINER}" \
    sh "${STOP_DOCKER_SCRIPT}" || {
      echo "WARN: clean stop before startup reported issues; continue startup"
      return 0
    }
}

# Start a container if it exists. Missing optional containers are reported as a
# warning so that one unavailable component does not block the whole lab startup.
start_container() {
  local container="$1"

  if ! docker inspect "${container}" >/dev/null 2>&1; then
    echo "WARN: container not found: ${container}"
    return 0
  fi

  echo "==> docker start ${container}"
  docker start "${container}" >/dev/null
}

# Copy a helper script into the target container. Helpers run inside the
# container because listener logs, archive logs, ORDS config, and APEX metadata
# are all container-local state.
copy_helper() {
  local container="$1"
  local script_name="$2"
  local source_path="${HELPER_DIR}/${script_name}"
  local target_dir="/tmp/ogg-lab-maintenance"

  if [ ! -f "${source_path}" ]; then
    echo "WARN: helper not found: ${source_path}"
    return 1
  fi

  docker exec -u root "${container}" mkdir -p "${target_dir}" || return 1
  docker cp "${source_path}" "${container}:${target_dir}/${script_name}" || return 1
  docker exec -u root "${container}" chmod 755 "${target_dir}/${script_name}" || return 1
}

# Run a command as the oracle user and continue on failure. Startup maintenance
# should reduce lab friction, not prevent the reader from seeing what is wrong.
run_in_container() {
  local container="$1"
  shift

  echo "==> ${container}: $*"
  docker exec -u oracle "${container}" "$@" || {
    echo "WARN: ${container}: command failed, continue startup"
  }
}

# Pass environment variables after the helper name, for example:
# run_helper demo_osrc_23ai cleanup_archivelogs.sh RETENTION_DAYS=3
run_helper() {
  local container="$1"
  local script_name="$2"
  shift 2

  if ! copy_helper "${container}" "${script_name}"; then
    echo "INFO: ${container}: skip optional helper ${script_name}"
    return 0
  fi

  run_in_container "${container}" env "$@" bash "/tmp/ogg-lab-maintenance/${script_name}"
}

# Safety-critical maintenance must fail closed. Missing scripts, copy failures,
# and non-zero helper exits stop startup instead of being reduced to warnings.
run_required_helper() {
  local container="$1"
  local script_name="$2"
  shift 2

  if ! copy_helper "${container}" "${script_name}"; then
    echo "ERROR: ${container}: required helper unavailable: ${script_name}"
    return 1
  fi

  echo "==> ${container}: required helper ${script_name}"
  if ! docker exec -u oracle "${container}" env "$@" \
      bash "/tmp/ogg-lab-maintenance/${script_name}"; then
    echo "ERROR: ${container}: required helper failed: ${script_name}"
    return 1
  fi
}

stop_optional_ai_workers() {
  if is_enabled "${AI_WORKERS_AUTOSTART}"; then
    echo "INFO: AI_WORKERS_AUTOSTART=${AI_WORKERS_AUTOSTART}; keep optional OCI AI worker timers unchanged"
    return 0
  fi

  if ! command -v systemctl >/dev/null 2>&1; then
    echo "INFO: systemctl not found; skip optional OCI AI worker timer check"
    return 0
  fi

  echo "==> stop optional OCI AI worker timers for base GoldenGate/OSA labs"
  if command -v sudo >/dev/null 2>&1; then
    sudo -n systemctl disable --now ${AI_WORKER_UNITS} >/dev/null 2>&1 || {
      echo "WARN: could not disable optional OCI AI worker timers without sudo authentication"
      echo "WARN: run manually if needed: sudo systemctl disable --now ${AI_WORKER_UNITS}"
    }
  else
    systemctl disable --now ${AI_WORKER_UNITS} >/dev/null 2>&1 || {
      echo "WARN: could not disable optional OCI AI worker timers"
    }
  fi
}

# Keep the small GoldenGate helper scripts current even when a reader updates
# the Lab Kit files from GitHub but does not rebuild the OGG image immediately.
sync_ogg_field_kit() {
  local container="$1"

  if ! docker inspect "${container}" >/dev/null 2>&1; then
    echo "WARN: ${container}: container not found, skip OGG field kit sync"
    return 0
  fi

  if [ ! -d "${OGG_FIELD_KIT_SOURCE}" ]; then
    echo "WARN: OGG field kit source not found: ${OGG_FIELD_KIT_SOURCE}"
    return 0
  fi

  echo "==> ${container}: sync OGG field kit"
  docker exec -u root "${container}" mkdir -p "${OGG_FIELD_KIT_TARGET}" || {
    echo "WARN: ${container}: cannot create ${OGG_FIELD_KIT_TARGET}"
    return 0
  }
  docker cp "${OGG_FIELD_KIT_SOURCE}/." "${container}:${OGG_FIELD_KIT_TARGET}/" || {
    echo "WARN: ${container}: OGG field kit copy failed"
    return 0
  }
  docker exec -u root "${container}" bash -lc \
    "chmod +x '${OGG_FIELD_KIT_TARGET}'/*.sh '${OGG_FIELD_KIT_TARGET}'/ogg_field_kit.py 2>/dev/null || true; \
     mkdir -p '${OGG_FIELD_KIT_TARGET}'/trails; \
     chown -R ogg:ogg '${OGG_FIELD_KIT_TARGET}' 2>/dev/null || true" || {
      echo "WARN: ${container}: OGG field kit permission repair failed"
    }

  if [ -d "${OGG_OBEY_SOURCE}" ]; then
    echo "==> ${container}: sync OGG Admin Client OBEY files"
    docker exec -u root "${container}" mkdir -p "${OGG_OBEY_TARGET}" || {
      echo "WARN: ${container}: cannot create ${OGG_OBEY_TARGET}"
      return 0
    }
    docker cp "${OGG_OBEY_SOURCE}/." "${container}:${OGG_OBEY_TARGET}/" || {
      echo "WARN: ${container}: OGG OBEY file copy failed"
      return 0
    }
    docker exec -u root "${container}" bash -lc \
      "chown -R ogg:ogg '${OGG_OBEY_TARGET}' 2>/dev/null || true; \
       chmod 644 '${OGG_OBEY_TARGET}'/*.oby '${OGG_OBEY_TARGET}'/*.md 2>/dev/null || true" || {
        echo "WARN: ${container}: OGG OBEY permission repair failed"
      }
  fi
}

sync_ogg_api_server() {
  local container="$1"
  local deployment="$2"
  local hook_source="$3"
  local ogg_url="${4:-http://localhost:9012}"

  if ! docker inspect "${container}" >/dev/null 2>&1; then
    echo "WARN: ${container}: container not found, skip OGG API server sync"
    return 0
  fi

  if [ ! -f "${OGG_API_SERVER_SOURCE}" ]; then
    echo "WARN: OGG API server source not found: ${OGG_API_SERVER_SOURCE}"
    return 0
  fi

  if [ ! -f "${hook_source}" ]; then
    echo "WARN: OGG API startup hook not found: ${hook_source}"
    return 0
  fi

  echo "==> ${container}: sync OGG API server"
  docker exec -u root "${container}" mkdir -p /u01/ogg/scripts/startup || {
    echo "WARN: ${container}: cannot create OGG API script directory"
    return 0
  }
  docker cp "${OGG_API_SERVER_SOURCE}" "${container}:${OGG_API_SERVER_TARGET}" || {
    echo "WARN: ${container}: OGG API server copy failed"
    return 0
  }
  docker cp "${hook_source}" "${container}:${OGG_API_START_HOOK_TARGET}" || {
    echo "WARN: ${container}: OGG API startup hook copy failed"
    return 0
  }
  docker exec -u root "${container}" bash -lc \
    "chmod 755 '${OGG_API_SERVER_TARGET}' '${OGG_API_START_HOOK_TARGET}' 2>/dev/null || true; \
     chown ogg:ogg '${OGG_API_SERVER_TARGET}' '${OGG_API_START_HOOK_TARGET}' 2>/dev/null || true" || {
      echo "WARN: ${container}: OGG API server permission repair failed"
    }

  echo "==> ${container}: restart OGG API server"
  docker exec -u root "${container}" bash -lc \
    "pkill -f '[o]gg_api_server.py' 2>/dev/null || true; \
     touch /u01/ogg/scripts/ogg_api_server.log; \
     chown ogg:ogg /u01/ogg/scripts/ogg_api_server.log 2>/dev/null || true" || true
  docker exec -u ogg "${container}" bash -lc \
    "nohup env OGG_URL='${ogg_url}' OGG_DEPLOYMENT='${deployment}' OGG_USER=\"\${OGG_USER:-\${OGG_ADMIN:-${OGG_REST_USER}}}\" OGG_PASS=\"\${OGG_PASS:-\${OGG_ADMIN_PWD:-${OGG_REST_PASSWORD}}}\" \
       '${OGG_API_SERVER_TARGET}' 8765 >/u01/ogg/scripts/ogg_api_server.log 2>&1 &" || {
      echo "WARN: ${container}: OGG API server restart command failed"
      return 0
    }

  sleep 2
  if docker exec "${container}" curl -fsS --max-time 5 http://127.0.0.1:8765/api/health >/dev/null 2>&1; then
    echo "OK: ${container}: OGG API server is ready on 8765"
  else
    echo "WARN: ${container}: OGG API server did not answer on 8765"
  fi
}

sync_fabric_apply_service() {
  local container="$1"

  if ! docker inspect "${container}" >/dev/null 2>&1; then
    echo "WARN: ${container}: container not found, skip Data Fabric apply helper sync"
    return 0
  fi

  if [ ! -f "${FABRIC_APPLY_SERVICE_SOURCE}" ]; then
    echo "WARN: Data Fabric apply helper source not found: ${FABRIC_APPLY_SERVICE_SOURCE}"
    return 0
  fi

  if [ ! -f "${FABRIC_APPLY_START_HOOK_SOURCE}" ]; then
    echo "WARN: Data Fabric apply helper startup hook not found: ${FABRIC_APPLY_START_HOOK_SOURCE}"
    return 0
  fi

  echo "==> ${container}: sync Data Fabric apply helper"
  docker exec -u root "${container}" mkdir -p /u01/ogg/scripts/startup || {
    echo "WARN: ${container}: cannot create Data Fabric helper script directory"
    return 0
  }
  docker cp "${FABRIC_APPLY_SERVICE_SOURCE}" "${container}:${FABRIC_APPLY_SERVICE_TARGET}" || {
    echo "WARN: ${container}: Data Fabric apply helper copy failed"
    return 0
  }
  docker cp "${FABRIC_APPLY_START_HOOK_SOURCE}" "${container}:${FABRIC_APPLY_START_HOOK_TARGET}" || {
    echo "WARN: ${container}: Data Fabric apply helper startup hook copy failed"
    return 0
  }
  docker exec -u root "${container}" bash -lc \
    "chmod 755 '${FABRIC_APPLY_SERVICE_TARGET}' '${FABRIC_APPLY_START_HOOK_TARGET}' 2>/dev/null || true; \
     chown ogg:ogg '${FABRIC_APPLY_SERVICE_TARGET}' '${FABRIC_APPLY_START_HOOK_TARGET}' 2>/dev/null || true" || {
      echo "WARN: ${container}: Data Fabric apply helper permission repair failed"
    }

  echo "==> ${container}: restart Data Fabric apply helper"
  docker exec -u root "${container}" bash -lc \
    "pkill -f '[f]abric_apply_service.py' 2>/dev/null || true; \
     touch /u01/ogg/scripts/fabric_apply_service.log; \
     chown ogg:ogg /u01/ogg/scripts/fabric_apply_service.log 2>/dev/null || true" || true
  docker exec -u ogg "${container}" bash -lc \
    "nohup env FABRIC_APPLY_PORT='${FABRIC_APPLY_PORT}' FABRIC_APPLY_TOKEN='${FABRIC_APPLY_TOKEN}' \
       '${FABRIC_APPLY_SERVICE_TARGET}' >/u01/ogg/scripts/fabric_apply_service.log 2>&1 &" || {
      echo "WARN: ${container}: Data Fabric apply helper restart command failed"
      return 0
    }

  sleep 2
  if docker exec "${container}" curl -fsS --max-time 5 "http://127.0.0.1:${FABRIC_APPLY_PORT}/health" >/dev/null 2>&1; then
    echo "OK: ${container}: Data Fabric apply helper is ready on ${FABRIC_APPLY_PORT}"
  else
    echo "WARN: ${container}: Data Fabric apply helper did not answer on ${FABRIC_APPLY_PORT}"
  fi
}

sync_ords_start_helper() {
  local container="$1"

  if ! docker inspect "${container}" >/dev/null 2>&1; then
    echo "WARN: ${container}: container not found, skip ORDS startup helper sync"
    return 0
  fi

  if [ ! -f "${ORDS_START_HELPER_SOURCE}" ]; then
    echo "WARN: ORDS startup helper not found: ${ORDS_START_HELPER_SOURCE}"
    return 0
  fi

  echo "==> ${container}: sync ORDS startup helper"
  docker exec -u root "${container}" mkdir -p /home/oracle/apex || {
    echo "WARN: ${container}: cannot create /home/oracle/apex"
    return 0
  }
  docker cp "${ORDS_START_HELPER_SOURCE}" "${container}:/home/oracle/apex/start_ords.sh" || {
    echo "WARN: ${container}: ORDS startup helper copy failed"
    return 0
  }
  docker exec -u root "${container}" bash -lc \
    "chown oracle:oinstall /home/oracle/apex/start_ords.sh 2>/dev/null || true; \
     chmod 755 /home/oracle/apex/start_ords.sh" || {
      echo "WARN: ${container}: ORDS startup helper permission repair failed"
    }
}

ords_home_exists() {
  local container="$1"

  docker exec -u oracle "${container}" bash -lc \
    "[ -x /home/oracle/ords/bin/ords ] || [ -x /home/oracle/ords_new/bin/ords ]" \
    >/dev/null 2>&1
}

# ORDS must be restarted after static file path repairs. APEX page rendering can
# also recover from stale ORDS sessions after a clean restart.
restart_ords() {
  local container="$1"

  if ! ords_home_exists "${container}"; then
    echo "INFO: ${container}: ORDS is not installed; run lab12_init.sh before using APEX"
    return 0
  fi

  echo "==> ${container}: restart ORDS"
  docker exec -u oracle "${container}" bash -lc \
    "mapfile -t pids < <(ps -eo pid=,comm=,args= | awk '\$2 == \"java\" && index(\$0, \"ords.war\") && index(\$0, \"/home/oracle/ords_config\") { print \$1 }'); \
     if [ \"\${#pids[@]}\" -gt 0 ]; then \
       printf '%s\n' \"\${pids[@]}\" | xargs -r kill; \
       sleep 8; \
     fi; \
     mapfile -t pids < <(ps -eo pid=,comm=,args= | awk '\$2 == \"java\" && index(\$0, \"ords.war\") && index(\$0, \"/home/oracle/ords_config\") { print \$1 }'); \
     if [ \"\${#pids[@]}\" -gt 0 ]; then \
       echo 'WARN: ORDS process did not stop cleanly; force stop stale process'; \
       printf '%s\n' \"\${pids[@]}\" | xargs -r kill -9; \
       sleep 3; \
     fi" || true

  sleep 2

  docker exec -d -u oracle "${container}" bash -lc \
    "if [ -x /home/oracle/apex/start_ords.sh ]; then \
       exec /home/oracle/apex/start_ords.sh; \
     fi; \
     if [ -x /home/oracle/script/apex/start_ords.sh ]; then \
       exec /home/oracle/script/apex/start_ords.sh; \
     fi; \
     ORDS_HOME=/home/oracle/ords; \
     if [ ! -x \"\${ORDS_HOME}/bin/ords\" ] && [ -x /home/oracle/ords_new/bin/ords ]; then \
       ORDS_HOME=/home/oracle/ords_new; \
     fi; \
     JAVA_HOME=/usr/java/jdk-17 PATH=/usr/java/jdk-17/bin:\"\${ORDS_HOME}/bin\":\$PATH \
       exec \"\${ORDS_HOME}/bin/ords\" --config /home/oracle/ords_config serve"
}

# Lightweight HTTP check used after ORDS restart. GET is used instead of HEAD
# because ORDS/APEX redirects and handlers are not always HEAD-friendly.
check_url() {
  local url="$1"

  if curl --max-time 10 -fsS -L -o /dev/null "${url}" >/dev/null 2>&1; then
    echo "OK: ${url}"
    return 0
  fi

  return 1
}

# Some non-ORDS services do not implement HEAD. Use a GET probe for MinIO,
# Iceberg REST Catalog, Trino, and the local Lakehouse Query API.
check_get_url() {
  local url="$1"

  if curl --max-time 10 -fsS "${url}" >/dev/null; then
    echo "OK: ${url}"
    return 0
  else
    echo "WARN: check failed: ${url}"
    return 1
  fi
}

check_external_port_binding() {
  local container="$1"
  local container_port="$2"
  local host_port="$3"
  local label="$4"
  local bindings

  if ! bindings="$(docker port "${container}" "${container_port}" 2>/dev/null)"; then
    echo "WARN: ${label}: cannot inspect Docker port binding for ${container_port}/tcp"
    return 0
  fi

  if [ -z "${bindings}" ]; then
    echo "WARN: ${label}: ${container_port}/tcp is not published to host port ${host_port}"
    return 0
  fi

  if printf '%s\n' "${bindings}" | grep -Eq "^(0\\.0\\.0\\.0:${host_port}|::?:${host_port}|\\[::\\]:${host_port})$"; then
    echo "OK: ${label}: ${container_port}/tcp is published for external access on host port ${host_port}"
    return 0
  fi

  echo "WARN: ${label}: ${container_port}/tcp is not published on all host interfaces"
  printf '%s\n' "${bindings}" | sed 's/^/  current binding: /'
  echo "WARN: ${label}: external browser access needs compose port mapping like \"${host_port}:${container_port}\""
  echo "WARN: ${label}: existing container port bindings cannot be changed without container recreate"
}

ensure_ords_ready() {
  local container="$1"
  local port="$2"
  local label="$3"
  local base_url="http://127.0.0.1:${port}"
  local attempt=1

  if ! ords_home_exists "${container}"; then
    echo "INFO: ${label}: ORDS is not installed; skip readiness check until lab12_init.sh"
    return 0
  fi

  while [ "${attempt}" -le "${ORDS_READY_RETRIES}" ]; do
    echo "==> ${label}: verify ORDS/APEX endpoint (attempt ${attempt}/${ORDS_READY_RETRIES})"
    if check_url "${base_url}/ords/" &&
       check_url "${base_url}/i/apex_version.txt"; then
      echo "OK: ${label}: ORDS/APEX is ready on host port ${port}"
      return 0
    fi

    if [ "${attempt}" -lt "${ORDS_READY_RETRIES}" ]; then
      if [ "${attempt}" -eq 1 ]; then
        echo "INFO: ${label}: ORDS/APEX is still starting; retry in ${ORDS_READY_RETRY_WAIT_SECONDS}s"
      else
        echo "INFO: ${label}: ORDS/APEX is still not ready; restart ORDS and retry in ${ORDS_READY_RETRY_WAIT_SECONDS}s"
        restart_ords "${container}"
      fi
      sleep "${ORDS_READY_RETRY_WAIT_SECONDS}"
    fi

    attempt=$((attempt + 1))
  done

  echo "WARN: ${label}: ORDS/APEX did not become ready on host port ${port}; inspect the ORDS process and log"
  docker exec -u oracle "${container}" bash -lc \
    "echo '--- ORDS process ---'; \
     ps -eo pid=,comm=,args= | awk '\$2 == \"java\" && (index(\$0, \"ords.war\") || index(\$0, \"oracle.dbtools\")) { print }' || true; \
     echo '--- ORDS log tail ---'; \
     tail -n 80 /home/oracle/ords_logs/ords-standalone.log 2>/dev/null || true" || true
}

check_tcp_from_container() {
  local from_container="$1"
  local host="$2"
  local port="$3"

  docker exec "${from_container}" bash -lc \
    "timeout 5 bash -lc '</dev/tcp/${host}/${port}'" >/dev/null 2>&1
}

check_tcp_in_container() {
  local container="$1"
  local host="$2"
  local port="$3"

  docker exec "${container}" bash -lc \
    "timeout 5 bash -lc '</dev/tcp/${host}/${port}'" >/dev/null 2>&1
}

# Oracle's GoldenGate container keeps Service Manager runtime files under the
# persistent deployment home. After a laptop sleep/reboot or an unclean Docker
# shutdown, ServiceManager.pid can remain even though the process no longer
# exists. On the next docker start, Service Manager may refuse to start with:
# "Another instance of Service Manager (process id NN) is already running".
# This repair removes only stale runtime files, never trail/checkpoint data.
repair_ogg_service_manager() {
  local container="$1"
  local sm_port="${OGG_SERVICE_MANAGER_PORT:-9011}"

  if ! docker inspect "${container}" >/dev/null 2>&1; then
    echo "WARN: ${container}: container not found, skip OGG Service Manager repair"
    return 0
  fi

  if check_tcp_in_container "${container}" "127.0.0.1" "${sm_port}"; then
    echo "OK: ${container}: Service Manager is listening on ${sm_port}"
    return 0
  fi

  echo "WARN: ${container}: Service Manager is not listening on ${sm_port}; run self-healing repair"
  docker exec -u root "${container}" bash -lc '
    set -u
    pid_file="/u02/ServiceManager/var/run/ServiceManager.pid"
    run_dir="/u02/ServiceManager/var/run"

    if [ -f "${pid_file}" ]; then
      pid="$(cat "${pid_file}" 2>/dev/null || true)"
      if [ -z "${pid}" ] || ! ps -p "${pid}" >/dev/null 2>&1; then
        echo "[self-healing] remove stale ServiceManager pid/socket files"
        rm -f "${pid_file}" "${run_dir}"/*.sock
      else
        echo "[self-healing] ServiceManager.pid points to live pid ${pid}; leave it in place"
      fi
    fi

    # Older custom images copied the optional API helper to /u01 while the
    # startup hook looks under /u01/ogg/scripts. Keep both layouts working.
    if [ -f /u01/ogg_api_server.py ] && [ ! -f /u01/ogg/scripts/ogg_api_server.py ]; then
      echo "[self-healing] repair optional OGG API helper path"
      cp -p /u01/ogg_api_server.py /u01/ogg/scripts/ogg_api_server.py
      chmod 755 /u01/ogg/scripts/ogg_api_server.py 2>/dev/null || true
      chown ogg:ogg /u01/ogg/scripts/ogg_api_server.py 2>/dev/null || true
    fi
  ' || {
    echo "WARN: ${container}: Service Manager self-healing command failed"
    return 0
  }

  echo "==> docker restart ${container} after OGG Service Manager repair"
  docker restart "${container}" >/dev/null || {
    echo "WARN: ${container}: restart failed after Service Manager repair"
    return 0
  }

  sleep 30

  if check_tcp_in_container "${container}" "127.0.0.1" "${sm_port}"; then
    echo "OK: ${container}: Service Manager recovered on ${sm_port}"
  else
    echo "WARN: ${container}: Service Manager still not reachable; check /u02/ServiceManager/var/log/ServiceManager.log"
  fi
}

oggbd_receiver_is_ready() {
  local container="$1"
  local receiver_port="$2"

  docker exec "${container}" bash -lc \
    "pgrep -f '[r]ecvsrvr' >/dev/null 2>&1 && timeout 5 bash -lc '</dev/tcp/127.0.0.1/${receiver_port}'" >/dev/null 2>&1
}

# OGGBD can occasionally show the deployment as RUNNING through Admin Client
# while the Receiver Server process is not actually listening. In that state,
# the OGGHUB distribution path fails with OGG-10351 / connection refused. A
# container restart is safe here because it restarts only OGGBD microservices
# and does not recreate trails, checkpoints, or database containers.
ensure_oggbd_receiver_ready() {
  local container="$1"
  local receiver_port="$2"
  local attempt=1

  if ! docker inspect "${container}" >/dev/null 2>&1; then
    echo "WARN: ${container}: container not found, skip OGGBD Receiver check"
    return 0
  fi

  while [ "${attempt}" -le "${OGGBD_RECEIVER_READY_RETRIES}" ]; do
    echo "==> ${container}: verify OGGBD Receiver Server on ${receiver_port} (attempt ${attempt}/${OGGBD_RECEIVER_READY_RETRIES})"
    if oggbd_receiver_is_ready "${container}" "${receiver_port}"; then
      echo "OK: ${container}: Receiver Server is listening on ${receiver_port}"
      return 0
    fi

    if [ "${attempt}" -eq 1 ]; then
      echo "WARN: ${container}: Receiver Server is not ready; restart ${container} only"
      docker restart "${container}" >/dev/null || {
        echo "WARN: ${container}: restart failed while repairing Receiver Server"
        return 0
      }
    else
      echo "WARN: ${container}: Receiver Server still not ready; wait ${OGGBD_RECEIVER_READY_WAIT_SECONDS}s"
    fi

    sleep "${OGGBD_RECEIVER_READY_WAIT_SECONDS}"
    attempt=$((attempt + 1))
  done

  echo "WARN: ${container}: Receiver Server did not become ready on ${receiver_port}; inspect OGG Big Data services"
  docker exec "${container}" bash -lc \
    "echo '--- OGG Big Data processes ---'; \
     ps -eo pid=,args= | awk '/[a]dminsrvr|[d]istsrvr|[r]ecvsrvr|[p]msrvr/ { print }' || true; \
     echo '--- listening ports ---'; \
     (ss -ltn 2>/dev/null || netstat -ltn 2>/dev/null || true) | awk '/:901[1-5][[:space:]]/ { print }'" || true
}

# Docker can show the Oracle DB containers as "Up" while the listener process is
# not accepting TCP connections yet. GoldenGate DBLOGIN depends on the listener,
# so startDocker repairs this before readers begin Admin Client work. The
# prebuilt DB image can also carry a build-time hostname in listener.ora; replace
# it with 0.0.0.0 so the listener binds inside the runtime container.
ensure_db_listener() {
  local db_container="$1"
  local db_service="$2"
  local label="$3"

  if ! docker inspect "${db_container}" >/dev/null 2>&1; then
    echo "WARN: ${label}: container not found: ${db_container}"
    return 0
  fi

  if ! docker inspect "${OGG_CONTAINER}" >/dev/null 2>&1; then
    echo "WARN: ${label}: OGG container not found, skip listener reachability check"
    return 0
  fi

  if check_tcp_from_container "${OGG_CONTAINER}" "${db_service}" "${ORACLE_DB_PORT}"; then
    echo "OK: ${label} listener is reachable from ${OGG_CONTAINER} at ${db_service}:${ORACLE_DB_PORT}"
    return 0
  fi

  echo "WARN: ${label} listener is not reachable from ${OGG_CONTAINER}; try lsnrctl start"
  docker exec -u oracle "${db_container}" bash -lc \
    "export ORACLE_HOME='${ORACLE_HOME}' ORACLE_SID='${ORACLE_SID}' PATH='${ORACLE_HOME}/bin':\$PATH; \
     listener_file=\"\${ORACLE_HOME}/network/admin/listener.ora\"; \
     if [ -f \"\${listener_file}\" ]; then \
       cp -p \"\${listener_file}\" \"\${listener_file}.bak_ogg_lab\" 2>/dev/null || true; \
       sed -i -E 's/\\(HOST[[:space:]]*=[[:space:]]*[^)]+\\)/(HOST = 0.0.0.0)/g' \"\${listener_file}\"; \
     fi; \
     lsnrctl start >/tmp/ogg_lab_lsnrctl_start.log 2>&1 || true; \
     printf 'alter system register;\nexit\n' | sqlplus -s / as sysdba >/tmp/ogg_lab_listener_register.log 2>&1 || true" || {
      echo "WARN: ${label}: listener start/register command failed"
    }

  sleep 5

  if check_tcp_from_container "${OGG_CONTAINER}" "${db_service}" "${ORACLE_DB_PORT}"; then
    echo "OK: ${label} listener is reachable from ${OGG_CONTAINER} at ${db_service}:${ORACLE_DB_PORT}"
  else
    echo "WARN: ${label} listener is still not reachable; check ${db_container} /tmp/ogg_lab_lsnrctl_start.log"
  fi
}

configure_apex_trail_directory() {
  local container="$1"

  if ! docker inspect "${container}" >/dev/null 2>&1; then
    echo "WARN: ${container}: container not found, skip APEX TRAILS directory setup"
    return 0
  fi

  echo "==> ${container}: prepare APEX Trail download directory"
  docker exec -u root "${container}" bash -lc \
    "mkdir -p '${TRAILS_DIRECTORY_PATH}' && \
     chown oracle:oinstall '${TRAILS_DIRECTORY_PATH}' 2>/dev/null || true; \
     chmod 775 '${TRAILS_DIRECTORY_PATH}'" || {
      echo "WARN: ${container}: cannot prepare ${TRAILS_DIRECTORY_PATH}"
      return 0
    }

  docker exec -u oracle "${container}" bash -lc \
    "set -e; \
     if command -v sqlplus >/dev/null 2>&1; then \
       SQLPLUS_BIN=\"\$(command -v sqlplus)\"; \
     else \
       for candidate in /opt/oracle/product/*/*/bin/sqlplus /opt/oracle/product/*/dbhome*/bin/sqlplus; do \
         if [ -x \"\$candidate\" ]; then SQLPLUS_BIN=\"\$candidate\"; break; fi; \
       done; \
     fi; \
     [ -n \"\${SQLPLUS_BIN:-}\" ] || { echo 'WARN: sqlplus not found'; exit 1; }; \
     export ORACLE_HOME=\"\${SQLPLUS_BIN%/bin/sqlplus}\"; \
     export ORACLE_SID=\"\${ORACLE_SID:-ORCLCDB}\"; \
     export PATH=\"\${ORACLE_HOME}/bin:\$PATH\"; \
     \"\$SQLPLUS_BIN\" -s / as sysdba <<SQL
whenever sqlerror exit sql.sqlcode rollback
set serveroutput on feedback off verify off heading off pages 0
declare
  l_requested_pdb varchar2(128) := upper(trim('${APEX_PDB_NAME}'));
  l_pdb           varchar2(128);
begin
  if l_requested_pdb is not null then
    begin
      select name
        into l_pdb
        from v\\\$pdbs
       where name = l_requested_pdb
         and open_mode = 'READ WRITE';
    exception
      when no_data_found then
        l_pdb := null;
    end;
  end if;

  if l_pdb is null then
    begin
      select p.name
        into l_pdb
        from v\\\$pdbs p
        join cdb_users u on u.con_id = p.con_id
       where u.username = upper('${APEX_SCHEMA}')
         and p.open_mode = 'READ WRITE'
       fetch first 1 row only;
    exception
      when no_data_found then
        select name
          into l_pdb
          from v\\\$pdbs
         where name <> 'PDB\\\$SEED'
           and open_mode = 'READ WRITE'
         fetch first 1 row only;
    end;
  end if;

  execute immediate 'alter session set container = ' || dbms_assert.simple_sql_name(l_pdb);
  dbms_output.put_line('Using PDB ' || l_pdb);
end;
/
create or replace directory ${TRAILS_DIRECTORY_NAME} as '${TRAILS_DIRECTORY_PATH}';
declare
  l_user_count number;
begin
  select count(*)
    into l_user_count
    from dba_users
   where username = upper('${APEX_SCHEMA}');

  if l_user_count > 0 then
    execute immediate 'grant read, write on directory ${TRAILS_DIRECTORY_NAME} to ${APEX_SCHEMA}';
    dbms_output.put_line('OK: ${TRAILS_DIRECTORY_NAME} -> ${TRAILS_DIRECTORY_PATH}, granted to ${APEX_SCHEMA}');
  else
    dbms_output.put_line('INFO: ${APEX_SCHEMA} does not exist yet; rerun startDocker.sh after creating the APEX workspace if Trail downloads are needed.');
  end if;
end;
/
exit
SQL" || {
      echo "WARN: ${container}: cannot create/grant ${TRAILS_DIRECTORY_NAME} directory"
    }
}

configure_apex_ogg_rest_acl() {
  local container="$1"

  if ! is_enabled "${OGG_PRIVILEGE_SELF_HEAL}"; then
    echo "INFO: OGG_PRIVILEGE_SELF_HEAL=${OGG_PRIVILEGE_SELF_HEAL}; skip APEX OGG REST ACL grant"
    echo "INFO: Set OGG_PRIVILEGE_SELF_HEAL=Y to let startDocker.sh repair App 101 DB network ACLs in this lab."
    return 0
  fi

  if ! docker inspect "${container}" >/dev/null 2>&1; then
    echo "WARN: ${container}: container not found, skip APEX OGG REST ACL setup"
    return 0
  fi

  echo "==> ${container}: configure APEX OGG REST ACL"
  docker exec -u oracle "${container}" bash -lc \
    "set -e; \
     if command -v sqlplus >/dev/null 2>&1; then \
       SQLPLUS_BIN=\"\$(command -v sqlplus)\"; \
     else \
       for candidate in /opt/oracle/product/*/*/bin/sqlplus /opt/oracle/product/*/dbhome*/bin/sqlplus; do \
         if [ -x \"\$candidate\" ]; then SQLPLUS_BIN=\"\$candidate\"; break; fi; \
       done; \
     fi; \
     [ -n \"\${SQLPLUS_BIN:-}\" ] || { echo 'WARN: sqlplus not found'; exit 1; }; \
     export ORACLE_HOME=\"\${SQLPLUS_BIN%/bin/sqlplus}\"; \
     export ORACLE_SID=\"\${ORACLE_SID:-ORCLCDB}\"; \
     export PATH=\"\${ORACLE_HOME}/bin:\$PATH\"; \
     \"\$SQLPLUS_BIN\" -s / as sysdba <<SQL
set serveroutput on feedback off verify off heading off pages 0
declare
  l_requested_pdb varchar2(128) := upper(trim('${APEX_PDB_NAME}'));
  l_pdb           varchar2(128);
begin
  if l_requested_pdb is not null then
    begin
      select name
        into l_pdb
        from v\\\$pdbs
       where name = l_requested_pdb
         and open_mode = 'READ WRITE';
    exception
      when no_data_found then
        l_pdb := null;
    end;
  end if;

  if l_pdb is null then
    begin
      select p.name
        into l_pdb
        from v\\\$pdbs p
        join cdb_users u on u.con_id = p.con_id
       where u.username = upper('${APEX_SCHEMA}')
         and p.open_mode = 'READ WRITE'
       fetch first 1 row only;
    exception
      when no_data_found then
        select name
          into l_pdb
          from v\\\$pdbs
         where name <> 'PDB\\\$SEED'
           and open_mode = 'READ WRITE'
         fetch first 1 row only;
    end;
  end if;

  execute immediate 'alter session set container = ' || dbms_assert.simple_sql_name(l_pdb);
  dbms_output.put_line('Using PDB ' || l_pdb);
end;
/
declare
  l_apex_owner varchar2(128);
  procedure grant_connect(p_host varchar2, p_principal varchar2) is
  begin
    if p_principal is null then
      return;
    end if;
    dbms_network_acl_admin.append_host_ace(
      host => p_host,
      ace => xs\\\$ace_type(
        privilege_list => xs\\\$name_list('connect'),
        principal_name => p_principal,
        principal_type => xs_acl.ptype_db));
    dbms_output.put_line('OK: ACL connect ' || p_host || ' -> ' || p_principal);
  exception
    when others then
      dbms_output.put_line('INFO: ACL connect ' || p_host || ' -> ' || p_principal || ': ' || sqlerrm);
  end;
begin
  begin
    select table_owner
      into l_apex_owner
      from dba_synonyms
     where owner = 'PUBLIC'
       and synonym_name = 'APEX_WEB_SERVICE'
     fetch first 1 row only;
  exception
    when no_data_found then
      l_apex_owner := null;
  end;

  grant_connect('172.28.0.5', upper('${APEX_SCHEMA}'));
  grant_connect('172.28.0.6', upper('${APEX_SCHEMA}'));
  grant_connect('172.28.0.5', l_apex_owner);
  grant_connect('172.28.0.6', l_apex_owner);

  begin
    execute immediate q'[update ${APEX_SCHEMA}.ogg_conf
       set gubun1 = '${OGG_REST_USER}',
           gubun2 = '${OGG_REST_PASSWORD}',
           gubun3 = 'Basic'
     where keya = 'OGGUSER'
       and keyb = 'ADMIN'
       and keyc = 'DUMMY']';
    dbms_output.put_line('OK: refreshed ${APEX_SCHEMA}.OGG_CONF OGGUSER metadata');
  exception
    when others then
      dbms_output.put_line('INFO: skip OGG_CONF credential refresh: ' || sqlerrm);
  end;
  commit;
end;
/
exit
SQL" || {
      echo "WARN: ${container}: cannot configure APEX OGG REST ACL"
    }
}

# The Big Data container may be "Up" while its internal services are inactive.
# GoldenGate for Big Data and stream demos need Zookeeper before Kafka, so the
# script starts them in that order and retries Kafka once.
start_bigdata_services() {
  local container="$1"
  local init_script="${LAB_HOME}/centos/init.sh"

  if ! docker inspect "${container}" >/dev/null 2>&1; then
    echo "WARN: container not found: ${container}, skip BigData service startup"
    return 0
  fi

  if [ -f "${init_script}" ]; then
    echo "==> ${container}: run BigData initialization"
    BIGDATA_CONTAINER="${container}" sh "${init_script}" || {
      echo "WARN: ${container}: BigData initialization failed"
    }
    return 0
  fi

  if ! docker exec -u root "${container}" command -v systemctl >/dev/null 2>&1; then
    echo "WARN: ${container}: systemctl not found, skip BigData service startup"
    return 0
  fi

  echo "==> ${container}: start Zookeeper"
  docker exec -u root "${container}" systemctl start zookeeper || {
    echo "WARN: ${container}: failed to start zookeeper"
    return 0
  }

  echo "==> ${container}: start Kafka"
  docker exec -u root "${container}" systemctl reset-failed kafka >/dev/null 2>&1 || true
  docker exec -u root "${container}" systemctl start kafka || true
  sleep 5

  if ! docker exec -u root "${container}" systemctl is-active --quiet kafka; then
    echo "WARN: ${container}: kafka not active yet; retry after ${KAFKA_START_RETRY_WAIT_SECONDS}s"
    sleep "${KAFKA_START_RETRY_WAIT_SECONDS}"
    docker exec -u root "${container}" systemctl reset-failed kafka >/dev/null 2>&1 || true
    docker exec -u root "${container}" systemctl start kafka || true
    sleep 5
  fi

  if docker exec -u root "${container}" systemctl is-active --quiet zookeeper; then
    echo "OK: ${container}: zookeeper active"
  else
    echo "WARN: ${container}: zookeeper is not active"
  fi

  if docker exec -u root "${container}" systemctl is-active --quiet kafka; then
    echo "OK: ${container}: kafka active"
  else
    echo "WARN: ${container}: kafka is not active; check /usr/local/kafka/logs/server.log"
  fi
}

# Start optional Lakehouse application services after Kafka is active. The base
# Lakehouse containers are started earlier by LAKEHOUSE_AUTOSTART; these services
# are intentionally separate because they actively consume Kafka events or expose
# extra APIs for later chapters.
start_lakehouse_services() {
  if ! is_enabled "${LAKEHOUSE_AUTOSTART}"; then
    echo "INFO: LAKEHOUSE_AUTOSTART=${LAKEHOUSE_AUTOSTART}; skip Lakehouse stack"
    return 0
  fi

  echo "==> check optional Lakehouse application services"

  if is_enabled "${LAKEHOUSE_QUERY_API_AUTOSTART}"; then
    if [ -f "${LAKEHOUSE_QUERY_API_DIR}/docker-compose.query-api.yml" ]; then
      echo "==> Lakehouse Query API: docker compose up"
      (
        cd "${LAKEHOUSE_QUERY_API_DIR}" &&
        docker compose -f docker-compose.query-api.yml up -d --build
      ) || echo "WARN: Lakehouse Query API startup failed, continue startup"
    else
      echo "WARN: Query API compose file not found: ${LAKEHOUSE_QUERY_API_DIR}/docker-compose.query-api.yml"
    fi
  else
    echo "INFO: LAKEHOUSE_QUERY_API_AUTOSTART=${LAKEHOUSE_QUERY_API_AUTOSTART}; skip Lakehouse Query API"
  fi

  if is_enabled "${LAKEHOUSE_WRITER_AUTOSTART}"; then
    if [ -f "${LAKEHOUSE_WRITER_DIR}/docker-compose.kafka-iceberg-writer.yml" ]; then
      if [ -f "${LAKEHOUSE_WRITER_DIR}/.env" ]; then
        echo "==> Kafka -> Iceberg writer: docker compose up"
        (
          cd "${LAKEHOUSE_WRITER_DIR}" &&
          docker compose --env-file .env -f docker-compose.kafka-iceberg-writer.yml up -d --build
        ) || echo "WARN: Kafka -> Iceberg writer startup failed, continue startup"
      else
        echo "WARN: ${LAKEHOUSE_WRITER_DIR}/.env not found; skip Kafka -> Iceberg writer"
      fi
    else
      echo "WARN: writer compose file not found: ${LAKEHOUSE_WRITER_DIR}/docker-compose.kafka-iceberg-writer.yml"
    fi
  else
    echo "INFO: LAKEHOUSE_WRITER_AUTOSTART=${LAKEHOUSE_WRITER_AUTOSTART}; skip Kafka -> Iceberg writer"
  fi
}

# 1. Hold startup before touching containers when the Windows/WSL storage has
# reached the Lab safety threshold. The helper reports what the reader needs to
# resolve and never deletes host files automatically.
run_startup_check "${HOST_STORAGE_CHECK}" pre-start "Lab storage preflight" fatal

if [ -x "${LEGACY_OSA_CLEANUP}" ]; then
  echo "==> Remove legacy duplicate OSA scripts"
  "${LEGACY_OSA_CLEANUP}"
fi

# 2. Always close the reader-lab containers first. This gives every startup a
# clean process baseline instead of inheriting half-running Kafka, ORDS, Spark,
# or OGG processes from a previous WSL/Windows/browser failure.
stop_optional_ai_workers
run_clean_stop_before_start

run_startup_check "${CHK_PS_SCRIPT}" pre-start "process cleanup" warn
run_startup_check "${CHK_ENV_SCRIPT}" pre-start "environment self-healing" warn

start_container "${SOURCE_DB_CONTAINER}"
start_container "${TARGET_DB_CONTAINER}"
start_container "${OGG_CONTAINER}"
start_container "${OGGBD_CONTAINER}"
start_container "${BIGDATA_CONTAINER}"
if [ -x "${LEGACY_OSA_CLEANUP}" ]; then
  echo "==> Reconcile OSA script directories in running database containers"
  "${LEGACY_OSA_CLEANUP}"
fi

# Check whether APEX/ORDS ports are reachable from outside the host. In this
# lab kit the APEX/ORDS console runs on the target DB by default; the source DB
# can enable the same checks explicitly when a separate source APEX app exists.
if [ "${SOURCE_ORDS_ENABLED}" = "Y" ]; then
  check_external_port_binding "${SOURCE_DB_CONTAINER}" "8080" "${SOURCE_ORDS_PORT}" "Source APEX/ORDS"
else
  echo "INFO: SOURCE_ORDS_ENABLED=N; skip Source APEX/ORDS port check"
fi
if [ "${TARGET_ORDS_ENABLED}" = "Y" ]; then
  check_external_port_binding "${TARGET_DB_CONTAINER}" "8080" "${TARGET_ORDS_PORT}" "Target APEX/ORDS"
else
  echo "INFO: TARGET_ORDS_ENABLED=N; skip Target APEX/ORDS port check"
fi

# Give Oracle listener, database background processes, and container entrypoints
# a short grace period before running maintenance inside the containers.
sleep 30

# 2. Repair OGG Service Manager runtime state after an unclean lab shutdown.
repair_ogg_service_manager "${OGG_CONTAINER}"
repair_ogg_service_manager "${OGGBD_CONTAINER}"
ensure_oggbd_receiver_ready "${OGGBD_CONTAINER}" "${OGGBD_RECEIVER_PORT}"

# 3. Sync GoldenGate helper scripts into the OGG container. Fresh builds already
# include these files through DockerfileOGG23ai, but this keeps existing
# containers current after a GitHub Lab Kit file update.
sync_ogg_field_kit "${OGG_CONTAINER}"
sync_ogg_api_server "${OGG_CONTAINER}" "OGGHUB" "${OGG_API_START_HOOK_OGGHUB_SOURCE}" "http://localhost:9012"
sync_fabric_apply_service "${OGG_CONTAINER}"
sync_ogg_api_server "${OGGBD_CONTAINER}" "OGGBD" "${OGG_API_START_HOOK_OGGBD_SOURCE}" "http://localhost:9012"

# 4. Make sure Oracle DB listeners are reachable from the GoldenGate container.
# This avoids Admin Client DBLOGIN failures such as ORA-12541 after a laptop
# reboot or a plain docker start.
ensure_db_listener "${SOURCE_DB_CONTAINER}" "${SOURCE_DB_SERVICE}" "Source DB"
ensure_db_listener "${TARGET_DB_CONTAINER}" "${TARGET_DB_SERVICE}" "Target DB"

# Prepare the database-side filesystem target used by App 101 when it downloads
# a GoldenGate trail sequence through REST before running SQL-side analysis.
configure_apex_trail_directory "${TARGET_DB_CONTAINER}"
configure_apex_ogg_rest_acl "${TARGET_DB_CONTAINER}"

# 5. Make sure Kafka/Zookeeper are actually active inside the Big Data container.
# This fixes the common case where Docker says the container is Up but stream
# processing fails because the internal broker was never started.
start_bigdata_services "${BIGDATA_CONTAINER}"
run_startup_check "${CHK_ENV_SCRIPT}" post-start "environment self-healing" fatal
run_startup_check "${CHK_PS_SCRIPT}" post-start "process readiness check" fatal

# 6. Clean files that grow during long-running labs. These helpers are safe to
# repeat and are designed to stop WSL virtual disks from growing unexpectedly
# during multi-day practice.
run_helper "${SOURCE_DB_CONTAINER}" cleanup_listener_logs.sh \
  RETENTION_DAYS="${LOG_RETENTION_DAYS}" \
  MAX_ACTIVE_LOG_MB="${MAX_ACTIVE_LISTENER_LOG_MB}"
run_helper "${TARGET_DB_CONTAINER}" cleanup_listener_logs.sh \
  RETENTION_DAYS="${LOG_RETENTION_DAYS}" \
  MAX_ACTIVE_LOG_MB="${MAX_ACTIVE_LISTENER_LOG_MB}"

run_required_helper "${SOURCE_DB_CONTAINER}" cleanup_archivelogs.sh \
  RETENTION_DAYS="${ARCHIVE_RETENTION_DAYS}" \
  ORACLE_SID="${ORACLE_SID}" || exit 1
run_required_helper "${TARGET_DB_CONTAINER}" cleanup_archivelogs.sh \
  RETENTION_DAYS="${ARCHIVE_RETENTION_DAYS}" \
  ORACLE_SID="${ORACLE_SID}" || exit 1

run_helper "${SOURCE_DB_CONTAINER}" cleanup_dump_files.sh \
  RETENTION_DAYS="${LOG_RETENTION_DAYS}"
run_helper "${TARGET_DB_CONTAINER}" cleanup_dump_files.sh \
  RETENTION_DAYS="${LOG_RETENTION_DAYS}"

# 7. Repair APEX/ORDS static file mapping before users open the browser. When
# this path is wrong, APEX login pages render without CSS/JS or show an
# "Oracle APEX files have not been loaded" warning.
if [ "${SOURCE_ORDS_ENABLED}" = "Y" ]; then
  run_helper "${SOURCE_DB_CONTAINER}" ensure_apex_static_path.sh
else
  echo "INFO: SOURCE_ORDS_ENABLED=N; skip Source APEX static-path repair"
fi
if [ "${TARGET_ORDS_ENABLED}" = "Y" ]; then
  run_helper "${TARGET_DB_CONTAINER}" ensure_apex_static_path.sh
else
  echo "INFO: TARGET_ORDS_ENABLED=N; skip Target APEX static-path repair"
fi

# 8. Refresh only the Lab Kit demo accounts. This prevents account expiry,
# failed-login locks, and first-login password-change prompts from interrupting
# readers who return to the lab after several days or weeks.
if [ "${SOURCE_ORDS_ENABLED}" = "Y" ]; then
  run_helper "${SOURCE_DB_CONTAINER}" refresh_apex_demo_accounts.sh \
    APEX_DEMO_USERS="ADMIN,CALLCENTER01,NEWBIZ01,CLAIMS01,SIU01"
else
  echo "INFO: SOURCE_ORDS_ENABLED=N; skip Source APEX demo-account refresh"
fi
if [ "${TARGET_ORDS_ENABLED}" = "Y" ]; then
  run_helper "${TARGET_DB_CONTAINER}" refresh_apex_demo_accounts.sh \
    APEX_DEMO_USERS="ADMIN,GGADMIN,MESHADMIN,DWADMIN,ICEBERG01,FLOW01,HOLDING01,SCM01,SEMI01,AUTO01,INSURANCE01,CORE01"
else
  echo "INFO: TARGET_ORDS_ENABLED=N; skip Target APEX demo-account refresh"
fi

# 9. Sync and restart ORDS so repaired static-path settings and fresh APEX
# sessions are picked up cleanly. The helper sync also updates existing lab
# containers that were created before the current ORDS startup helper existed.
if [ "${SOURCE_ORDS_ENABLED}" = "Y" ]; then
  sync_ords_start_helper "${SOURCE_DB_CONTAINER}"
  restart_ords "${SOURCE_DB_CONTAINER}"
else
  echo "INFO: SOURCE_ORDS_ENABLED=N; skip Source ORDS restart"
fi
if [ "${TARGET_ORDS_ENABLED}" = "Y" ]; then
  sync_ords_start_helper "${TARGET_DB_CONTAINER}"
  restart_ords "${TARGET_DB_CONTAINER}"
else
  echo "INFO: TARGET_ORDS_ENABLED=N; skip Target ORDS restart"
fi

sleep 10

# 10. Verify both the ORDS endpoint and the APEX static files endpoint. Seeing
# these checks pass is a quick signal that the APEX login/app pages can render.
# If ORDS is slow or died immediately after startup, retry once from here rather
# than leaving readers with an "APEX URL does not open" browser symptom.
if [ "${SOURCE_ORDS_ENABLED}" = "Y" ]; then
  ensure_ords_ready "${SOURCE_DB_CONTAINER}" "${SOURCE_ORDS_PORT}" "Source APEX/ORDS"
else
  echo "INFO: SOURCE_ORDS_ENABLED=N; skip Source ORDS/APEX readiness check"
fi
if [ "${TARGET_ORDS_ENABLED}" = "Y" ]; then
  ensure_ords_ready "${TARGET_DB_CONTAINER}" "${TARGET_ORDS_PORT}" "Target APEX/ORDS"
else
  echo "INFO: TARGET_ORDS_ENABLED=N; skip Target ORDS/APEX readiness check"
fi

# 11. Let the OGG container's own startup script bring GoldenGate services back.
# Process-level RUNNING/LAG/heartbeat checks are then done from the integrated
# Console, which becomes the natural resume point for the next book exercise.
if docker exec "${OGG_CONTAINER}" test -x /home/oracle/startOGG.sh >/dev/null 2>&1; then
  docker exec "${OGG_CONTAINER}" /home/oracle/startOGG.sh || true
else
  echo "INFO: ${OGG_CONTAINER}: no /home/oracle/startOGG.sh; container entrypoint manages GoldenGate services"
fi

echo "INFO: OSA/GGSA is not started by startDocker.sh."
echo "INFO: Run bash startOSA.sh only when you begin the Stream Analytics labs."
echo "INFO: OCI AI worker timers are not started by startDocker.sh."
echo "INFO: Run sh startAIWorkers.sh only when you begin the OCI AI/APEX labs."
echo "INFO: Lakehouse/Iceberg is not started by startDocker.sh."
echo "INFO: Run sh startLakehouse.sh only when you begin the Lakehouse/Iceberg labs."
