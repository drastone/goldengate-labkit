#!/usr/bin/env bash

set -Eeuo pipefail

LAB12_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${LAB12_DIR}/lab12_common.sh"

lab12_begin_stage "lab12-reset"

CONFIRM_TEXT="RESET-LAB12-${TARGET_PDB}"
if [ "${1:-}" != "--confirm" ] || [ "${2:-}" != "${CONFIRM_TEXT}" ]; then
  lab12_log "ERROR: this operation removes ORDS first and then APEX from ${TARGET_PDB}."
  lab12_log "ERROR: APEX applications and workspaces can be deleted."
  lab12_log "ERROR: run only when a full Chapter 12 reset is intended:"
  lab12_log "ERROR: bash lab12_reset.sh --confirm ${CONFIRM_TEXT}"
  exit 2
fi

bash "${LAB12_DIR}/remove_ords.sh" --confirm "REMOVE-ORDS-${TARGET_PDB}"
bash "${LAB12_DIR}/remove_apex.sh" --confirm "REMOVE-APEX-${TARGET_PDB}"

lab12_finish_stage
