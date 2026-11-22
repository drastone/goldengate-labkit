#!/usr/bin/env bash
set -u

MODE="${1:-post-start}"
BIGDATA_CONTAINER="${BIGDATA_CONTAINER:-demo_centos}"
OGGBD_CONTAINER="${OGGBD_CONTAINER:-demo_oggbd_23ai}"
OGG_REST_USER="${OGG_REST_USER:-oggadmin}"
OGG_REST_PASSWORD="${OGG_REST_PASSWORD:-WElcome1234##}"
KAFKA_PROBE_TOPIC="${KAFKA_PROBE_TOPIC:-__startdocker_probe}"

rc=0

ok() { echo "OK: $*"; }
info() { echo "INFO: $*"; }
warn() { echo "WARN: $*"; }
error() { echo "ERROR: $*"; rc=1; }

container_running() {
  [ "$(docker inspect -f '{{.State.Status}}' "$1" 2>/dev/null || true)" = "running" ]
}

port_open_in_centos() {
  port="$1"
  docker exec "${BIGDATA_CONTAINER}" bash -lc "ss -ltn 2>/dev/null | grep -q ':${port} '" >/dev/null 2>&1
}

cleanup_optional_osa_runtime() {
  if ! container_running "${BIGDATA_CONTAINER}"; then
    info "${BIGDATA_CONTAINER} is not running; skip optional OSA/Spark process cleanup"
    return 0
  fi

  echo "==> ${BIGDATA_CONTAINER}: cleanup optional OSA/Spark runtime before base startup"
  docker exec -u root "${BIGDATA_CONTAINER}" bash -lc '
    patterns="oracle.cloud.osa.Main|org.apache.spark.deploy.master.Master|org.apache.spark.deploy.worker.Worker|CoarseGrainedExecutorBackend|spark-submit"
    pids=$(ps -eo pid=,stat=,args= | awk -v pat="${patterns}" "\$0 ~ pat && \$2 !~ /Z/ { print \$1 }")
    if [ -z "${pids}" ]; then
      echo "OK: no optional OSA/Spark runtime process remains"
      exit 0
    fi
    echo "WARN: stop optional OSA/Spark runtime PIDs: ${pids}"
    kill ${pids} 2>/dev/null || true
    sleep 3
    pids=$(ps -eo pid=,stat=,args= | awk -v pat="${patterns}" "\$0 ~ pat && \$2 !~ /Z/ { print \$1 }")
    [ -z "${pids}" ] || kill -9 ${pids} 2>/dev/null || true
    rm -f /home/oracle/osa/osa-base/osa.pid /tmp/spark-oracle-org.apache.spark.deploy.*.pid 2>/dev/null || true
  ' || return 1
}

cleanup_bigdata_core_runtime() {
  if ! container_running "${BIGDATA_CONTAINER}"; then
    info "${BIGDATA_CONTAINER} is not running; skip Kafka/ZooKeeper process cleanup"
    return 0
  fi

  echo "==> ${BIGDATA_CONTAINER}: cleanup Kafka/ZooKeeper runtime before base startup"
  docker exec -u root "${BIGDATA_CONTAINER}" bash -lc '
    patterns="kafka.Kafka|org.apache.zookeeper.server.quorum.QuorumPeerMain|QuorumPeerMain"
    pids=$(ps -eo pid=,stat=,args= | awk -v pat="${patterns}" "\$0 ~ pat && \$2 !~ /Z/ { print \$1 }")
    if [ -z "${pids}" ]; then
      echo "OK: no Kafka/ZooKeeper runtime process remains"
      exit 0
    fi
    echo "WARN: stop Kafka/ZooKeeper runtime PIDs: ${pids}"
    kill ${pids} 2>/dev/null || true
    sleep 5
    pids=$(ps -eo pid=,stat=,args= | awk -v pat="${patterns}" "\$0 ~ pat && \$2 !~ /Z/ { print \$1 }")
    [ -z "${pids}" ] || kill -9 ${pids} 2>/dev/null || true
    rm -f /tmp/kafka-*.pid /tmp/zookeeper*.pid /usr/local/kafka/logs/.lock 2>/dev/null || true
  ' || return 1
}

check_required_containers() {
  for container in demo_osrc_23ai demo_otrg_23ai demo_ogg_23ai "${OGGBD_CONTAINER}" "${BIGDATA_CONTAINER}"; do
    if container_running "${container}"; then
      ok "${container} is running"
    else
      error "${container} is not running"
    fi
  done
}

check_bigdata_processes() {
  if ! container_running "${BIGDATA_CONTAINER}"; then
    error "${BIGDATA_CONTAINER} is not running"
    return 0
  fi

  if port_open_in_centos 2181; then
    ok "ZooKeeper listener is open on ${BIGDATA_CONTAINER}:2181"
  else
    error "ZooKeeper listener is not open on ${BIGDATA_CONTAINER}:2181"
  fi

  if port_open_in_centos 9092; then
    ok "Kafka listener is open on ${BIGDATA_CONTAINER}:9092"
  else
    error "Kafka listener is not open on ${BIGDATA_CONTAINER}:9092"
  fi

  docker exec "${BIGDATA_CONTAINER}" bash -lc "
    set -e
    /usr/local/kafka/bin/kafka-topics.sh --bootstrap-server localhost:9092 \
      --create --if-not-exists --topic '${KAFKA_PROBE_TOPIC}' \
      --partitions 1 --replication-factor 1 >/tmp/chk-ps-kafka-topic.out 2>&1

    msg=\"probe-\$(date +%s)-\$\$\"
    rm -f /tmp/chk-ps-kafka-producer.out /tmp/chk-ps-kafka-consumer.out
    timeout 12 /usr/local/kafka/bin/kafka-console-consumer.sh \
      --bootstrap-server localhost:9092 --topic '${KAFKA_PROBE_TOPIC}' \
      --partition 0 --offset latest --max-messages 1 --timeout-ms 10000 \
      >/tmp/chk-ps-kafka-consumer.out 2>&1 &
    consumer_pid=\$!
    sleep 2
    printf '%s\n' \"\${msg}\" | timeout 10 /usr/local/kafka/bin/kafka-console-producer.sh \
      --bootstrap-server localhost:9092 --topic '${KAFKA_PROBE_TOPIC}' >/tmp/chk-ps-kafka-producer.out 2>&1
    wait \${consumer_pid}
    grep -qx \"\${msg}\" /tmp/chk-ps-kafka-consumer.out
  " >/dev/null 2>&1 && ok "Kafka produce/consume probe succeeded" || error "Kafka produce/consume probe failed"
}


case "${MODE}" in
  pre-start)
    cleanup_optional_osa_runtime || warn "optional OSA/Spark cleanup failed; continue startup"
    cleanup_bigdata_core_runtime || warn "Kafka/ZooKeeper cleanup failed; continue startup"
    ;;
  post-start)
    check_required_containers
    check_bigdata_processes
    ;;
  *)
    echo "Usage: sh chk_ps.sh [pre-start|post-start]"
    exit 2
    ;;
esac

exit "${rc}"
