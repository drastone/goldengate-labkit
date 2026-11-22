#!/usr/bin/env bash
set -u

LAB_HOME="${LAB_HOME:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
REMOVE_CONTAINERS=N

usage() {
  cat <<'USAGE'
Usage:
  sh stopDocker.sh        Stop Lab Kit containers only.
  sh stopDocker.sh --rm   Stop and remove Lab Kit containers.

The --rm option removes containers, but it does not remove Docker images,
volumes, or product media files under oracle/pkg and centos/pkg.
USAGE
}

case "${1:-}" in
  "")
    ;;
  --rm|--remove)
    REMOVE_CONTAINERS=Y
    ;;
  -h|--help)
    usage
    exit 0
    ;;
  *)
    echo "ERROR: unknown option: $1"
    usage
    exit 1
    ;;
esac

CONTAINERS="${CONTAINERS:-\
demo_pyiceberg_writer \
demo_flink_writer \
demo_ksqldb \
demo_logstash \
demo_kibana \
demo_grafana \
demo_influxdb \
demo_trino \
demo_iceberg_catalog \
demo_minio \
demo_myheat \
demo_mysql \
demo_flink_tm \
demo_flink \
demo_es \
demo_centos \
demo_oggbd_23ai \
demo_ogg_23ai \
demo_otrg_23ai \
demo_osrc_23ai}"

echo "==> Stop Lab Kit containers"
echo "==> Lab Kit home: ${LAB_HOME}"
if [ "${REMOVE_CONTAINERS}" = "Y" ]; then
  echo "==> Remove mode: containers will be removed after stop"
fi

for container in ${CONTAINERS}; do
  if ! docker inspect "${container}" >/dev/null 2>&1; then
    echo "WARN: ${container}: container not found"
    continue
  fi

  status="$(docker inspect -f '{{.State.Status}}' "${container}" 2>/dev/null || true)"
  if [ "${status}" != "running" ]; then
    echo "OK: ${container}: already ${status}"
    continue
  fi

  echo "==> docker stop ${container}"
  if docker stop "${container}" >/dev/null; then
    echo "OK: ${container}: stopped"
  else
    echo "WARN: ${container}: stop failed"
  fi
done

if [ "${REMOVE_CONTAINERS}" = "Y" ]; then
  echo "==> Remove Lab Kit containers"
  for container in ${CONTAINERS}; do
    if ! docker inspect "${container}" >/dev/null 2>&1; then
      continue
    fi

    status="$(docker inspect -f '{{.State.Status}}' "${container}" 2>/dev/null || true)"
    if [ "${status}" = "running" ]; then
      echo "WARN: ${container}: still running; skip remove"
      continue
    fi

    echo "==> docker rm ${container}"
    if docker rm "${container}" >/dev/null; then
      echo "OK: ${container}: removed"
    else
      echo "WARN: ${container}: remove failed"
    fi
  done
fi

echo "OK: Lab Kit stop completed."
