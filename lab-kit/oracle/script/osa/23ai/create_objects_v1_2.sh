#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "INFO: create_objects_v1_2.sh is a compatibility wrapper."
echo "INFO: running prepare_osa_source_objects.sh"
exec bash "${SCRIPT_DIR}/prepare_osa_source_objects.sh" "$@"
