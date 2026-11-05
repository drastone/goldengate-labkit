#!/usr/bin/env bash

set -Eeuo pipefail

LAB12_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${LAB12_DIR}/lab12_common.sh"

lab12_begin_stage "lab12-init"

lab12_log "INFO: Chapter 12 setup runs four idempotent stages."
lab12_log "INFO: prepare media -> install APEX -> install ORDS -> verify"

bash "${LAB12_DIR}/lab12_prepare_media.sh"
bash "${LAB12_DIR}/lab12_install_apex.sh"
bash "${LAB12_DIR}/lab12_install_ords.sh"
bash "${LAB12_DIR}/check_lab12.sh"

lab12_log "OK: Chapter 12 APEX/ORDS environment is ready."
lab12_log "NEXT: open http://localhost:36080/ords/apex_admin and create the OGG workspace."
lab12_finish_stage
