#!/usr/bin/env bash

set -Eeuo pipefail

LAB12_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB12_ROLE="${1:?usage: lab12_setup_db.sh source|target CONTAINER HOST_ORDS_PORT}"
TARGET_DB_CONTAINER="${2:?usage: lab12_setup_db.sh source|target CONTAINER HOST_ORDS_PORT}"
HOST_ORDS_PORT="${3:?usage: lab12_setup_db.sh source|target CONTAINER HOST_ORDS_PORT}"

case "${LAB12_ROLE}" in
  source|target) ;;
  *)
    echo "ERROR: role must be source or target: ${LAB12_ROLE}" >&2
    exit 2
    ;;
esac

export LAB12_ROLE TARGET_DB_CONTAINER HOST_ORDS_PORT
export LAB12_LOG_DIR="${LAB12_LOG_DIR:-$(cd "${LAB12_DIR}/../.." && pwd)/logs/lab12/${LAB12_ROLE}}"

echo "==> Configure ${LAB12_ROLE} APEX/ORDS: ${TARGET_DB_CONTAINER}, host port ${HOST_ORDS_PORT}"
bash "${LAB12_DIR}/lab12_prepare_media.sh"
bash "${LAB12_DIR}/lab12_install_apex.sh"
bash "${LAB12_DIR}/lab12_install_ords.sh"
bash "${LAB12_DIR}/lab12_configure_workspace.sh"

if [ "${LAB12_ROLE}" = "source" ]; then
  bash "${LAB12_DIR}/lab12_configure_source_apps.sh"
  export APEX_EXPECTED_APP_IDS=100,102,110,120,130,140
fi

bash "${LAB12_DIR}/check_lab12.sh"
