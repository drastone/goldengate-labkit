#!/bin/sh
set -eu

# Host/Base Linux wrapper for the Kafka reset helper inside demo_centos.

BIGDATA_CONTAINER="${BIGDATA_CONTAINER:-demo_centos}"
CONTAINER_SCRIPT="${CONTAINER_SCRIPT:-/u01/reset_osa_kafka_topics.sh}"
KAFKA_HOME="${KAFKA_HOME:-/usr/local/kafka}"
BOOTSTRAP_SERVER="${BOOTSTRAP_SERVER:-localhost:9092}"
PARTITIONS="${PARTITIONS:-1}"
REPLICATION_FACTOR="${REPLICATION_FACTOR:-1}"
DELETE_WAIT_SECONDS="${DELETE_WAIT_SECONDS:-30}"
TOPICS="${TOPICS:-}"

if ! docker inspect "${BIGDATA_CONTAINER}" >/dev/null 2>&1; then
  echo "ERROR: container not found: ${BIGDATA_CONTAINER}" >&2
  exit 1
fi

if ! docker exec -u root "${BIGDATA_CONTAINER}" test -x "${CONTAINER_SCRIPT}"; then
  echo "ERROR: container helper not found: ${BIGDATA_CONTAINER}:${CONTAINER_SCRIPT}" >&2
  echo "Rebuild or update demo_centos with the current Lab Kit." >&2
  exit 1
fi

docker exec -u root \
  -e KAFKA_HOME="${KAFKA_HOME}" \
  -e BOOTSTRAP_SERVER="${BOOTSTRAP_SERVER}" \
  -e PARTITIONS="${PARTITIONS}" \
  -e REPLICATION_FACTOR="${REPLICATION_FACTOR}" \
  -e DELETE_WAIT_SECONDS="${DELETE_WAIT_SECONDS}" \
  -e TOPICS="${TOPICS}" \
  "${BIGDATA_CONTAINER}" "${CONTAINER_SCRIPT}"
