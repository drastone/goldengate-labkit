#!/usr/bin/env bash
set -u

BIGDATA_CONTAINER="${BIGDATA_CONTAINER:-demo_centos}"
OGGBD_CONTAINER="${OGGBD_CONTAINER:-demo_oggbd_23ai}"
KAFKA_HOME="${KAFKA_HOME:-/usr/local/kafka}"
KAFKA_BOOTSTRAP_SERVER="${KAFKA_BOOTSTRAP_SERVER:-localhost:9092}"
KAFKA_REPLICAT_NAME="${KAFKA_REPLICAT_NAME:-KAF01}"
FORCE="${FORCE:-N}"

TOPICS="${TOPICS:-SOE.CFUND_DT}"
OSA_TOPIC_PREFIX="${OSA_TOPIC_PREFIX:-sx_KafkaPipeline_}"

rc=0

ok() { echo "OK: $*"; }
info() { echo "INFO: $*"; }
warn() { echo "WARN: $*"; }
error() { echo "ERROR: $*"; rc=1; }

is_yes() {
  case "${1:-}" in
    1|Y|y|YES|yes|TRUE|true|ON|on) return 0 ;;
    *) return 1 ;;
  esac
}

container_running() {
  [ "$(docker inspect -f '{{.State.Status}}' "$1" 2>/dev/null || true)" = "running" ]
}

confirm_reset() {
  if is_yes "${FORCE}"; then
    return 0
  fi

  echo "WARN: This deletes Kafka demo topics used by the OSA dashboard lab."
  echo "WARN: Source database rows are not deleted, but Kafka history for these topics is removed."
  echo "WARN: Topics:"
  for topic in ${TOPICS}; do
    echo "WARN:   ${topic}"
  done
  echo "WARN:   ${OSA_TOPIC_PREFIX}*"
  printf "Type RESET to continue: "
  read answer
  [ "${answer}" = "RESET" ]
}

stop_kafka_replicat() {
  if ! container_running "${OGGBD_CONTAINER}"; then
    warn "${OGGBD_CONTAINER} is not running; skip ${KAFKA_REPLICAT_NAME} stop"
    return 0
  fi

  echo "==> Stop ${KAFKA_REPLICAT_NAME}"
  docker exec -u ogg "${OGGBD_CONTAINER}" bash -lc "
    timeout 20 curl -fsS 'http://127.0.0.1:8765/api/adminclient?cmd=stop%20${KAFKA_REPLICAT_NAME}' >/tmp/reset-osa-stop-kaf.out 2>&1 || true
    timeout 20 curl -fsS 'http://127.0.0.1:8765/api/adminclient?cmd=info%20${KAFKA_REPLICAT_NAME}' 2>/dev/null | sed -n '1,20p' || true
  " | sed 's/^/INFO: /'
}

start_kafka_replicat() {
  if ! container_running "${OGGBD_CONTAINER}"; then
    warn "${OGGBD_CONTAINER} is not running; skip ${KAFKA_REPLICAT_NAME} start"
    return 0
  fi

  echo "==> Start ${KAFKA_REPLICAT_NAME}"
  docker exec -u ogg "${OGGBD_CONTAINER}" bash -lc "
    timeout 20 curl -fsS 'http://127.0.0.1:8765/api/adminclient?cmd=start%20${KAFKA_REPLICAT_NAME}' >/tmp/reset-osa-start-kaf.out 2>&1 || true
    timeout 20 curl -fsS 'http://127.0.0.1:8765/api/adminclient?cmd=info%20${KAFKA_REPLICAT_NAME}' 2>/dev/null | sed -n '1,20p' || true
  " | sed 's/^/INFO: /'
}

reset_topics() {
  if ! container_running "${BIGDATA_CONTAINER}"; then
    error "${BIGDATA_CONTAINER} is not running"
    return 1
  fi

  echo "==> Delete and recreate OSA demo Kafka topics"
  docker exec "${BIGDATA_CONTAINER}" bash -lc "
    set +e
    topic_list=\"${TOPICS}\"
    osa_topics=\$('${KAFKA_HOME}/bin/kafka-topics.sh' --bootstrap-server '${KAFKA_BOOTSTRAP_SERVER}' --list 2>/dev/null | grep '^${OSA_TOPIC_PREFIX}' || true)
    topic_list=\"\${topic_list} \${osa_topics}\"

    for topic in \${topic_list}; do
      [ -n \"\${topic}\" ] || continue
      echo \"INFO: delete topic \${topic}\"
      '${KAFKA_HOME}/bin/kafka-topics.sh' --bootstrap-server '${KAFKA_BOOTSTRAP_SERVER}' --delete --topic \"\${topic}\" >/tmp/reset-osa-delete-\${topic//[^A-Za-z0-9]/_}.out 2>&1 || true
    done

    sleep 15

    echo 'INFO: recreate source topic SOE.CFUND_DT'
    '${KAFKA_HOME}/bin/kafka-topics.sh' --bootstrap-server '${KAFKA_BOOTSTRAP_SERVER}' \
      --create --if-not-exists --topic SOE.CFUND_DT --partitions 1 --replication-factor 1

    echo 'INFO: current matching topics'
    '${KAFKA_HOME}/bin/kafka-topics.sh' --bootstrap-server '${KAFKA_BOOTSTRAP_SERVER}' --list \
      | grep -E '^(SOE\\.CFUND_DT|sx_KafkaPipeline_)' || true
  " || return 1
}

if ! confirm_reset; then
  echo "INFO: reset cancelled"
  exit 0
fi

stop_kafka_replicat
reset_topics || error "Kafka topic reset failed"
start_kafka_replicat

echo "INFO: Republish the OSA pipeline or run fix_osa_demo.sh before sending dashboard data."
exit "${rc}"
