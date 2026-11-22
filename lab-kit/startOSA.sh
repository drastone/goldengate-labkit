#!/usr/bin/env bash
set -eu

# Start OSA/GGSA only when the Stream Analytics labs need it.
# Keep this separate from startDocker.sh so ordinary CDC/Kafka labs do not
# spend laptop memory on Spark and OSA background processes.

LAB_HOME="${LAB_HOME:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
HELPER_DIR="${HELPER_DIR:-${LAB_HOME}/troubleshooting/scripts}"
HOST_STORAGE_CHECK="${HOST_STORAGE_CHECK:-${HELPER_DIR}/check_host_storage.sh}"
OSA_CONTAINER="${OSA_CONTAINER:-demo_centos}"
OSA_DB_CONTAINER="${OSA_DB_CONTAINER:-demo_osrc_23ai}"
OSA_DB_SERVICE="${OSA_DB_SERVICE:-ORCLPDB1}"
OSA_SETUP_SCRIPT="${OSA_SETUP_SCRIPT:-${LAB_HOME}/centos/setup_osa26.sh}"
TARGET_DB_CONTAINER="${TARGET_DB_CONTAINER:-demo_otrg_23ai}"
OGGHUB_CONTAINER="${OGGHUB_CONTAINER:-demo_ogg_23ai}"
TARGET_REPLICAT_NAME="${TARGET_REPLICAT_NAME:-D01}"
# The reader-size OSA profile always reserves Target DB memory for Spark/OSA.
# Keep the OSA metadata/reference connection on the Source DB and stop Target.
STOP_TARGET_FOR_OSA=Y
STOP_OPTIONAL_FOR_OSA="${STOP_OPTIONAL_FOR_OSA:-Y}"
OSA_OPTIONAL_CONTAINERS="${OSA_OPTIONAL_CONTAINERS:-demo_minio demo_iceberg_catalog demo_trino demo_kafka_iceberg_writer demo_iceberg_writer demo_gold_dashboard demo_mysql demo_myheat}"
OSA_BASE="${OSA_BASE:-/home/oracle/osa/osa-base}"
OSA_BIN="${OSA_BIN:-${OSA_BASE}/bin}"
SPARK_HOME="${SPARK_HOME:-/home/oracle/spark}"
SPARK_WORKER_INSTANCES="${SPARK_WORKER_INSTANCES:-2}"
SPARK_WORKER_CORES="${SPARK_WORKER_CORES:-6}"
SPARK_WORKER_MEMORY="${SPARK_WORKER_MEMORY:-7g}"
OSA_SPARK_STARTUP_TIMEOUT_MS="${OSA_SPARK_STARTUP_TIMEOUT_MS:-300000}"
OSA_SPARK_FILESHARE_PATH="${OSA_SPARK_FILESHARE_PATH:-/home/oracle/osatmp}"
OSA_PASSWORD="${OSA_PASSWORD:-WElcome1234##}"
OSA_ADMIN_USER="${OSA_ADMIN_USER:-osaadmin}"
OSA_ADMIN_PASSWORD="${OSA_ADMIN_PASSWORD:-${OSA_PASSWORD}}"
OGGBD_CONTAINER="${OGGBD_CONTAINER:-demo_oggbd_23ai}"
KAFKA_REPLICAT_NAME="${KAFKA_REPLICAT_NAME:-KAF01}"
KAFKA_HOME="${KAFKA_HOME:-/usr/local/kafka}"
KAFKA_BOOTSTRAP_SERVER="${KAFKA_BOOTSTRAP_SERVER:-localhost:9092}"
KAFKA_LOG_DIR="${KAFKA_LOG_DIR:-/usr/local/kafka/logs}"
ZOOKEEPER_DATA_DIR="${ZOOKEEPER_DATA_DIR:-/tmp/zookeeper}"
OSA_KAFKA_SELF_HEAL="${OSA_KAFKA_SELF_HEAL:-Y}"
OSA_KAFKA_PROBE_TOPIC="${OSA_KAFKA_PROBE_TOPIC:-__osa_self_heal_probe}"
OSA_SPATIAL_MAP_PATCH="${OSA_SPATIAL_MAP_PATCH:-${LAB_HOME}/centos/osa_milestone_current/vizChart/SpatialMap.js}"
OSA_SPATIAL_MAP_TARGET="${OSA_SPATIAL_MAP_TARGET:-${OSA_BASE}/ui/osa/features/visualization/components/vizChart/SpatialMap.js}"
OSA_SPATIAL_MAP_ORIGINAL_SHA256="${OSA_SPATIAL_MAP_ORIGINAL_SHA256:-d50b5b03f8fca664447f0cdbe28e9c1340abb2ada33960d20e2ea1e775e59ab3}"
OSA_SPATIAL_MAP_PATCHED_SHA256="${OSA_SPATIAL_MAP_PATCHED_SHA256:-5d7d0af151e54be65aa99f3cd52207cec4994eecf7339f91bdba18c9a00d5723}"
OSA_SPATIAL_BUNDLE_PATCHER="${OSA_SPATIAL_BUNDLE_PATCHER:-${LAB_HOME}/centos/patch_osa_spatial_bundle.py}"
OSA_SPATIAL_BUNDLE_TARGET="${OSA_SPATIAL_BUNDLE_TARGET:-${OSA_BASE}/ui/osa/bundle.js}"
OSA_SPATIAL_BUNDLE_ORIGINAL_SHA256="${OSA_SPATIAL_BUNDLE_ORIGINAL_SHA256:-dd38791b1dac5f68e7a77e43b9533437e0b8891ef9d05721494a5c4a6b03f5f7}"
OSA_SPATIAL_BUNDLE_PATCHED_SHA256="${OSA_SPATIAL_BUNDLE_PATCHED_SHA256:-130e47692e5dc08901e04526cc9f8e2397be4e2c71994ac1bfb4d74abea05cd1}"
OSA_PIE_3D_PATCHER="${OSA_PIE_3D_PATCHER:-${LAB_HOME}/centos/patch_osa_pie_3d.py}"
OSA_PIE_PROPERTIES_TARGET="${OSA_PIE_PROPERTIES_TARGET:-${OSA_BASE}/ui/osa/features/visualization/components/chartProperties/PieChartProperties.js}"
OSA_PIE_MODEL_TARGET="${OSA_PIE_MODEL_TARGET:-${OSA_BASE}/ui/osa/features/visualization/models/charts/PieChart.js}"
OSA_CHART_RENDERER_TARGET="${OSA_CHART_RENDERER_TARGET:-${OSA_BASE}/ui/osa/features/visualization/components/vizChart/VizChart.js}"
WAIT_SECONDS="${WAIT_SECONDS:-180}"


run_storage_preflight() {
  if [ ! -x "${HOST_STORAGE_CHECK}" ]; then
    echo "ERROR: storage preflight helper not found: ${HOST_STORAGE_CHECK}"
    exit 1
  fi

  echo "==> OSA/GGSA storage preflight"
  if ! LAB_STORAGE_START_SCRIPT=startOSA.sh \
       LAB_STORAGE_START_COMMAND="bash startOSA.sh" \
       "${HOST_STORAGE_CHECK}"; then
    echo "ERROR: OSA/GGSA startup is on hold until host storage is available."
    exit 1
  fi
}

require_container() {
  if ! docker inspect "${OSA_CONTAINER}" >/dev/null 2>&1; then
    echo "ERROR: container not found: ${OSA_CONTAINER}"
    exit 1
  fi
}

ensure_osa_log_error_helper() {
  logger_file="${OSA_BIN}/logger_util.sh"
  if docker exec "${OSA_CONTAINER}" grep -Eq '^(function[[:space:]]+)?logError[[:space:]]*\(\)' "${logger_file}" 2>/dev/null; then
    return
  fi

  echo "==> Repair OSA vendor logError helper"
  docker exec -u root "${OSA_CONTAINER}" bash -lc "
    set -eu
    logger='${logger_file}'
    test -f \"\${logger}\"
    if ! grep -Eq '^(function[[:space:]]+)?logError[[:space:]]*\(\)' \"\${logger}\"; then
      printf '%s\n' \
        '' \
        'function logError() {' \
        '    echo \"\$(ts) ERROR: \$*\" 1>&2' \
        '}' >> \"\${logger}\"
    fi
  "
  docker exec "${OSA_CONTAINER}" grep -Eq '^(function[[:space:]]+)?logError[[:space:]]*\(\)' "${logger_file}"
  echo "OK: OSA vendor logError helper is available."
}

require_running_container() {
  container="$1"
  if ! docker inspect "${container}" >/dev/null 2>&1; then
    echo "ERROR: container not found: ${container}"
    exit 1
  fi
  if [ "$(docker inspect -f '{{.State.Running}}' "${container}" 2>/dev/null)" != "true" ]; then
    echo "ERROR: required container is not running: ${container}"
    echo "INFO: Run bash startDocker.sh before bash startOSA.sh."
    exit 1
  fi
}

exec_oracle() {
  docker exec -u oracle "${OSA_CONTAINER}" bash -lc "$*"
}

exec_root() {
  docker exec "${OSA_CONTAINER}" bash -lc "$*"
}

is_yes() {
  case "${1:-}" in
    1|Y|y|YES|yes|TRUE|true|ON|on) return 0 ;;
    *) return 1 ;;
  esac
}

reconcile_spatial_map_focus() {
  if [ ! -f "${OSA_SPATIAL_MAP_PATCH}" ]; then
    echo "WARN: OSA Geo Spatial Seoul-focus patch not found: ${OSA_SPATIAL_MAP_PATCH}"
    return 0
  fi

  if ! grep -qF 'center:[126.978,37.5665],zoom:10' "${OSA_SPATIAL_MAP_PATCH}"; then
    echo "ERROR: invalid OSA Geo Spatial Seoul-focus patch: ${OSA_SPATIAL_MAP_PATCH}"
    return 1
  fi
  if grep -qF 'o.default.setCenterAndZoomWithPlaces(y,t)' "${OSA_SPATIAL_MAP_PATCH}"; then
    echo "ERROR: OSA Geo Spatial patch still contains the data-driven auto-focus call."
    return 1
  fi

  if ! docker exec "${OSA_CONTAINER}" test -f "${OSA_SPATIAL_MAP_TARGET}"; then
    echo "WARN: OSA Geo Spatial runtime module not found: ${OSA_SPATIAL_MAP_TARGET}"
    return 0
  fi

  source_hash="$(sha256sum "${OSA_SPATIAL_MAP_PATCH}" | awk '{print $1}')"
  target_hash="$(docker exec "${OSA_CONTAINER}" sha256sum "${OSA_SPATIAL_MAP_TARGET}" | awk '{print $1}')"

  if [ "${target_hash}" = "${source_hash}" ]; then
    :
  elif [ "${target_hash}" != "${OSA_SPATIAL_MAP_ORIGINAL_SHA256}" ] &&
       [ "${target_hash}" != "ceb76506fc4ff6d4560221204db278355121b6d49ccae5e9e619c5374a908241" ] &&
       [ "${target_hash}" != "9b90eeab8eadaf4961754933665e0a399ec1870f755533c60ddfd30c34e74baf" ]; then
    echo "WARN: OSA Geo Spatial runtime module differs from the supported OSA 19 build; skip Seoul-focus patch."
    echo "WARN: runtime sha256=${target_hash}"
    return 0
  else
    echo "INFO: Applying OSA Geo Spatial Seoul-focus module patch."
    docker cp "${OSA_SPATIAL_MAP_PATCH}" "${OSA_CONTAINER}:/tmp/SpatialMap.js.labkit"
    docker exec "${OSA_CONTAINER}" bash -lc "
      set -eu
      backup='${OSA_SPATIAL_MAP_TARGET}.pre-seoul-focus'
      if { [ '${target_hash}' = 'ceb76506fc4ff6d4560221204db278355121b6d49ccae5e9e619c5374a908241' ] ||
           [ '${target_hash}' = '9b90eeab8eadaf4961754933665e0a399ec1870f755533c60ddfd30c34e74baf' ]; } &&
         [ -f \"\${backup}\" ]; then
        cp -p \"\${backup}\" '${OSA_SPATIAL_MAP_TARGET}'
      else
        [ -f \"\${backup}\" ] || cp -p '${OSA_SPATIAL_MAP_TARGET}' \"\${backup}\"
      fi
      install -m 0644 -o oracle -g oinstall /tmp/SpatialMap.js.labkit '${OSA_SPATIAL_MAP_TARGET}'
      rm -f /tmp/SpatialMap.js.labkit
    "

    target_hash="$(docker exec "${OSA_CONTAINER}" sha256sum "${OSA_SPATIAL_MAP_TARGET}" | awk '{print $1}')"
    if [ "${target_hash}" != "${OSA_SPATIAL_MAP_PATCHED_SHA256}" ]; then
      echo "ERROR: OSA Geo Spatial module patch verification failed."
      return 1
    fi
  fi

  if [ ! -f "${OSA_SPATIAL_BUNDLE_PATCHER}" ]; then
    echo "WARN: OSA Geo Spatial bundle patcher not found: ${OSA_SPATIAL_BUNDLE_PATCHER}"
    return 0
  fi
  if ! docker exec "${OSA_CONTAINER}" test -f "${OSA_SPATIAL_BUNDLE_TARGET}"; then
    echo "WARN: OSA UI bundle not found: ${OSA_SPATIAL_BUNDLE_TARGET}"
    return 0
  fi

  bundle_hash="$(docker exec "${OSA_CONTAINER}" sha256sum "${OSA_SPATIAL_BUNDLE_TARGET}" | awk '{print $1}')"
  if [ "${bundle_hash}" = "${OSA_SPATIAL_BUNDLE_PATCHED_SHA256}" ] ||
     { docker exec "${OSA_CONTAINER}" grep -qF 'center:[126.978,37.5665],zoom:10' "${OSA_SPATIAL_BUNDLE_TARGET}" &&
       ! docker exec "${OSA_CONTAINER}" grep -qF 'o.default.setCenterAndZoomWithPlaces(y,t)' "${OSA_SPATIAL_BUNDLE_TARGET}"; }; then
    echo "OK: OSA Geo Spatial map focus is set to Seoul."
    return 0
  fi
  if [ "${bundle_hash}" != "${OSA_SPATIAL_BUNDLE_ORIGINAL_SHA256}" ] &&
     [ "${bundle_hash}" != "358b76c7c24b8041cd8f1d3b4c221c0a1d753fd1efd1e5524d3dd209ccc248d6" ] &&
     [ "${bundle_hash}" != "43fe16235b9154873b555e12b58b35537f0615050bd009f098c80c452d073cc0" ]; then
    echo "WARN: OSA UI bundle differs from the supported OSA 19 build; skip Seoul-focus bundle patch."
    echo "WARN: bundle sha256=${bundle_hash}"
    return 0
  fi

  bundle_temp="$(mktemp /tmp/osa-bundle.XXXXXX.js)"
  if [ "${bundle_hash}" = "358b76c7c24b8041cd8f1d3b4c221c0a1d753fd1efd1e5524d3dd209ccc248d6" ] ||
     [ "${bundle_hash}" = "43fe16235b9154873b555e12b58b35537f0615050bd009f098c80c452d073cc0" ]; then
    docker cp "${OSA_CONTAINER}:${OSA_SPATIAL_BUNDLE_TARGET}.pre-seoul-focus" "${bundle_temp}"
  else
    docker cp "${OSA_CONTAINER}:${OSA_SPATIAL_BUNDLE_TARGET}" "${bundle_temp}"
  fi
  if ! python3 "${OSA_SPATIAL_BUNDLE_PATCHER}" "${bundle_temp}" >/dev/null; then
    rm -f "${bundle_temp}"
    echo "ERROR: OSA Geo Spatial bundle patch failed."
    return 1
  fi

  echo "INFO: Applying OSA Geo Spatial Seoul-focus bundle patch."
  docker cp "${bundle_temp}" "${OSA_CONTAINER}:/tmp/osa-bundle.labkit.js"
  rm -f "${bundle_temp}"
  docker exec "${OSA_CONTAINER}" bash -lc "
    set -eu
    backup='${OSA_SPATIAL_BUNDLE_TARGET}.pre-seoul-focus'
    [ -f \"\${backup}\" ] || cp -p '${OSA_SPATIAL_BUNDLE_TARGET}' \"\${backup}\"
    install -m 0644 -o oracle -g oinstall /tmp/osa-bundle.labkit.js '${OSA_SPATIAL_BUNDLE_TARGET}'
    rm -f /tmp/osa-bundle.labkit.js
  "

  bundle_hash="$(docker exec "${OSA_CONTAINER}" sha256sum "${OSA_SPATIAL_BUNDLE_TARGET}" | awk '{print $1}')"
  if [ "${bundle_hash}" != "${OSA_SPATIAL_BUNDLE_PATCHED_SHA256}" ]; then
    echo "ERROR: OSA Geo Spatial bundle patch verification failed."
    return 1
  fi
  echo "OK: OSA Geo Spatial map focus is set to Seoul."
}

patch_osa_pie_3d_file() {
  target="$1"
  label="$2"

  if ! docker exec "${OSA_CONTAINER}" test -f "${target}"; then
    echo "WARN: OSA ${label} file not found: ${target}"
    return 0
  fi

  temp_dir="$(mktemp -d /tmp/osa-pie-3d.XXXXXX)"
  temp_file="${temp_dir}/$(basename "${target}")"
  docker cp "${OSA_CONTAINER}:${target}" "${temp_file}"
  if ! patch_result="$(python3 "${OSA_PIE_3D_PATCHER}" "${temp_file}" 2>&1)"; then
    rm -f "${temp_file}"
    rmdir "${temp_dir}"
    echo "WARN: Cannot restore the OSA Pie 3D option in ${label}; keep the vendor file unchanged."
    echo "WARN: ${patch_result}"
    return 0
  fi

  if [ "${patch_result}" = "already-patched" ]; then
    rm -f "${temp_file}"
    rmdir "${temp_dir}"
    return 0
  fi

  container_temp="/tmp/$(basename "${target}").pie-3d.labkit"
  docker cp "${temp_file}" "${OSA_CONTAINER}:${container_temp}"
  rm -f "${temp_file}"
  rmdir "${temp_dir}"
  docker exec "${OSA_CONTAINER}" bash -lc "
    set -eu
    backup='${target}.pre-pie-3d'
    [ -f \"\${backup}\" ] || cp -p '${target}' \"\${backup}\"
    install -m 0644 -o oracle -g oinstall '${container_temp}' '${target}'
    rm -f '${container_temp}'
  "
}

reconcile_pie_3d_option() {
  if [ ! -f "${OSA_PIE_3D_PATCHER}" ]; then
    echo "WARN: OSA Pie 3D patcher not found: ${OSA_PIE_3D_PATCHER}"
    return 0
  fi

  patch_osa_pie_3d_file "${OSA_PIE_PROPERTIES_TARGET}" "Pie chart properties"
  patch_osa_pie_3d_file "${OSA_PIE_MODEL_TARGET}" "Pie chart model"
  patch_osa_pie_3d_file "${OSA_CHART_RENDERER_TARGET}" "chart renderer"
  patch_osa_pie_3d_file "${OSA_SPATIAL_BUNDLE_TARGET}" "UI bundle"

  if docker exec "${OSA_CONTAINER}" grep -qF 'Use 3D rendering' "${OSA_SPATIAL_BUNDLE_TARGET}" &&
     docker exec "${OSA_CONTAINER}" grep -qF 'threeDEffect:e.userSpecifiedProperties.threed' "${OSA_SPATIAL_BUNDLE_TARGET}" &&
     docker exec "${OSA_CONTAINER}" grep -qF 'styleDefaults:p.styleDefaults' "${OSA_SPATIAL_BUNDLE_TARGET}"; then
    echo "OK: OSA Pie visualization 3D option is available."
  else
    echo "WARN: OSA Pie visualization 3D option could not be verified."
  fi
}

ensure_osa_metadata() {
  if docker exec -i "${OSA_DB_CONTAINER}" bash -lc 'sqlplus -s "/ as sysdba"' <<SQL | grep -q '^OSA_READY$'
set heading off feedback off pages 0 verify off echo off
alter session set container=${OSA_DB_SERVICE};
select case
         when exists (select 1 from dba_users where username = 'OSA')
          and exists (select 1 from dba_tables where owner = 'OSA' and table_name = 'OSA_SYSTEM_PROPERTY')
         then 'OSA_READY'
         else 'OSA_NOT_READY'
       end
  from dual;
exit;
SQL
  then
    echo "INFO: OSA metadata is ready in ${OSA_DB_CONTAINER}/${OSA_DB_SERVICE}."
    return 0
  fi

  if [ ! -f "${OSA_SETUP_SCRIPT}" ]; then
    echo "ERROR: OSA metadata is not ready and setup script was not found: ${OSA_SETUP_SCRIPT}"
    exit 1
  fi

  echo "==> Initialize OSA metadata in ${OSA_DB_CONTAINER}/${OSA_DB_SERVICE}"
  OSA_DB_CONTAINER="${OSA_DB_CONTAINER}" START_OSA=N bash "${OSA_SETUP_SCRIPT}"
}

stop_optional_for_osa_if_needed() {
  if ! is_yes "${STOP_OPTIONAL_FOR_OSA}"; then
    echo "INFO: STOP_OPTIONAL_FOR_OSA=${STOP_OPTIONAL_FOR_OSA}; keep optional containers unchanged."
    return 0
  fi

  echo "==> Stop optional containers not required by OSA/GGSA"
  for container in ${OSA_OPTIONAL_CONTAINERS}; do
    if ! docker inspect "${container}" >/dev/null 2>&1; then
      continue
    fi
    if [ "$(docker inspect -f '{{.State.Running}}' "${container}" 2>/dev/null)" = "true" ]; then
      echo "Stopping ${container}"
      docker stop "${container}" >/dev/null
    fi
  done
}

stop_target_for_osa_if_needed() {
  if [ "${TARGET_DB_CONTAINER}" = "${OSA_DB_CONTAINER}" ]; then
    echo "ERROR: OSA_DB_CONTAINER must not be the Target DB in the reader OSA profile."
    echo "INFO: use ${OSA_DB_CONTAINER} for OSA and keep ${TARGET_DB_CONTAINER} stopped."
    exit 1
  fi

  if docker inspect "${OGGHUB_CONTAINER}" >/dev/null 2>&1 \
     && [ "$(docker inspect -f '{{.State.Running}}' "${OGGHUB_CONTAINER}" 2>/dev/null)" = "true" ]; then
    echo "==> Stop ${TARGET_REPLICAT_NAME} before stopping ${TARGET_DB_CONTAINER}"
    docker exec -i "${OGGHUB_CONTAINER}" python3 - "${TARGET_REPLICAT_NAME}" <<'PY' || true
import json
import sys
import urllib.parse
import urllib.request

name = sys.argv[1].upper()

def admin(command):
    url = "http://127.0.0.1:8765/api/adminclient?cmd=" + urllib.parse.quote(command)
    with urllib.request.urlopen(url, timeout=60) as response:
        return json.loads(response.read().decode()).get("output", "")

try:
    info = admin("info all")
    line = next((row for row in info.splitlines() if "REPLICAT" in row and name in row), "")
    if "RUNNING" in line:
        print(admin("stop " + name))
    elif line:
        print(f"INFO: {name} is already {line.split()[1]}.")
    else:
        print(f"INFO: {name} was not found; continue with OSA resource mode.")
except Exception as exc:
    print(f"WARN: could not stop {name} gracefully: {exc}")
PY
  fi

  if ! docker inspect "${TARGET_DB_CONTAINER}" >/dev/null 2>&1; then
    echo "INFO: target DB container not found: ${TARGET_DB_CONTAINER}; skip target stop."
    return 0
  fi

  if [ "$(docker inspect -f '{{.State.Running}}' "${TARGET_DB_CONTAINER}" 2>/dev/null)" = "true" ]; then
    echo "==> Stop ${TARGET_DB_CONTAINER} to reserve CPU/memory for OSA/GGSA"
    docker stop "${TARGET_DB_CONTAINER}" >/dev/null
  else
    echo "INFO: ${TARGET_DB_CONTAINER} is already stopped."
  fi
}

verify_target_stopped_for_osa() {
  if docker inspect "${TARGET_DB_CONTAINER}" >/dev/null 2>&1 \
     && [ "$(docker inspect -f '{{.State.Running}}' "${TARGET_DB_CONTAINER}" 2>/dev/null)" = "true" ]; then
    echo "ERROR: ${TARGET_DB_CONTAINER} is still running after OSA resource preparation."
    exit 1
  fi
  echo "OK: ${TARGET_DB_CONTAINER} is stopped; its memory is reserved for OSA/Spark."
}

wait_for_osa() {
  echo "==> Wait for OSA HTTPS listener on ${OSA_CONTAINER}:9443"
  docker exec "${OSA_CONTAINER}" bash -lc "
    end=\$((SECONDS + ${WAIT_SECONDS}))
    while [ \${SECONDS} -lt \${end} ]; do
      if command -v ss >/dev/null 2>&1; then
        ss -ltn | grep -q ':9443 ' && exit 0
      elif command -v netstat >/dev/null 2>&1; then
        netstat -ltn | grep -q ':9443 ' && exit 0
      fi
      sleep 2
    done
    exit 1
  " || {
    echo "ERROR: OSA HTTPS listener did not open within ${WAIT_SECONDS} seconds."
    echo "INFO: Check ${OSA_CONTAINER}:${OSA_BASE}/logs/osa-startup-manual.log"
    exit 1
  }
}

heal_kafka_if_needed() {
  if ! is_yes "${OSA_KAFKA_SELF_HEAL}"; then
    echo "INFO: Kafka self-healing is disabled (OSA_KAFKA_SELF_HEAL=${OSA_KAFKA_SELF_HEAL})."
    return 0
  fi

  echo "==> Check Kafka health for OSA/GGSA"
  exec_root "
    set -u
    KAFKA_HOME='${KAFKA_HOME}'
    BOOTSTRAP_SERVER='${KAFKA_BOOTSTRAP_SERVER}'
    PROBE_TOPIC='${OSA_KAFKA_PROBE_TOPIC}'
    KAFKA_LOG_DIR='${KAFKA_LOG_DIR}'
    ZOOKEEPER_DATA_DIR='${ZOOKEEPER_DATA_DIR}'

    start_zookeeper() {
      if ss -ltn 2>/dev/null | grep -q ':2181 '; then
        return 0
      fi
      if [ -x /usr/local/zookeeper/bin/zkServer.sh ]; then
        /usr/local/zookeeper/bin/zkServer.sh start /usr/local/zookeeper/conf/zoo.cfg >/tmp/osa-start-zookeeper.log 2>&1 || true
      fi
      for i in \$(seq 1 20); do
        timeout 1 bash -lc '</dev/tcp/127.0.0.1/2181' >/dev/null 2>&1 && return 0
        sleep 1
      done
      return 1
    }

    start_kafka() {
      if ss -ltn 2>/dev/null | grep -q ':9092 '; then
        return 0
      fi
      if [ -x \"\${KAFKA_HOME}/bin/kafka-server-start.sh\" ]; then
        KAFKA_HEAP_OPTS=\"\${KAFKA_HEAP_OPTS:--Xms500m -Xmx500m}\" \
          \"\${KAFKA_HOME}/bin/kafka-server-start.sh\" -daemon \"\${KAFKA_HOME}/config/server.properties\" \
          >/tmp/osa-start-kafka.log 2>&1 || true
      fi
      for i in \$(seq 1 30); do
        timeout 1 bash -lc '</dev/tcp/127.0.0.1/9092' >/dev/null 2>&1 && return 0
        sleep 1
      done
      return 1
    }

    kafka_probe() {
      [ -x \"\${KAFKA_HOME}/bin/kafka-topics.sh\" ] || return 1
      [ -x \"\${KAFKA_HOME}/bin/kafka-console-producer.sh\" ] || return 1
      [ -x \"\${KAFKA_HOME}/bin/kafka-console-consumer.sh\" ] || return 1

      \"\${KAFKA_HOME}/bin/kafka-topics.sh\" --bootstrap-server \"\${BOOTSTRAP_SERVER}\" \
        --create --if-not-exists --topic \"\${PROBE_TOPIC}\" --partitions 1 --replication-factor 1 \
        >/tmp/osa-kafka-probe-create.log 2>&1 || return 1

      msg=\"osa-self-heal-\$(date +%s)-\$\$\"
      printf '%s\n' \"\${msg}\" \
        | timeout 10 \"\${KAFKA_HOME}/bin/kafka-console-producer.sh\" \
            --bootstrap-server \"\${BOOTSTRAP_SERVER}\" --topic \"\${PROBE_TOPIC}\" \
          >/tmp/osa-kafka-probe-producer.log 2>&1 || return 1

      timeout 12 \"\${KAFKA_HOME}/bin/kafka-console-consumer.sh\" \
        --bootstrap-server \"\${BOOTSTRAP_SERVER}\" \
        --topic \"\${PROBE_TOPIC}\" \
        --from-beginning \
        --max-messages 1 \
        --timeout-ms 7000 \
        >/tmp/osa-kafka-probe-consumer.log 2>&1 || return 1

      return 0
    }

    kafka_logs_show_corruption() {
      find \"\${KAFKA_LOG_DIR}\" /tmp -maxdepth 1 -type f \
        \( -name '*.log' -o -name 'osa-kafka-probe-*.log' \) -mmin -10 \
        -exec grep -qiE 'Topic ID in memory|NOT_LEADER_OR_FOLLOWER|NotLeaderOrFollowerException|NOT_COORDINATOR|NotCoordinatorException' {} \; \
        -print -quit 2>/dev/null | grep -q .
    }

    stop_kafka_and_zookeeper() {
      if [ -x \"\${KAFKA_HOME}/bin/kafka-server-stop.sh\" ]; then
        \"\${KAFKA_HOME}/bin/kafka-server-stop.sh\" >/tmp/osa-stop-kafka.log 2>&1 || true
      fi
      sleep 5

      kafka_pids=\$(ps -eo pid=,args= | awk '/kafka\\.Kafka/ && !/awk/ {print \$1}')
      if [ -n \"\${kafka_pids}\" ]; then
        echo \"Kafka PIDs: \${kafka_pids}\"
        kill \${kafka_pids} 2>/dev/null || true
        sleep 3
      fi

      if [ -x /usr/local/zookeeper/bin/zkServer.sh ]; then
        /usr/local/zookeeper/bin/zkServer.sh stop /usr/local/zookeeper/conf/zoo.cfg >/tmp/osa-stop-zookeeper.log 2>&1 || true
      fi
      sleep 3

      zk_pids=\$(ps -eo pid=,args= | awk '/QuorumPeerMain|org\\.apache\\.zookeeper\\.server/ && !/awk/ {print \$1}')
      if [ -n \"\${zk_pids}\" ]; then
        echo \"ZooKeeper PIDs: \${zk_pids}\"
        kill \${zk_pids} 2>/dev/null || true
        sleep 2
      fi
    }

    reset_kafka_state() {
      ts=\$(date +%Y%m%d_%H%M%S)
      backup_dir=/root/kafka-reset-backup
      mkdir -p \"\${backup_dir}\"
      echo \"WARN: Reset Kafka/ZooKeeper lab state after backing it up under \${backup_dir}.\"
      [ -d \"\${KAFKA_LOG_DIR}\" ] && mv \"\${KAFKA_LOG_DIR}\" \"\${backup_dir}/kafka-logs-\${ts}\"
      [ -d \"\${ZOOKEEPER_DATA_DIR}\" ] && mv \"\${ZOOKEEPER_DATA_DIR}\" \"\${backup_dir}/zookeeper-\${ts}\"
      mkdir -p \"\${KAFKA_LOG_DIR}\" \"\${ZOOKEEPER_DATA_DIR}\"
    }

    if start_zookeeper && start_kafka && kafka_probe && ! kafka_logs_show_corruption; then
      echo 'Kafka health check passed.'
      exit 0
    fi

    echo 'WARN: Kafka health check detected a stale/corrupted lab state.'
    echo 'WARN: This usually follows WSL shutdown, forced container stop, or interrupted OSA/Kafka runs.'
    stop_kafka_and_zookeeper
    reset_kafka_state
    start_zookeeper || { echo 'ERROR: ZooKeeper did not restart after Kafka self-heal.'; exit 1; }
    start_kafka || { echo 'ERROR: Kafka did not restart after Kafka self-heal.'; exit 1; }
    kafka_probe || { echo 'ERROR: Kafka probe still failed after Kafka self-heal.'; exit 1; }
    echo 'Kafka self-healing completed.'
  "
}

ensure_kafka_replicat_running() {
  if ! docker inspect "${OGGBD_CONTAINER}" >/dev/null 2>&1; then
    echo "INFO: ${OGGBD_CONTAINER} not found; skip ${KAFKA_REPLICAT_NAME} self-heal."
    return 0
  fi

  echo "==> Ensure ${KAFKA_REPLICAT_NAME} Replicat is running"
  docker exec -i -u ogg "${OGGBD_CONTAINER}" python3 - "${KAFKA_REPLICAT_NAME}" <<'PY' || {
import json
import sys
import time
import urllib.parse
import urllib.request

replicat = sys.argv[1].upper()

def admin(cmd):
    url = "http://localhost:8765/api/adminclient?cmd=" + urllib.parse.quote(cmd)
    raw = urllib.request.urlopen(url, timeout=60).read().decode()
    try:
        payload = json.loads(raw)
    except json.JSONDecodeError:
        return raw

    output = payload.get("output")
    if isinstance(output, str):
        return output

    response = payload.get("response")
    if isinstance(response, dict) and isinstance(response.get("reply"), str):
        return response["reply"]
    return raw

def status():
    info = admin("info all")
    for row in info.splitlines():
        fields = row.split()
        if len(fields) >= 3 and fields[0] == "REPLICAT" and fields[2].upper() == replicat:
            return fields[1].upper()
    return "NOT_FOUND"

try:
    current = status()
except Exception as exc:
    print(f"WARN: OGG API is not ready; skip {replicat} self-heal: {exc}")
    sys.exit(0)

if current == "RUNNING":
    print(f"OK: {replicat} is already RUNNING.")
    sys.exit(0)

if current == "NOT_FOUND":
    print(f"WARN: {replicat} was not found; skip Replicat start.")
    sys.exit(0)

print(f"INFO: {replicat} status is {current}; starting it.")
try:
    admin(f"start {replicat}")
    for _ in range(15):
        time.sleep(2)
        current = status()
        if current == "RUNNING":
            print(f"OK: {replicat} is RUNNING.")
            sys.exit(0)
except Exception as exc:
    print(f"WARN: could not start {replicat}: {exc}")
    sys.exit(1)

print(f"WARN: {replicat} did not reach RUNNING state (status={current}).")
sys.exit(1)
PY
    echo "WARN: unable to verify/start ${KAFKA_REPLICAT_NAME}; continue OSA startup."
  }
}

stop_stale_osa_main_processes() {
  echo "==> Stop stale OSA/GGSA Java processes before restart"
  exec_root "
    set -u
    pids=\$( {
      ps -eo pid=,args= | awk '/oracle\\.cloud\\.osa\\.Main/ && !/awk/ {print \$1}'
      command -v jps >/dev/null 2>&1 && jps -lm 2>/dev/null | awk '/oracle\\.cloud\\.osa\\.Main/ {print \$1}'
    } | sort -u )
    live_pids=''
    zombie_pids=''
    for pid in \${pids}; do
      state=\$(awk '/^State:/ {print \$2}' \"/proc/\${pid}/status\" 2>/dev/null || true)
      if [ \"\${state}\" = 'Z' ]; then
        zombie_pids=\"\${zombie_pids} \${pid}\"
      elif [ -n \"\${state}\" ]; then
        live_pids=\"\${live_pids} \${pid}\"
      fi
    done
    [ -z \"\${zombie_pids}\" ] || echo \"Ignore zombie OSA/GGSA pids:\${zombie_pids}\"
    pids=\"\${live_pids}\"
    if [ -z \"\${pids}\" ]; then
      echo 'No stale OSA/GGSA Java process found.'
      exit 0
    fi

    echo \"TERM OSA/GGSA pids: \${pids}\"
    kill \${pids} 2>/dev/null || true
    sleep 5

    pids=\$( {
      ps -eo pid=,args= | awk '/oracle\\.cloud\\.osa\\.Main/ && !/awk/ {print \$1}'
      command -v jps >/dev/null 2>&1 && jps -lm 2>/dev/null | awk '/oracle\\.cloud\\.osa\\.Main/ {print \$1}'
    } | sort -u )
    live_pids=''
    for pid in \${pids}; do
      state=\$(awk '/^State:/ {print \$2}' \"/proc/\${pid}/status\" 2>/dev/null || true)
      [ \"\${state}\" = 'Z' ] || [ -z \"\${state}\" ] || live_pids=\"\${live_pids} \${pid}\"
    done
    pids=\"\${live_pids}\"
    if [ -n \"\${pids}\" ]; then
      echo \"KILL OSA/GGSA pids: \${pids}\"
      kill -KILL \${pids} 2>/dev/null || true
      sleep 2
    fi
  "
}

run_storage_preflight
require_container
ensure_osa_log_error_helper
require_running_container "${OSA_DB_CONTAINER}"
ensure_osa_metadata
stop_optional_for_osa_if_needed
stop_target_for_osa_if_needed
verify_target_stopped_for_osa

echo "Start OSA/GGSA runtime"
echo "Container : ${OSA_CONTAINER}"
echo "OSA DB    : ${OSA_DB_CONTAINER}/${OSA_DB_SERVICE}"
echo "Target DB : ${TARGET_DB_CONTAINER} (STOP_TARGET_FOR_OSA=${STOP_TARGET_FOR_OSA})"
echo "URL       : https://localhost:39443/osa/index.html"

heal_kafka_if_needed
ensure_kafka_replicat_running

echo "==> Heal OSA/Spark stale PID files if needed"
exec_oracle "
  set -eu
  heal_pid_file() {
    pid_file=\"\$1\"
    expected_pattern=\"\$2\"
    label=\"\$3\"
    [ -f \"\${pid_file}\" ] || return 0

    pid=\$(cat \"\${pid_file}\" 2>/dev/null || true)
    stat=\$(ps -o stat= -p \"\${pid}\" 2>/dev/null | tr -d ' ' || true)
    args=\$(ps -o args= -p \"\${pid}\" 2>/dev/null || true)

    if [ -n \"\${pid}\" ] && [ -n \"\${stat}\" ] && ! echo \"\${stat}\" | grep -q 'Z' && echo \"\${args}\" | grep -q \"\${expected_pattern}\"; then
      echo \"\${label} is already running with PID \${pid}.\"
      return 0
    fi

    backup=\"\${pid_file}.stale-\$(date +%Y%m%d%H%M%S)\"
    echo \"Moving stale \${label} PID file to \${backup} (pid=\${pid:-empty}, stat=\${stat:-none}, args=\${args:-none})\"
    mv \"\${pid_file}\" \"\${backup}\"
  }

  heal_pid_file '${OSA_BASE}/osa.pid' 'oracle.cloud.osa.Main' 'OSA/GGSA'
  heal_pid_file '/tmp/spark-oracle-org.apache.spark.deploy.master.Master-1.pid' 'org.apache.spark.deploy.master.Master' 'Spark master'
  heal_pid_file '/tmp/spark-oracle-org.apache.spark.deploy.worker.Worker-1.pid' 'org.apache.spark.deploy.worker.Worker' 'Spark worker'
  heal_pid_file '/tmp/spark-oracle-org.apache.spark.deploy.history.HistoryServer-1.pid' 'org.apache.spark.deploy.history.HistoryServer' 'Spark history server'
"

stop_stale_osa_main_processes

echo "==> Reconcile Spark configuration for OSA/GGSA"
exec_root "
  set -eu
  mkdir -p '${OSA_SPARK_FILESHARE_PATH}'
  chown oracle:oinstall '${OSA_SPARK_FILESHARE_PATH}'
  chown oracle:oinstall '${SPARK_HOME}/conf/spark-defaults.conf' '${SPARK_HOME}/conf/spark-env.sh'
  chmod u+rw '${SPARK_HOME}/conf/spark-defaults.conf' '${SPARK_HOME}/conf/spark-env.sh'
"
exec_oracle "
  set -eu
  conf='${SPARK_HOME}/conf/spark-defaults.conf'
  env='${SPARK_HOME}/conf/spark-env.sh'

  mkdir -p '${SPARK_HOME}/conf'
  touch \"\${conf}\" \"\${env}\"

  set_or_replace_property() {
    file=\"\$1\"
    key=\"\$2\"
    value=\"\$3\"
    if grep -q \"^\${key}[[:space:]]\" \"\${file}\"; then
      sed -i \"s#^\${key}[[:space:]].*#\${key} \${value}#\" \"\${file}\"
    else
      printf '%s %s\n' \"\${key}\" \"\${value}\" >> \"\${file}\"
    fi
  }

  set_or_replace_shell_var() {
    file=\"\$1\"
    key=\"\$2\"
    value=\"\$3\"
    if grep -q \"^\${key}=\" \"\${file}\"; then
      sed -i \"s#^\${key}=.*#\${key}=\${value}#\" \"\${file}\"
    else
      printf '%s=%s\n' \"\${key}\" \"\${value}\" >> \"\${file}\"
    fi
  }

  set_or_replace_property \"\${conf}\" spark.master spark://localhost:7077
  set_or_replace_property \"\${conf}\" spark.master.rest.enabled true
  set_or_replace_property \"\${conf}\" spark.master.rest.port 6066
  set_or_replace_property \"\${conf}\" spark.ui.filters oracle.osa.installer.OsaSparkAuthenticationFilter
  set_or_replace_property \"\${conf}\" spark.oracle.osa.installer.OsaSparkAuthenticationFilter.params dataSourceConfigPath=${OSA_BASE}/etc/osa-datasource.xml

  set_or_replace_shell_var \"\${env}\" SPARK_MASTER_HOST localhost
  set_or_replace_shell_var \"\${env}\" SPARK_PUBLIC_DNS 127.0.0.1
  set_or_replace_shell_var \"\${env}\" SPARK_WORKER_INSTANCES ${SPARK_WORKER_INSTANCES}
  set_or_replace_shell_var \"\${env}\" SPARK_WORKER_CORES ${SPARK_WORKER_CORES}
  set_or_replace_shell_var \"\${env}\" SPARK_WORKER_MEMORY ${SPARK_WORKER_MEMORY}
  grep -q '^export OSA_AES_KEY_PATH=' \"\${env}\" || printf '%s\n' 'export OSA_AES_KEY_PATH=${OSA_BASE}/etc/osa_aes.key' >> \"\${env}\"
  if grep -q '^SPARK_DAEMON_CLASSPATH=' \"\${env}\"; then
    sed -i \"s#^SPARK_DAEMON_CLASSPATH=.*#SPARK_DAEMON_CLASSPATH=${OSA_BASE}/bin/osa.installer.jar:${OSA_BASE}/libs/javaengine-env-19.1.3-100.jar:${OSA_BASE}/libs/osa.sparkinteg.model.jar:${OSA_BASE}/libs/ojdbc11-23.9.0.25.07.jar#\" \"\${env}\"
  else
    printf '%s\n' 'SPARK_DAEMON_CLASSPATH=${OSA_BASE}/bin/osa.installer.jar:${OSA_BASE}/libs/javaengine-env-19.1.3-100.jar:${OSA_BASE}/libs/osa.sparkinteg.model.jar:${OSA_BASE}/libs/ojdbc11-23.9.0.25.07.jar' >> \"\${env}\"
  fi

  if [ -d '${SPARK_HOME}/jars' ]; then
    ln -sfn '${OSA_BASE}/bin/osa.installer.jar' '${SPARK_HOME}/jars/osa-osa.installer.jar'
    ln -sfn '${OSA_BASE}/libs/javaengine-env-19.1.3-100.jar' '${SPARK_HOME}/jars/osa-javaengine-env-19.1.3-100.jar'
    ln -sfn '${OSA_BASE}/libs/osa.sparkinteg.model.jar' '${SPARK_HOME}/jars/osa-osa.sparkinteg.model.jar'
    ln -sfn '${OSA_BASE}/libs/ojdbc11-23.9.0.25.07.jar' '${SPARK_HOME}/jars/osa-ojdbc11-23.9.0.25.07.jar'
  fi
"

echo "==> Reconcile OSA/GGSA Spark runtime properties"
docker exec -i -u oracle "${OSA_DB_CONTAINER}" bash -lc 'sqlplus -s "/ as sysdba"' <<SQL
whenever sqlerror continue
set heading off feedback off verify off pages 0 serveroutput on
alter session set container=${OSA_DB_SERVICE};

declare
  l_count number;
begin
  select count(*)
    into l_count
    from all_tables
   where owner = 'OSA'
     and table_name = 'OSA_SYSTEM_PROPERTY';

  if l_count > 0 then
    execute immediate q'[
      merge into osa.osa_system_property p
      using (
        select 'draft.osa.spark.ha.enabled' mkey, 'false' value from dual union all
        select 'draft.spark.driver.cores', '1' from dual union all
        select 'draft.spark.driver.memory', '1500m' from dual union all
        select 'draft.spark.executor.cores', '2' from dual union all
        select 'draft.spark.executor.instances', '1' from dual union all
        select 'draft.spark.executor.memory', '1800m' from dual union all
        select 'draft.spark.k8s.driver.cores', '1000' from dual union all
        select 'draft.spark.k8s.driver.memory', '800' from dual union all
        select 'draft.spark.k8s.executor.cores', '1000' from dual union all
        select 'draft.spark.k8s.executor.memory', '500' from dual union all
        select 'osa.runtime' mkey, 'spark' value from dual union all
        select 'osa.spark.deploy.ping.period', '1000' from dual union all
        select 'osa.spark.fileshare.path', '${OSA_SPARK_FILESHARE_PATH}' from dual union all
        select 'osa.spark.fileshare.type', 'file' from dual union all
        select 'osa.spark.ha.batch.count', '1' from dual union all
        select 'osa.spark.ha.enabled', 'false' from dual union all
        select 'osa.spark.standalone.console.port', '8080' from dual union all
        select 'osa.spark.url', 'localhost:6066' from dual union all
        select 'spark.driver.cores', '1' from dual union all
        select 'spark.driver.memory', '1500' from dual union all
        select 'spark.driver.supervise', 'false' from dual union all
        select 'spark.executor.cores', '2' from dual union all
        select 'spark.executor.instances', '1' from dual union all
        select 'spark.executor.memory', '1800' from dual union all
        select 'spark.master', 'spark://localhost:7077' from dual union all
        select 'spark.master.rest.enabled', 'true' from dual union all
        select 'spark.master.rest.port', '6066' from dual union all
        select 'spark.submit.deploy.mode', 'cluster' from dual union all
        select 'spark.executor.startup.timeout', '${OSA_SPARK_STARTUP_TIMEOUT_MS}' from dual union all
        select 'osa.spark.deploy.timeout', '${OSA_SPARK_STARTUP_TIMEOUT_MS}' from dual union all
        select 'spark.history.connect.timeout.ms', '5000' from dual union all
        select 'spark.history.read.timeout.ms', '15000' from dual union all
        select 'spark.k8s.driver.cores', '1000' from dual union all
        select 'spark.k8s.driver.memory', '800' from dual union all
        select 'spark.k8s.executor.cores', '1000' from dual union all
        select 'spark.k8s.executor.memory', '500' from dual union all
        select 'spark.k8s.pod.log.size', '500000' from dual union all
        select 'spark.log.level', 'ERROR' from dual union all
        select 'spark.oracle.osa.installer.osa.spark.authentication.filter.params',
               'dataSourceConfigPath=${OSA_BASE}/etc/osa-datasource.xml' from dual union all
        select 'spark.streaming.batchDuration', '1000' from dual union all
        select 'spark.streaming.partition.factor', '1.0' from dual union all
        select 'spark.ui.filters', 'oracle.osa.installer.OsaSparkAuthenticationFilter' from dual union all
        select 'spark.yarn.max.app.attempts', '1' from dual
      ) required
      on (p.mkey = required.mkey)
      when matched then update set p.value = required.value
        where nvl(p.value, 'x') <> required.value
      when not matched then insert (mkey, value)
        values (required.mkey, required.value)
    ]';
    commit;
  else
    dbms_output.put_line('WARN: OSA.OSA_SYSTEM_PROPERTY not found; skip Spark runtime reconciliation.');
  end if;
exception
  when others then
    dbms_output.put_line('WARN: skip Spark runtime reconciliation: ' || sqlerrm);
end;
/
exit;
SQL

echo "==> Start Spark services if available"
exec_oracle "
  set -eu
  if [ -x '${SPARK_HOME}/sbin/start-master.sh' ]; then
    '${SPARK_HOME}/sbin/start-master.sh' >/tmp/osa-start-spark-master.log 2>&1 || true
  fi
  if [ -x '${SPARK_HOME}/sbin/start-worker.sh' ]; then
    for i in \$(seq 1 ${SPARK_WORKER_INSTANCES}); do
      '${SPARK_HOME}/sbin/start-worker.sh' spark://localhost:7077 >/tmp/osa-start-spark-worker-\${i}.log 2>&1 || true
    done
  fi
  if [ -x '${SPARK_HOME}/sbin/start-history-server.sh' ]; then
    '${SPARK_HOME}/sbin/start-history-server.sh' >/tmp/osa-start-spark-history.log 2>&1 || true
  fi
"

echo "==> Patch OSA/GGSA websocket origins for the Lab Kit host port"
docker exec -i -e OSA_BASE="${OSA_BASE}" "${OSA_CONTAINER}" bash <<'CONTAINER'
set -eu
jar="${OSA_BASE}/libs/api-server-19.1.3-100.jar"
[ -f "${jar}" ] || exit 0
work=$(mktemp -d)
trap 'rm -rf "${work}"' EXIT
cd "${work}"
jar xf "${jar}" application.yaml application-standalone-ssl.yaml >/dev/null 2>&1 || exit 0
changed=0
for f in application.yaml application-standalone-ssl.yaml; do
  [ -f "${f}" ] || continue
  if ! grep -q 'https://localhost:39443' "${f}"; then
    if grep -q 'https://localhost:9443' "${f}"; then
      sed -i '/https:\/\/localhost:9443/a\                       "https://localhost:39443",\n                       "https://127.0.0.1:39443",' "${f}"
    elif grep -q 'https://127.0.0.1",' "${f}"; then
      sed -i '/https:\/\/127.0.0.1",/a\                       "https://localhost:39443",\n                       "https://127.0.0.1:39443",' "${f}"
    fi
    if grep -q 'https://localhost:39443' "${f}"; then
      changed=1
    fi
  fi
done
if [ "${changed}" -eq 1 ]; then
    jar uf "${jar}" application.yaml application-standalone-ssl.yaml
    chown oracle:oinstall "${jar}" 2>/dev/null || true
    echo 'Patched OSA/GGSA websocket origins for https://localhost:39443.'
fi
CONTAINER

echo "==> Reconcile OSA Geo Spatial map focus"
reconcile_spatial_map_focus

echo "==> Restore OSA Pie visualization 3D option"
reconcile_pie_3d_option

echo "==> Start OSA/GGSA server"
exec_oracle "
  set -eu
  mkdir -p '${OSA_BASE}/logs'
  cd '${OSA_BIN}'
  timeout 60 ./stop-osa.sh >'${OSA_BASE}/logs/osa-stop-before-start.log' 2>&1 || true
  osa_pids=\$(ps -eo pid=,args= | awk '/oracle\\.cloud\\.osa\\.Main/ && !/awk/ {print \$1}')
  if [ -n \"\${osa_pids}\" ]; then
    echo \"Stopping stale OSA/GGSA process pids: \${osa_pids}\"
    kill \${osa_pids} 2>/dev/null || true
    sleep 5
    osa_pids=\$(ps -eo pid=,args= | awk '/oracle\\.cloud\\.osa\\.Main/ && !/awk/ {print \$1}')
    if [ -n \"\${osa_pids}\" ]; then
      echo \"Killing stale OSA/GGSA process pids: \${osa_pids}\"
      kill -KILL \${osa_pids} 2>/dev/null || true
      sleep 2
    fi
  fi
  pid_file='${OSA_BASE}/osa.pid'
  if [ -f \"\${pid_file}\" ]; then
    pid=\$(cat \"\${pid_file}\" 2>/dev/null || true)
    stat=\$(ps -o stat= -p \"\${pid}\" 2>/dev/null | tr -d ' ' || true)
    args=\$(ps -o args= -p \"\${pid}\" 2>/dev/null || true)
    if [ -z \"\${pid}\" ] || [ -z \"\${stat}\" ] || echo \"\${stat}\" | grep -q 'Z' || ! echo \"\${args}\" | grep -q 'oracle.cloud.osa.Main'; then
      backup=\"\${pid_file}.stale-after-stop-\$(date +%Y%m%d%H%M%S)\"
      echo \"Moving stale OSA PID file after stop attempt to \${backup}\"
      mv \"\${pid_file}\" \"\${backup}\"
    fi
  fi
  nohup ./start-osa.sh --no-samples \
    dbroot='SYS AS SYSDBA' \
    dbroot_password='${OSA_PASSWORD}' \
    osaadmin_user='${OSA_ADMIN_USER}' \
    osaadmin_password='${OSA_ADMIN_PASSWORD}' \
    >'${OSA_BASE}/logs/osa-startup-manual.log' 2>&1 < /dev/null &
"

wait_for_osa

echo "OK: OSA/GGSA is ready."
echo "Open: https://localhost:39443/osa/index.html"
