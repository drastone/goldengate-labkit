#!/bin/bash
set -euo pipefail

LAB_HOME="${LAB_HOME:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
OGG_USER=${OGG_USER:-oggadmin}
OGG_PASSWORD=${OGG_PASSWORD:-WElcome1234##}

printf "Start Chapter 19 Lakehouse minimum containers\n"
printf "Host: "; uname -n
printf "\n"

printf "Stop containers that are not required for the Chapter 19 Data Streams path.\n"
docker stop demo_otrg_23ai demo_oggbd_23ai demo_centos demo_trino >/dev/null 2>&1 || true

printf "\nStart required containers.\n"
docker start demo_osrc_23ai demo_ogg_23ai
sh "${LAB_HOME}/startLakehouse.sh"

printf "\nWait for Source DB and GoldenGate Hub to become healthy.\n"
for name in demo_osrc_23ai demo_ogg_23ai; do
  for i in $(seq 1 30); do
    status=$(docker inspect -f "{{.State.Health.Status}}" "$name" 2>/dev/null || echo none)
    if [ "$status" = "healthy" ]; then
      printf "OK: %s is healthy.\n" "$name"
      break
    fi
    sleep 2
  done
done

printf "\nStart GoldenGate Extract C01 for Data Streams.\n"
curl -sS --max-time 20 -u "${OGG_USER}:${OGG_PASSWORD}" \
  -H "Content-Type: application/json" \
  -X PATCH http://localhost:9112/services/v2/extracts/C01 \
  -d '{"status":"running"}' >/tmp/lab19_start_c01.out 2>&1 || true
sleep 3
c01_status=$(curl -sS --max-time 10 -u "${OGG_USER}:${OGG_PASSWORD}" \
  http://localhost:9112/services/v2/extracts/C01 \
  | sed -n 's/.*"status":"\([^"]*\)".*/\1/p' | head -1)
if [ "${c01_status}" = "running" ]; then
  printf "OK: C01 is running.\n"
else
  printf "WARN: C01 status is %s.\n" "${c01_status:-unknown}"
  cat /tmp/lab19_start_c01.out
fi

printf "\nCurrent Chapter 19 containers:\n"
docker ps --format "table {{.Names}}\t{{.Status}}" | egrep "NAMES|demo_osrc_23ai|demo_ogg_23ai|demo_minio|demo_iceberg_catalog|demo_iceberg_writer|demo_trino" || true
