#!/bin/bash
set -euo pipefail

LAB_DIR=/home/oracle/labs/lab19
PORT=${GOLD_DASHBOARD_PORT:-39119}
HTML_FILE="${LAB_DIR}/gold_channel_action_dashboard.html"

if [ ! -f "${HTML_FILE}" ]; then
  echo "Dashboard HTML not found: ${HTML_FILE}"
  echo "Run build_gold_dashboard.sh first."
  exit 1
fi

docker rm -f demo_gold_dashboard >/dev/null 2>&1 || true

docker run -d --name demo_gold_dashboard \
  -p 127.0.0.1:${PORT}:8000 \
  -v "${LAB_DIR}:/site:ro" \
  oracle-demo_pyiceberg_writer \
  python -m http.server 8000 --directory /site

sleep 2
docker ps --filter name=demo_gold_dashboard --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo
echo "Gold Dashboard URL:"
echo "  http://localhost:${PORT}/gold_channel_action_dashboard.html"
