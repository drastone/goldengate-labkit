#!/bin/bash
set -euo pipefail

TARGET_ORDS_PORT="${TARGET_ORDS_PORT:-36080}"
ORDS_READY_RETRIES="${ORDS_READY_RETRIES:-6}"
ORDS_READY_WAIT_SECONDS="${ORDS_READY_WAIT_SECONDS:-10}"

printf "Start Chapter 20 Data Fabric Console minimum containers\n"
printf "Host: "; uname -n
printf "\n"

printf "Stop containers that are not required for the Chapter 20 metadata path.\n"
docker stop \
  demo_centos \
  demo_minio \
  demo_iceberg_catalog \
  demo_trino \
  demo_iceberg_writer \
  demo_gold_dashboard \
  demo_pyiceberg_writer \
  demo_flink_writer \
  demo_ksqldb \
  demo_logstash \
  demo_kibana \
  demo_grafana \
  demo_influxdb \
  demo_flink_tm \
  demo_flink \
  demo_es \
  >/dev/null 2>&1 || true

printf "\nStart required containers.\n"
docker start demo_osrc_23ai demo_otrg_23ai demo_ogg_23ai demo_oggbd_23ai

wait_for_healthy() {
  name="$1"

  for _ in $(seq 1 45); do
    status=$(docker inspect -f "{{.State.Health.Status}}" "$name" 2>/dev/null || echo none)
    if [ "$status" = "healthy" ]; then
      printf "OK: %s is healthy.\n" "$name"
      return 0
    fi
    sleep 2
  done

  printf "WARN: %s did not report healthy yet.\n" "$name"
}

printf "\nWait for database and GoldenGate containers to become healthy.\n"
wait_for_healthy demo_osrc_23ai
wait_for_healthy demo_otrg_23ai
wait_for_healthy demo_ogg_23ai

printf "\nStart or verify Data Fabric apply helper.\n"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if docker exec -i demo_ogg_23ai bash -lc 'test -x /u01/ogg/scripts/startup/98_start_fabric_apply_service.sh' >/dev/null 2>&1; then
  docker exec -i -u root demo_ogg_23ai bash -lc '/u01/ogg/scripts/startup/98_start_fabric_apply_service.sh'
elif [ -x "${SCRIPT_DIR}/start_fabric_apply_service.sh" ]; then
  "${SCRIPT_DIR}/start_fabric_apply_service.sh"
else
  printf "WARN: %s is not executable. Set Table/Remove Table can still create previews, but immediate apply needs this helper.\n" "${SCRIPT_DIR}/start_fabric_apply_service.sh"
fi

printf "\nStart or verify Target ORDS/APEX.\n"
docker exec -d -u oracle demo_otrg_23ai bash -lc '
  if [ -x /home/oracle/apex/start_ords.sh ]; then
    exec /home/oracle/apex/start_ords.sh
  fi
  if [ -x /home/oracle/script/apex/start_ords.sh ]; then
    exec /home/oracle/script/apex/start_ords.sh
  fi
  ORDS_HOME=/home/oracle/ords
  if [ ! -x "${ORDS_HOME}/bin/ords" ] && [ -x /home/oracle/ords_new/bin/ords ]; then
    ORDS_HOME=/home/oracle/ords_new
  fi
  JAVA_HOME=/usr/java/jdk-17 PATH=/usr/java/jdk-17/bin:"${ORDS_HOME}/bin":$PATH \
    exec "${ORDS_HOME}/bin/ords" --config /home/oracle/ords_config serve
' >/dev/null

for attempt in $(seq 1 "${ORDS_READY_RETRIES}"); do
  if curl --max-time 10 -fsS -L -o /dev/null "http://127.0.0.1:${TARGET_ORDS_PORT}/ords/" 2>/dev/null &&
     curl --max-time 10 -fsS -L -o /dev/null "http://127.0.0.1:${TARGET_ORDS_PORT}/i/apex_version.txt" 2>/dev/null; then
    printf "OK: Target ORDS/APEX is ready on http://localhost:%s/ords/\n" "${TARGET_ORDS_PORT}"
    break
  fi

  if [ "$attempt" -eq "${ORDS_READY_RETRIES}" ]; then
    printf "WARN: Target ORDS/APEX is not ready yet. Check demo_otrg_23ai ORDS logs if the browser does not open.\n"
  else
    printf "WAIT: Target ORDS/APEX is starting. retry %s/%s\n" "$attempt" "${ORDS_READY_RETRIES}"
    sleep "${ORDS_READY_WAIT_SECONDS}"
  fi
done

printf "\nCurrent Chapter 20 containers:\n"
docker ps --format "table {{.Names}}\t{{.Status}}" |
  egrep "NAMES|demo_osrc_23ai|demo_otrg_23ai|demo_ogg_23ai|demo_oggbd_23ai" || true

printf "\nGoldenGate Integrated Console URL:\n"
printf "  http://localhost:%s/ords/r/ogg/goldengate-console\n" "${TARGET_ORDS_PORT}"
