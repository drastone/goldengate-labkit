#!/bin/bash
set -euo pipefail

KAFKA_HOME="${KAFKA_HOME:-/usr/local/kafka}"
KAFKA_CONTAINER="${KAFKA_CONTAINER:-demo_centos}"
BOOTSTRAP_SERVER="${BOOTSTRAP_SERVER:-localhost:9092}"
PARTITIONS="${PARTITIONS:-1}"
REPLICATION_FACTOR="${REPLICATION_FACTOR:-1}"
DELETE_WAIT_SECONDS="${DELETE_WAIT_SECONDS:-30}"

CREATE_TOPICS=(
  "SOE.CFUND_DT"
  "ORCLPDB1.SOE.CFUND_DT"
)

DELETE_TOPICS=(
  "${CREATE_TOPICS[@]}"
  "FREEPDB1.SOE.CFUND_DT"
)

if [ "$#" -gt 0 ]; then
  CREATE_TOPICS=("$@")
  DELETE_TOPICS=("$@")
fi

KAFKA_TOPICS="${KAFKA_HOME}/bin/kafka-topics.sh"

USE_DOCKER_EXEC="N"

if [ ! -x "${KAFKA_TOPICS}" ]; then
  if command -v docker >/dev/null 2>&1 \
    && docker ps --format '{{.Names}}' | grep -Fxq "${KAFKA_CONTAINER}" \
    && docker exec "${KAFKA_CONTAINER}" test -x "${KAFKA_TOPICS}"; then
    USE_DOCKER_EXEC="Y"
  else
    echo "Kafka topic command not found: ${KAFKA_TOPICS}" >&2
    echo "Also failed to find it in Docker container: ${KAFKA_CONTAINER}" >&2
    exit 1
  fi
fi

kafka_topics() {
  if [ "${USE_DOCKER_EXEC}" = "Y" ]; then
    docker exec "${KAFKA_CONTAINER}" "${KAFKA_TOPICS}" "$@"
  else
    "${KAFKA_TOPICS}" "$@"
  fi
}

echo "Initializing Kafka topics for OSA sample stream..."
echo "Bootstrap server: ${BOOTSTRAP_SERVER}"
if [ "${USE_DOCKER_EXEC}" = "Y" ]; then
  echo "Kafka command: docker exec ${KAFKA_CONTAINER} ${KAFKA_TOPICS}"
else
  echo "Kafka command: ${KAFKA_TOPICS}"
fi

topic_exists() {
  local topic="$1"

  kafka_topics \
    --bootstrap-server "${BOOTSTRAP_SERVER}" \
    --list \
  | grep -Fxq "${topic}"
}

for topic in "${DELETE_TOPICS[@]}"; do
  echo "==> ${topic}: delete if exists"
  kafka_topics \
    --bootstrap-server "${BOOTSTRAP_SERVER}" \
    --delete \
    --if-exists \
    --topic "${topic}"
done

deadline=$(( $(date '+%s') + DELETE_WAIT_SECONDS ))
for topic in "${DELETE_TOPICS[@]}"; do
  while topic_exists "${topic}"; do
    if [ "$(date '+%s')" -ge "${deadline}" ]; then
      echo "WARN: ${topic}: still visible after delete request; create step will use --if-not-exists"
      break
    fi
    sleep 1
  done
done

for topic in "${CREATE_TOPICS[@]}"; do
  echo "==> ${topic}: create"
  kafka_topics \
    --bootstrap-server "${BOOTSTRAP_SERVER}" \
    --create \
    --if-not-exists \
    --topic "${topic}" \
    --partitions "${PARTITIONS}" \
    --replication-factor "${REPLICATION_FACTOR}"
done

echo "Current OSA Kafka topics:"
kafka_topics \
  --bootstrap-server "${BOOTSTRAP_SERVER}" \
  --list \
| grep -E '(^|[.])(CFUND_DT)$' || true

echo "Kafka topics initialized."
