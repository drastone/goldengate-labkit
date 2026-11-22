#!/bin/bash
set -euo pipefail
printf "Host: "; uname -n
printf "\n== containers ==\n"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | egrep "NAMES|demo_osrc_23ai|demo_ogg_23ai|demo_minio|demo_iceberg_catalog|demo_trino|demo_iceberg_writer" || true
printf "\n== resources ==\n"
names=""
for name in demo_osrc_23ai demo_ogg_23ai demo_minio demo_iceberg_catalog demo_iceberg_writer demo_trino; do
  if docker ps --format '{{.Names}}' | grep -qx "$name"; then
    names="$names $name"
  fi
done
if [ -n "$names" ]; then
  docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.PIDs}}" $names
else
  echo "No matching containers are running."
fi
printf "\n== writer logs ==\n"
docker logs --tail 10 demo_iceberg_writer 2>/dev/null || true
