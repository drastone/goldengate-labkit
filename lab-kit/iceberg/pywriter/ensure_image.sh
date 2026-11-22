#!/usr/bin/env sh
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
IMAGE="${PYICEBERG_WRITER_IMAGE:-oracle-demo_pyiceberg_writer:latest}"

if docker image inspect "$IMAGE" >/dev/null 2>&1; then
  echo "OK: PyIceberg writer image is ready: $IMAGE"
  exit 0
fi

if [ ! -f "${SCRIPT_DIR}/Dockerfile" ] || \
   [ ! -f "${SCRIPT_DIR}/requirements.txt" ] || \
   [ ! -f "${SCRIPT_DIR}/requirements.lock" ]; then
  echo "ERROR: PyIceberg writer build context is incomplete: ${SCRIPT_DIR}" >&2
  echo "ERROR: Dockerfile, requirements.txt, and requirements.lock are required." >&2
  exit 1
fi

echo "==> Build the missing Chapter 19 PyIceberg writer image"
echo "INFO: image: $IMAGE"
echo "INFO: build context: ${SCRIPT_DIR}"
docker build -t "$IMAGE" "$SCRIPT_DIR"

if ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
  echo "ERROR: PyIceberg writer image was not created: $IMAGE" >&2
  exit 1
fi

echo "OK: PyIceberg writer image is ready: $IMAGE"
