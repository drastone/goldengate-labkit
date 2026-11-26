#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "${SCRIPT_DIR}"

echo "Prepare Chapter 7 Source business objects"
bash "${SCRIPT_DIR}/prepare_osa_source_objects.sh" --core-only
bash "${SCRIPT_DIR}/check_source_business_objects.sh"

echo "OK: Chapter 7 Source business objects are ready."
