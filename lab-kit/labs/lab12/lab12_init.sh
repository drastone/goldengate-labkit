#!/usr/bin/env bash

if [ -z "${BASH_VERSION:-}" ] || shopt -qo posix 2>/dev/null; then
  if command -v bash >/dev/null 2>&1; then
    exec bash "$0" "$@"
  fi
  echo "ERROR: lab12_init.sh requires bash." >&2
  exit 1
fi

set -Eeuo pipefail

LAB12_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${LAB12_DIR}/lab12_common.sh"

lab12_begin_stage "lab12-init"

lab12_log "INFO: Chapter 12 prepares APEX/ORDS on both reader-lab databases."
lab12_log "INFO: Source business apps -> http://localhost:35080/ords/"
lab12_log "INFO: Target information apps and OGG Console -> http://localhost:36080/ords/"

bash "${LAB12_DIR}/lab12_setup_db.sh" source demo_osrc_23ai 35080
bash "${LAB12_DIR}/lab12_setup_db.sh" target demo_otrg_23ai 36080

lab12_log "OK: Source and Target APEX/ORDS environments are ready."
lab12_log "NEXT: open Source http://localhost:35080/ords/ or Target http://localhost:36080/ords/apex."
lab12_finish_stage
