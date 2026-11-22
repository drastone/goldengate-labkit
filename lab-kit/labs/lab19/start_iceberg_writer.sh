#!/bin/bash
set -euo pipefail

LAB_HOME="${LAB_HOME:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
LAB_DIR="${LAB_HOME}/labs/lab19"
WRITER_IMAGE="${PYICEBERG_WRITER_IMAGE:-oracle-demo_pyiceberg_writer:latest}"
WRITER_IMAGE_HELPER="${LAB_HOME}/iceberg/pywriter/ensure_image.sh"

if [ ! -f "${WRITER_IMAGE_HELPER}" ]; then
  echo "ERROR: Chapter 19 writer image helper not found: ${WRITER_IMAGE_HELPER}" >&2
  echo "ERROR: apply the latest Lab Kit release before retrying." >&2
  exit 1
fi

PYICEBERG_WRITER_IMAGE="${WRITER_IMAGE}" sh "${WRITER_IMAGE_HELPER}"

docker rm -f demo_iceberg_writer >/dev/null 2>&1 || true

docker run -d --name demo_iceberg_writer --network host \
  -v "${LAB_DIR}/ds_iceberg_writer.py:/app/ds_iceberg_writer.py:ro" \
  "${WRITER_IMAGE}" python /app/ds_iceberg_writer.py

sleep 3
docker logs --tail 20 demo_iceberg_writer
