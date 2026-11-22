#!/bin/bash
set -euo pipefail

ROWS=${1:-20}
INTERVAL=${2:-1}

printf "Generate source business events\n"
printf "Host      : "; uname -n
printf "Container : demo_osrc_23ai\n"
printf "Script    : /home/oracle/script/osa/23ai/gen_base.sh %s %s\n\n" "$ROWS" "$INTERVAL"

docker exec demo_osrc_23ai bash -lc "cd /home/oracle/script/osa/23ai && sh gen_base.sh ${ROWS} ${INTERVAL}" 2>&1 \
  | sed '/^nohup: appending output to/d'

printf "\nSource event generation command completed.\n"
