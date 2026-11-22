#!/bin/bash
set -euo pipefail

printf "Chapter 20 Data Fabric Console status\n"
printf "Host: "; uname -n
printf "\n"

printf "== containers ==\n"
docker ps --format "table {{.Names}}\t{{.Status}}" |
  egrep "NAMES|demo_osrc_23ai|demo_otrg_23ai|demo_ogg_23ai|demo_oggbd_23ai|demo_centos|demo_minio|demo_iceberg|demo_trino|demo_gold_dashboard" || true

printf "\n== resources ==\n"
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.PIDs}}" \
  demo_osrc_23ai demo_otrg_23ai demo_ogg_23ai demo_oggbd_23ai 2>/dev/null || true

printf "\n== target APEX/ORDS ==\n"
if curl --max-time 10 -fsS -L -o /dev/null http://127.0.0.1:36080/ords/; then
  printf "OK: http://localhost:36080/ords/\n"
else
  printf "WARN: http://localhost:36080/ords/ is not responding.\n"
fi
