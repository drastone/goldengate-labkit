#!/usr/bin/env bash
set -u

rc=0
CHECK_OPTIONAL="${CHECK_OPTIONAL:-N}"

ok() {
  echo "OK: $*"
}

warn() {
  echo "WARN: $*"
}

info() {
  echo "INFO: $*"
}

error() {
  echo "ERROR: $*"
  rc=1
}

container_status() {
  docker inspect -f '{{.State.Status}}{{if .State.Health}} {{.State.Health.Status}}{{end}}' "$1" 2>/dev/null || true
}

require_running() {
  name="$1"
  status="$(container_status "$name")"

  case "$status" in
    "running healthy")
      ok "$name is running (healthy)"
      ;;
    "running")
      ok "$name is running"
      ;;
    "")
      error "$name container was not found"
      ;;
    *)
      error "$name status is '$status'"
      ;;
  esac
}

optional_running() {
  name="$1"
  status="$(container_status "$name")"

  case "$status" in
    "running healthy")
      ok "$name is running (healthy)"
      ;;
    "running")
      ok "$name is running"
      ;;
    "")
      warn "$name optional container was not found"
      ;;
    *)
      warn "$name optional container status is '$status'"
      ;;
  esac
}

allow_completed() {
  name="$1"
  status="$(docker inspect -f '{{.State.Status}} {{.State.ExitCode}}' "$name" 2>/dev/null || true)"

  case "$status" in
    "exited 0")
      ok "$name completed successfully"
      ;;
    "running 0"|"running "*)
      ok "$name is running"
      ;;
    "")
      warn "$name container was not found"
      ;;
    *)
      error "$name status is '$status'"
      ;;
  esac
}

check_centos_port() {
  port="$1"
  label="$2"

  if docker exec demo_centos bash -lc "netstat -ltn | grep -q ':${port} '" >/dev/null 2>&1; then
    ok "$label listener is open on demo_centos:${port}"
  else
    error "$label listener is not open on demo_centos:${port}"
  fi
}

check_centos_process() {
  pattern="$1"
  label="$2"
  severity="${3:-warn}"

  if docker exec demo_centos bash -lc "ps -ef | grep -E '${pattern}' | grep -v grep >/dev/null" >/dev/null 2>&1; then
    ok "$label process is running"
  else
    if [ "$severity" = "info" ]; then
      info "$label process is not running"
    else
      warn "$label process is not running"
    fi
  fi
}

check_centos_pid_file() {
  pid_file="$1"
  pattern="$2"
  label="$3"
  severity="${4:-error}"

  docker exec demo_centos bash -lc "
    [ -f '${pid_file}' ] || exit 2
    pid=\$(cat '${pid_file}' 2>/dev/null || true)
    stat=\$(ps -o stat= -p \"\${pid}\" 2>/dev/null | tr -d ' ' || true)
    args=\$(ps -o args= -p \"\${pid}\" 2>/dev/null || true)
    [ -n \"\${pid}\" ] && [ -n \"\${stat}\" ] && ! echo \"\${stat}\" | grep -q 'Z' && echo \"\${args}\" | grep -q '${pattern}'
  " >/dev/null 2>&1
  case "$?" in
    0)
      ok "$label PID file points to a live process"
      ;;
    2)
      warn "$label PID file is not present"
      ;;
    *)
      if [ "$severity" = "info" ]; then
        info "$label has a previous-run PID file; startOSA.sh/stopOSA.sh will clean it automatically"
      elif [ "$severity" = "warn" ]; then
        warn "$label has a previous-run PID file; startOSA.sh/stopOSA.sh will clean it automatically"
      else
        error "$label PID file is stale or points to the wrong process"
      fi
      ;;
  esac
}

check_tcp_from_container() {
  from_container="$1"
  host="$2"
  port="$3"
  label="$4"

  if docker exec "$from_container" bash -lc \
      "timeout 5 bash -lc '</dev/tcp/${host}/${port}'" >/dev/null 2>&1; then
    ok "$label is reachable from $from_container at ${host}:${port}"
  else
    error "$label is not reachable from $from_container at ${host}:${port}"
  fi
}

check_mysql_ping() {
  container="$1"
  label="$2"

  if docker exec "$container" sh -lc \
      'mysqladmin ping -h 127.0.0.1 -uroot -p"${MYSQL_ROOT_PASSWORD}" --silent' >/dev/null 2>&1; then
    ok "$label is accepting MySQL connections"
  else
    error "$label is not accepting MySQL connections"
  fi
}

echo "==> Check Lab Kit containers"
require_running demo_osrc_23ai
require_running demo_otrg_23ai
require_running demo_ogg_23ai
require_running demo_oggbd_23ai
require_running demo_centos
optional_running demo_mysql
optional_running demo_myheat
optional_running demo_minio
optional_running demo_iceberg_catalog
optional_running demo_trino

echo "==> Check Oracle DB listeners from GoldenGate"
check_tcp_from_container demo_ogg_23ai oracle_src_23ai 1521 "Source DB listener"
check_tcp_from_container demo_ogg_23ai oracle_trg_23ai 1521 "Target DB listener"

echo "==> Check MySQL -> HeatWave migration sandbox"
if [ "$CHECK_OPTIONAL" = "Y" ]; then
  check_mysql_ping demo_mysql "MySQL source demo_mysql"
  check_mysql_ping demo_myheat "HeatWave-compatible target demo_myheat"
  check_tcp_from_container demo_ogg_23ai mysql 3306 "MySQL source listener"
  check_tcp_from_container demo_ogg_23ai myheat 3306 "HeatWave-compatible target listener"
else
  warn "MySQL/HeatWave checks skipped by default. Run CHECK_OPTIONAL=Y ./status_labkit.sh for optional service checks."
fi

echo "==> Check Big Data services inside demo_centos"
check_centos_port 2181 "ZooKeeper"
check_centos_port 9092 "Kafka"

if docker exec demo_centos bash -lc '/usr/local/kafka/bin/kafka-topics.sh --bootstrap-server 127.0.0.1:9092 --list >/dev/null' >/dev/null 2>&1; then
  ok "Kafka CLI can connect to 127.0.0.1:9092"
else
  error "Kafka CLI cannot connect to 127.0.0.1:9092"
fi

echo "==> Check optional OSA/GGSA runtime inside demo_centos"
osa_runtime_running=N
if docker exec demo_centos bash -lc "ps -ef | grep -E 'oracle.cloud.osa.Main|org.apache.spark.deploy.master.Master|org.apache.spark.deploy.worker.Worker' | grep -v grep >/dev/null" >/dev/null 2>&1; then
  osa_runtime_running=Y
  check_centos_process 'oracle.cloud.osa.Main' "OSA/GGSA"
  check_centos_process 'org.apache.spark.deploy.master.Master' "Spark master"
  check_centos_process 'org.apache.spark.deploy.worker.Worker' "Spark worker"
  check_centos_pid_file /home/oracle/osa/osa-base/osa.pid 'oracle.cloud.osa.Main' "OSA/GGSA"
  check_centos_pid_file /tmp/spark-oracle-org.apache.spark.deploy.master.Master-1.pid 'org.apache.spark.deploy.master.Master' "Spark master"
  check_centos_pid_file /tmp/spark-oracle-org.apache.spark.deploy.worker.Worker-1.pid 'org.apache.spark.deploy.worker.Worker' "Spark worker"
else
  info "OSA/GGSA and Spark are optional and are not running yet. Run ./startOSA.sh before OSA/GGSA labs."
  check_centos_pid_file /home/oracle/osa/osa-base/osa.pid 'oracle.cloud.osa.Main' "OSA/GGSA" info
  check_centos_pid_file /tmp/spark-oracle-org.apache.spark.deploy.master.Master-1.pid 'org.apache.spark.deploy.master.Master' "Spark master" info
  check_centos_pid_file /tmp/spark-oracle-org.apache.spark.deploy.worker.Worker-1.pid 'org.apache.spark.deploy.worker.Worker' "Spark worker" info
fi

if docker exec demo_centos bash -lc "grep -q '^spark.master[[:space:]]spark://localhost:7077' /home/oracle/spark/conf/spark-defaults.conf 2>/dev/null"; then
  ok "Spark default master is spark://localhost:7077"
else
  if [ "$osa_runtime_running" = "Y" ]; then
    warn "Spark default master is not set for OSA/GGSA; run ./startOSA.sh before OSA labs"
  else
    info "Spark default master will be reconciled by ./startOSA.sh before OSA/GGSA labs"
  fi
fi

if docker exec demo_centos bash -lc "unzip -p /home/oracle/osa/osa-base/libs/api-server-19.1.3-100.jar application.yaml 2>/dev/null | grep -q 'https://localhost:39443'"; then
  ok "OSA/GGSA websocket origin allows https://localhost:39443"
else
  warn "OSA/GGSA websocket origin for https://localhost:39443 is not patched; run ./startOSA.sh"
fi

if [ "$rc" -eq 0 ]; then
  ok "Lab Kit runtime status checks passed."
else
  error "Lab Kit runtime status checks failed. Check docker logs for the ERROR items above."
fi

exit "$rc"
