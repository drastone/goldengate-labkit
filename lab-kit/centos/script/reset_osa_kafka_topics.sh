#!/usr/bin/env bash
set -euo pipefail

KAFKA_HOME="${KAFKA_HOME:-/usr/local/kafka}"
BOOTSTRAP_SERVER="${BOOTSTRAP_SERVER:-localhost:9092}"
PARTITIONS="${PARTITIONS:-1}"
REPLICATION_FACTOR="${REPLICATION_FACTOR:-1}"
DELETE_WAIT_SECONDS="${DELETE_WAIT_SECONDS:-30}"

if [ -n "${TOPICS:-}" ]; then
  read -r -a CREATE_TOPICS <<<"${TOPICS}"
  DELETE_TOPICS=("${CREATE_TOPICS[@]}")
else
  CREATE_TOPICS=(
    "SOE.CFUND_DT"
    "ORCLPDB1.SOE.CFUND_DT"
  )
  DELETE_TOPICS=(
    "${CREATE_TOPICS[@]}"
    "FREEPDB1.SOE.CFUND_DT"
  )
fi

KAFKA_TOPICS="${KAFKA_HOME}/bin/kafka-topics.sh"

if [ ! -x "${KAFKA_TOPICS}" ]; then
  echo "ERROR: Kafka topic command not found: ${KAFKA_TOPICS}" >&2
  exit 1
fi

topic_exists() {
  local topic="$1"
  "${KAFKA_TOPICS}" --bootstrap-server "${BOOTSTRAP_SERVER}" --list |
    grep -Fxq "${topic}"
}

echo "Initializing Kafka topics for OSA sample stream..."
echo "Bootstrap server: ${BOOTSTRAP_SERVER}"

for topic in "${DELETE_TOPICS[@]}"; do
  echo "==> ${topic}: delete if exists"
  "${KAFKA_TOPICS}" \
    --bootstrap-server "${BOOTSTRAP_SERVER}" \
    --delete --if-exists \
    --topic "${topic}"
done

deadline=$(( $(date '+%s') + DELETE_WAIT_SECONDS ))
for topic in "${DELETE_TOPICS[@]}"; do
  while topic_exists "${topic}"; do
    if [ "$(date '+%s')" -ge "${deadline}" ]; then
      echo "WARN: ${topic}: still visible after delete request"
      break
    fi
    sleep 1
  done
done

for topic in "${CREATE_TOPICS[@]}"; do
  echo "==> ${topic}: create"
  "${KAFKA_TOPICS}" \
    --bootstrap-server "${BOOTSTRAP_SERVER}" \
    --create --if-not-exists \
    --topic "${topic}" \
    --partitions "${PARTITIONS}" \
    --replication-factor "${REPLICATION_FACTOR}"
done

echo "Current OSA Kafka topics:"
"${KAFKA_TOPICS}" --bootstrap-server "${BOOTSTRAP_SERVER}" --list |
  grep -E '(^|[.])CFUND_DT$' | sort || true

echo "Kafka topics initialized."
