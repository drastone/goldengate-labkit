#!/usr/bin/env bash
set -euo pipefail
exec "$(dirname "$0")/ogg_trail_parse.sh" "$@"
