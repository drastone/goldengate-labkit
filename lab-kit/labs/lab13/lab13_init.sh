#!/usr/bin/env bash

if [ -z "${BASH_VERSION:-}" ] || shopt -qo posix 2>/dev/null; then
  if command -v bash >/dev/null 2>&1; then
    exec bash "$0" "$@"
  fi
  echo "ERROR: lab13_init.sh requires bash." >&2
  exit 1
fi

set -Eeuo pipefail

LAB13_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_HOME="${LAB_HOME:-$(cd "${LAB13_DIR}/../.." && pwd)}"
LAB_LOGGING="${LAB_HOME}/troubleshooting/scripts/lab_init_logging.sh"
LAB12_INIT="${LAB12_INIT:-${LAB13_DIR}/../lab12/lab12_init.sh}"
MODE="${1:-base}"

case "${MODE}" in
  base)
    [ "$#" -eq 0 ] || shift
    ;;
  migration)
    shift
    ;;
  *)
    echo "ERROR: unsupported Chapter 13 mode: ${MODE}" >&2
    echo "Usage: sh lab13_init.sh [migration]" >&2
    exit 2
    ;;
esac

for file in "${LAB_LOGGING}" "${LAB12_INIT}"; do
  if [ ! -f "${file}" ]; then
    echo "ERROR: required Chapter 13 component is missing: ${file}" >&2
    exit 1
  fi
done

if [ "${MODE}" = migration ]; then
  MYSQL_START="${LAB_HOME}/startMySQL.sh"
  OGGMYSQL_START="${LAB_HOME}/mysql/oggmysql/start_oggmysql.sh"
  MYSQL_CONFIG="${LAB_HOME}/mysql/oggmysql/configure_mysql_replication.sh"
  MONGO_ROOT="${LAB_HOME}/oracle/script/mongodb"

  for file in "${MYSQL_START}" "${OGGMYSQL_START}" "${MYSQL_CONFIG}" \
    "${MONGO_ROOT}/create_mongodb_lab.sh" \
    "${MONGO_ROOT}/prepare_mongodb_dependencies.sh" \
    "${MONGO_ROOT}/configure_mongodb_replication.sh"; do
    if [ ! -f "${file}" ]; then
      echo "ERROR: required Chapter 13 migration component is missing: ${file}" >&2
      exit 1
    fi
  done
fi

source "${LAB_LOGGING}"
lab_init_log_begin lab13 lab13-init

echo "Chapter 13 prepares the GoldenGate Integrated Console migration runtime."
echo "Base containers:"
echo "  - demo_osrc_23ai / demo_otrg_23ai : Oracle migration and APEX/ORDS"
echo "  - demo_ogg_23ai                    : GoldenGate Hub"
echo "MySQL and MongoDB containers remain stopped until their migration exercise."
echo "Mode: ${MODE}"
echo

echo "Stop unrelated demo containers to release notebook memory."
required=' demo_osrc_23ai demo_otrg_23ai demo_ogg_23ai '
docker ps --format '{{.Names}}' | while IFS= read -r name; do
  case "${name}" in
    demo_*)
      if [[ "${required}" != *" ${name} "* ]]; then
        docker stop "${name}" >/dev/null
        echo "STOP: ${name}"
      fi
      ;;
  esac
done

echo
echo "Start Source and Target databases for the Chapter 12 prerequisite."
docker start demo_osrc_23ai demo_otrg_23ai >/dev/null
for container in demo_osrc_23ai demo_otrg_23ai; do
  for attempt in $(seq 1 60); do
    status="$(docker inspect -f '{{.State.Health.Status}}' "${container}" 2>/dev/null || true)"
    [ "${status}" = healthy ] && break
    [ "${status}" = unhealthy ] && break
    sleep 5
  done
  if [ "${status}" != healthy ]; then
    echo "ERROR: ${container} did not become healthy." >&2
    exit 1
  fi
  echo "OK: ${container} is healthy."
done

echo
echo "Prepare Oracle APEX/ORDS prerequisites."
bash "${LAB12_INIT}" "$@"

if [ "${MODE}" = migration ]; then
  echo
  echo "Switch to the MySQL and MongoDB migration runtime."
  for container in demo_osrc_23ai demo_ogg_23ai; do
    if [ "$(docker inspect -f '{{.State.Running}}' "${container}" 2>/dev/null || true)" = true ]; then
      docker stop "${container}" >/dev/null
      echo "STOP: ${container}"
    fi
  done

  bash "${MYSQL_START}"
  bash "${MONGO_ROOT}/create_mongodb_lab.sh"
  bash "${OGGMYSQL_START}"

  echo "Start GoldenGate Big Data for MongoDB."
  docker start demo_oggbd_23ai >/dev/null
  for attempt in $(seq 1 60); do
    status="$(docker inspect -f '{{.State.Health.Status}}' demo_oggbd_23ai 2>/dev/null || true)"
    [ "${status}" = healthy ] && break
    [ "${status}" = unhealthy ] && break
    sleep 5
  done
  if [ "${status}" != healthy ]; then
    echo "ERROR: demo_oggbd_23ai did not become healthy." >&2
    exit 1
  fi
  echo "OK: demo_oggbd_23ai is healthy."

  bash "${MONGO_ROOT}/prepare_mongodb_dependencies.sh"

  echo
  echo "Configure and verify MySQL capture/apply."
  bash "${MYSQL_CONFIG}"

  echo
  echo "Configure and verify MongoDB capture/apply."
  bash "${MONGO_ROOT}/configure_mongodb_replication.sh"

  display_pattern='NAMES|demo_(otrg|mysql|myheat|oggmysql_23ai|mongo_src|mongo_trg|oggbd_23ai)'
else
  echo
  echo "Start GoldenGate Hub."
  docker start demo_ogg_23ai >/dev/null
  for container in demo_ogg_23ai; do
    for attempt in $(seq 1 60); do
      status="$(docker inspect -f '{{.State.Health.Status}}' "${container}" 2>/dev/null || true)"
      [ "${status}" = healthy ] && break
      [ "${status}" = unhealthy ] && break
      sleep 5
    done
    if [ "${status}" != healthy ]; then
      echo "ERROR: ${container} did not become healthy." >&2
      exit 1
    fi
    echo "OK: ${container} is healthy."
  done

  display_pattern='NAMES|demo_(osrc|otrg|ogg_23ai)'
fi

echo
echo "Current Chapter 13 containers:"
docker ps --filter name=demo_ --format 'table {{.Names}}\t{{.Status}}' | \
  grep -E "${display_pattern}"
echo
docker stats --no-stream --format 'table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.PIDs}}' | \
  grep -E "${display_pattern}"

echo
if [ "${MODE}" = migration ]; then
  echo "OK: Chapter 13 online appendix MySQL and MongoDB migration runtime is ready."
  echo "INFO: Oracle Source and GoldenGate Hub are stopped to release memory."
else
  echo "OK: Chapter 13 base migration runtime is ready."
  echo "INFO: MySQL and MongoDB migration exercises are provided in the online appendix."
fi
echo "NEXT: import App 101 manually as shown in Chapter 13, then open:"
echo "  http://localhost:36080/ords/r/ogg/goldengate-console"
lab_init_log_finish
