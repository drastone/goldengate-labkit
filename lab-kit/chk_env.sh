#!/usr/bin/env bash
set -u

MODE="${1:-post-start}"
BIGDATA_CONTAINER="${BIGDATA_CONTAINER:-demo_centos}"

rc=0

ok() { echo "OK: $*"; }
info() { echo "INFO: $*"; }
warn() { echo "WARN: $*"; }
error() { echo "ERROR: $*"; rc=1; }

container_running() {
  [ "$(docker inspect -f '{{.State.Status}}' "$1" 2>/dev/null || true)" = "running" ]
}

run_centos() {
  docker exec -u root "${BIGDATA_CONTAINER}" bash -lc "$*"
}

reset_kafka_cluster_id_mismatch() {
  echo "==> ${BIGDATA_CONTAINER}: repair Kafka cluster.id mismatch"
  run_centos '
    set -eu
    ts=$(date +%Y%m%d_%H%M%S)
    backup_dir=/root/kafka-reset-backup
    mkdir -p "${backup_dir}"

    for port in 9092 2181; do
      pids=$(ss -ltnp 2>/dev/null | awk -v port=":${port}" "
        index(\$0, port) && match(\$0, /pid=[0-9]+/) {
          print substr(\$0, RSTART + 4, RLENGTH - 4)
        }" | sort -u)
      [ -z "${pids}" ] || kill ${pids} 2>/dev/null || true
    done
    sleep 3
    for port in 9092 2181; do
      pids=$(ss -ltnp 2>/dev/null | awk -v port=":${port}" "
        index(\$0, port) && match(\$0, /pid=[0-9]+/) {
          print substr(\$0, RSTART + 4, RLENGTH - 4)
        }" | sort -u)
      [ -z "${pids}" ] || kill -9 ${pids} 2>/dev/null || true
    done

    [ -e /usr/local/kafka/logs ] && mv /usr/local/kafka/logs "${backup_dir}/kafka-logs-${ts}"
    [ -e /usr/local/zookeeper/data/version-2 ] && mv /usr/local/zookeeper/data/version-2 "${backup_dir}/zookeeper-version-2-${ts}"
    mkdir -p /usr/local/kafka/logs /usr/local/zookeeper/data /usr/local/zookeeper/logs
    echo 1 > /usr/local/zookeeper/data/myid

    cd /usr/local/zookeeper
    nohup env ZOO_LOG_DIR=/usr/local/zookeeper/logs ZOO_LOG4J_PROP=INFO,ROLLINGFILE \
      /usr/local/zookeeper/bin/zkServer.sh start-foreground /usr/local/zookeeper/conf/zoo.cfg \
      >> /usr/local/zookeeper/logs/zookeeper-startup.out 2>&1 </dev/null &
    for i in $(seq 1 30); do ss -ltn | grep -q ":2181 " && break; sleep 1; done
    ss -ltn | grep -q ":2181 "

    cd /usr/local/kafka
    nohup env KAFKA_HEAP_OPTS="-Xms256m -Xmx512m" \
      /usr/local/kafka/bin/kafka-server-start.sh /usr/local/kafka/config/server.properties \
      >> /usr/local/kafka/logs/kafka-startup.out 2>&1 </dev/null &
    for i in $(seq 1 40); do ss -ltn | grep -q ":9092 " && break; sleep 1; done
    ss -ltn | grep -q ":9092 "
  ' && ok "Kafka cluster.id mismatch repaired" || error "Kafka cluster.id mismatch repair failed"
}

check_kafka_environment() {
  if ! container_running "${BIGDATA_CONTAINER}"; then
    info "${BIGDATA_CONTAINER} is not running; skip Kafka environment check"
    return 0
  fi

  if run_centos 'ss -ltn | grep -q ":9092 "' >/dev/null 2>&1; then
    ok "Kafka listener is already open"
    return 0
  fi

  if run_centos 'grep -Rqs "Invalid cluster.id" /usr/local/kafka/logs/server.log /usr/local/kafka/logs/kafka-startup.out 2>/dev/null' >/dev/null 2>&1; then
    warn "Kafka cluster.id mismatch detected"
    reset_kafka_cluster_id_mismatch
  else
    info "Kafka listener is not open yet, but no cluster.id mismatch was detected"
  fi
}

case "${MODE}" in
  pre-start|post-start)
    check_kafka_environment
    ;;
  *)
    echo "Usage: sh chk_env.sh [pre-start|post-start]"
    exit 2
    ;;
esac

exit "${rc}"
