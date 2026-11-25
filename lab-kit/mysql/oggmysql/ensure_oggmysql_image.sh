#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_HOME="${LAB_HOME:-$(cd "${SCRIPT_DIR}/../.." && pwd)}"
IMAGE="${OGGMYSQL_IMAGE:-oracle/goldengate:23.26.1-mysql}"
BASE_IMAGE="${OGGMYSQL_BASE_IMAGE:-oraclelinux:8@sha256:732d62107de9413a8a5f26912a9692d8a8dfe29e3774d7c907d4a19c4179d392}"
INSTALLER_NAME="${OGGMYSQL_INSTALLER_NAME:-V1054821-01.zip}"
INSTALLER="${OGGMYSQL_INSTALLER:-${LAB_HOME}/mysql/pkg/${INSTALLER_NAME}}"
INSTALLER_SHA256="${OGGMYSQL_INSTALLER_SHA256:-b7a8c250159e86d8020496bc656940b771c612609715c212480e18b475e24999}"
BUILD_CONTEXT="${OGGMYSQL_BUILD_CONTEXT:-${LAB_HOME}/docker-images/OracleGoldenGate/23}"
CONTEXT_INSTALLER="${BUILD_CONTEXT}/${INSTALLER_NAME}"
REMOVE_CONTEXT_INSTALLER=N

cleanup() {
  if [ "${REMOVE_CONTEXT_INSTALLER}" = Y ]; then
    rm -f "${CONTEXT_INSTALLER}"
  fi
}
trap cleanup EXIT

if docker image inspect "${IMAGE}" >/dev/null 2>&1; then
  echo "OK: GoldenGate for MySQL image is ready: ${IMAGE}"
  exit 0
fi

for file in "${INSTALLER}" "${BUILD_CONTEXT}/Dockerfile" \
  "${BUILD_CONTEXT}/install-deployment.sh" "${BUILD_CONTEXT}/install-prerequisites.sh"; do
  if [ ! -f "${file}" ]; then
    echo "ERROR: GoldenGate for MySQL image dependency is missing: ${file}" >&2
    exit 1
  fi
done

actual_sha256="$(sha256sum "${INSTALLER}" | awk '{print $1}')"
if [ "${actual_sha256}" != "${INSTALLER_SHA256}" ]; then
  echo "ERROR: unexpected SHA-256 for ${INSTALLER}" >&2
  echo "ERROR: expected ${INSTALLER_SHA256}" >&2
  echo "ERROR: actual   ${actual_sha256}" >&2
  exit 1
fi

if [ "${INSTALLER}" != "${CONTEXT_INSTALLER}" ]; then
  rm -f "${CONTEXT_INSTALLER}"
  if ! ln "${INSTALLER}" "${CONTEXT_INSTALLER}" 2>/dev/null; then
    cp "${INSTALLER}" "${CONTEXT_INSTALLER}"
  fi
  REMOVE_CONTEXT_INSTALLER=Y
fi

echo "Build pinned GoldenGate for MySQL image: ${IMAGE}"
docker build \
  --tag "${IMAGE}" \
  --build-arg "BASE_IMAGE=${BASE_IMAGE}" \
  --build-arg "INSTALLER=${INSTALLER_NAME}" \
  "${BUILD_CONTEXT}"

docker image inspect "${IMAGE}" >/dev/null
echo "OK: GoldenGate for MySQL image is ready: ${IMAGE}"
