#!/usr/bin/env bash
set -eu

KAFKA_HOME="${KAFKA_HOME:-/usr/local/kafka}"
KAFKA_BOOTSTRAP="${KAFKA_BOOTSTRAP:-localhost:9092}"
KAFKA_TIMEOUT_MS="${KAFKA_TIMEOUT_MS:-30000}"

# Default to --from-beginning so a reader can confirm existing lab messages.
# Use KAFKA_FROM_BEGINNING=N to watch only messages produced after this consumer starts.
KAFKA_FROM_BEGINNING="${KAFKA_FROM_BEGINNING:-Y}"
TOPIC="${1:-SOE.EMPLOYEE}"

cmd=(
  "${KAFKA_HOME}/bin/kafka-console-consumer.sh"
  --bootstrap-server "${KAFKA_BOOTSTRAP}"
  --topic "${TOPIC}"
  --property print.key=true
  --timeout-ms "${KAFKA_TIMEOUT_MS}"
)

case "${KAFKA_FROM_BEGINNING}" in
  1|Y|y|YES|yes|TRUE|true|ON|on)
    cmd+=(--from-beginning)
    ;;
esac

if [ -n "${KAFKA_MAX_MESSAGES:-}" ]; then
  cmd+=(--max-messages "${KAFKA_MAX_MESSAGES}")
fi

exec "${cmd[@]}"
