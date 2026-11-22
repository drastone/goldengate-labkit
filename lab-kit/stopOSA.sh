#!/usr/bin/env bash
set -eu

# Stop OSA/GGSA and Spark after the Stream Analytics labs to return memory to
# the laptop/WSL environment. Kafka and ZooKeeper are intentionally left running.

OSA_CONTAINER="${OSA_CONTAINER:-demo_centos}"
OSA_BASE="${OSA_BASE:-/home/oracle/osa/osa-base}"
OSA_BIN="${OSA_BIN:-${OSA_BASE}/bin}"
SPARK_HOME="${SPARK_HOME:-/home/oracle/spark}"
STOP_GRACE_SECONDS="${STOP_GRACE_SECONDS:-60}"
STOP_KILL_WAIT_SECONDS="${STOP_KILL_WAIT_SECONDS:-15}"
STOP_POLL_SECONDS="${STOP_POLL_SECONDS:-5}"

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

exec_oracle() {
  docker exec -u oracle "${OSA_CONTAINER}" bash -lc "$*"
}

require_container
ensure_osa_log_error_helper

echo "Stop OSA/GGSA runtime"
echo "Container : ${OSA_CONTAINER}"

echo "==> Stop OSA/GGSA server"
exec_oracle "
  set -u
  if [ -x '${OSA_BIN}/stop-osa.sh' ]; then
    mkdir -p '${OSA_BASE}/logs'
    cd '${OSA_BIN}'
    timeout 90 ./stop-osa.sh >'${OSA_BASE}/logs/osa-stop-manual.log' 2>&1 || true
  fi
  pid_file='${OSA_BASE}/osa.pid'
  if [ -f \"\${pid_file}\" ]; then
    pid=\$(cat \"\${pid_file}\" 2>/dev/null || true)
    stat=\$(ps -o stat= -p \"\${pid}\" 2>/dev/null | tr -d ' ' || true)
    args=\$(ps -o args= -p \"\${pid}\" 2>/dev/null || true)
    if [ -z \"\${pid}\" ] || [ -z \"\${stat}\" ] || echo \"\${stat}\" | grep -q 'Z' || ! echo \"\${args}\" | grep -q 'oracle.cloud.osa.Main'; then
      backup=\"\${pid_file}.stale-stop-\$(date +%Y%m%d%H%M%S)\"
      echo \"Moving stale OSA PID file to \${backup}\"
      mv \"\${pid_file}\" \"\${backup}\"
    fi
  fi
"

echo "==> Stop Spark services if available"
exec_oracle "
  set -u
  if [ -x '${SPARK_HOME}/sbin/stop-worker.sh' ]; then
    '${SPARK_HOME}/sbin/stop-worker.sh' >/tmp/osa-stop-spark-worker.log 2>&1 || true
  fi
  if [ -x '${SPARK_HOME}/sbin/stop-master.sh' ]; then
    '${SPARK_HOME}/sbin/stop-master.sh' >/tmp/osa-stop-spark-master.log 2>&1 || true
  fi
  if [ -x '${SPARK_HOME}/sbin/stop-history-server.sh' ]; then
    '${SPARK_HOME}/sbin/stop-history-server.sh' >/tmp/osa-stop-spark-history.log 2>&1 || true
  fi
  for pid_file in \
      /tmp/spark-oracle-org.apache.spark.deploy.worker.Worker-1.pid \
      /tmp/spark-oracle-org.apache.spark.deploy.master.Master-1.pid \
      /tmp/spark-oracle-org.apache.spark.deploy.history.HistoryServer-1.pid; do
    [ -f \"\${pid_file}\" ] || continue
    pid=\$(cat \"\${pid_file}\" 2>/dev/null || true)
    stat=\$(ps -o stat= -p \"\${pid}\" 2>/dev/null | tr -d ' ' || true)
    args=\$(ps -o args= -p \"\${pid}\" 2>/dev/null || true)
    if [ -z \"\${pid}\" ] || [ -z \"\${stat}\" ] || echo \"\${stat}\" | grep -q 'Z' || ! echo \"\${args}\" | grep -q 'org.apache.spark.deploy'; then
      backup=\"\${pid_file}.stale-stop-\$(date +%Y%m%d%H%M%S)\"
      echo \"Moving stale Spark PID file to \${backup}\"
      mv \"\${pid_file}\" \"\${backup}\"
    fi
  done

  runtime_pids() {
    ps -eo pid,stat,args | awk '
      /oracle\.cloud\.osa\.Main|org\.apache\.spark\.deploy\./ && !/awk/ && \$2 !~ /^Z/ {print \$1}
    '
  }

  wait_for_runtime_exit() {
    limit="\$1"
    elapsed=0
    while true; do
      set -- \$(runtime_pids)
      [ "\$#" -eq 0 ] && return 0
      [ "\${elapsed}" -ge "\${limit}" ] && return 1
      echo \"INFO: Waiting for OSA/Spark shutdown (\${elapsed}/\${limit}s, pids: \$*)\"
      sleep '${STOP_POLL_SECONDS}'
      elapsed=\$((elapsed + ${STOP_POLL_SECONDS}))
    done
  }

  set -- \$(runtime_pids)
  if [ "\$#" -gt 0 ]; then
    echo "Stopping remaining OSA/Spark process pids: \$*"
    kill "\$@" 2>/dev/null || true
    wait_for_runtime_exit '${STOP_GRACE_SECONDS}' || true
  fi

  set -- \$(runtime_pids)
  if [ "\$#" -gt 0 ]; then
    echo "Killing remaining OSA/Spark process pids: \$*"
    kill -KILL "\$@" 2>/dev/null || true
    wait_for_runtime_exit '${STOP_KILL_WAIT_SECONDS}' || true
  fi
"

echo "==> Remaining OSA/Spark processes"
if docker exec "${OSA_CONTAINER}" bash -lc "
  ps -eo stat,args | awk '
    /oracle\.cloud\.osa\.Main|org\.apache\.spark\.deploy\./ && !/awk/ && \$1 !~ /^Z/ {found=1}
    END {exit found ? 0 : 1}
  '
"; then
  docker exec "${OSA_CONTAINER}" bash -lc "
    ps -eo pid,stat,args | awk '
      /oracle\.cloud\.osa\.Main|org\.apache\.spark\.deploy\./ && !/awk/ && \$2 !~ /^Z/ {
        role=\"Spark runtime\"
        if (/oracle\.cloud\.osa\.Main/) role=\"OSA server\"
        else if (/master\.Master/) role=\"Spark master\"
        else if (/worker\.Worker/) role=\"Spark worker\"
        else if (/history\.HistoryServer/) role=\"Spark history server\"
        else if (/worker\.DriverWrapper/) role=\"Spark pipeline driver\"
        printf \"PID %-7s %s\\n\", \$1, role
      }
    '
  "
  echo "ERROR: OSA/Spark processes are still running."
  exit 1
fi

echo "No OSA/Spark runtime process remains."

echo "OK: OSA/GGSA stop completed."
