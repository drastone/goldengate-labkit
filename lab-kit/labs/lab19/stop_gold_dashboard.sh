#!/bin/bash
set -euo pipefail

docker rm -f demo_gold_dashboard >/dev/null 2>&1 || true
echo "demo_gold_dashboard stopped."
