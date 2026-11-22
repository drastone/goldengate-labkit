#!/bin/bash
set -euo pipefail

printf "Stop Chapter 19 Iceberg writer\n"
printf "Host: "; uname -n
printf "\n"

if docker inspect demo_iceberg_writer >/dev/null 2>&1; then
  docker rm -f demo_iceberg_writer >/dev/null
  printf "OK: demo_iceberg_writer stopped and removed.\n"
else
  printf "OK: demo_iceberg_writer is not present.\n"
fi
