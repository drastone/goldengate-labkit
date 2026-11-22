#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="${SCRIPT_DIR}/logs"
RUN_ID="$(date +%Y%m%d_%H%M%S)"
LOG_FILE="${LOG_DIR}/prepare_ai_26ai_demo_${RUN_ID}.log"

mkdir -p "${LOG_DIR}"
cd "${SCRIPT_DIR}"

START_EPOCH="$(date +%s)"
START_TIME="$(date '+%Y-%m-%d %H:%M:%S')"

echo "Preparing 26ai AI demo candidates..."
echo "Start time: ${START_TIME}"
echo "Log file: ${LOG_FILE}"

sqlplus -s soe/soe@orclpdb1 @"${SCRIPT_DIR}/prepare_ai_26ai_demo.sql" > "${LOG_FILE}" 2>&1

END_EPOCH="$(date +%s)"
END_TIME="$(date '+%Y-%m-%d %H:%M:%S')"
ELAPSED="$((END_EPOCH - START_EPOCH))"

echo "End time: ${END_TIME}"
echo "Elapsed time: ${ELAPSED} seconds"
echo "26ai AI demo candidates prepared."
