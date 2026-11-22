#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ogg_trail_dump.sh [-n NUM] [-v] [-D] ["logdump option" ...] TRAIL [TRAIL ...]

Dump GoldenGate trail records through logdump.
LOGDUMP can point to an explicit logdump binary. If not set, the script checks
PATH and common GoldenGate client homes.

Options:
  -n NUM  Limit records printed per trail. Default: count records and print all.
  -v      Verbose logdump detail settings.
  -D      Print generated logdump commands only.
  -h      Show help.
EOF
}

resolve_logdump() {
  local candidate
  if [[ -n "${LOGDUMP:-}" && -x "${LOGDUMP:-}" ]]; then
    printf '%s\n' "$LOGDUMP"
    return 0
  fi
  for candidate in ./logdump "$(dirname "$PWD")/logdump" /u01/app/ogg/ogg*/bin/logdump /u01/ogg/bin/logdump; do
    if [[ -x "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done
  if command -v logdump >/dev/null 2>&1; then
    command -v logdump
    return 0
  fi
  echo "ERROR: logdump not found. Set LOGDUMP=/path/to/logdump." >&2
  return 1
}

LOGDUMP_BIN="$(resolve_logdump)"
commands_only=""
max_num=""
trails=()
opts=(
  "ghdr on"
  "detail data on"
  "usertoken detail on"
  "ggstoken detail on"
  "headertoken detail on"
  "detail on"
  "sfh"
  "fileheader detail"
)

while getopts hn:vD opt; do
  case "$opt" in
    h) usage; exit 0 ;;
    n) max_num=${OPTARG} ;;
    v) opts=("ghdr on" "detail data on" "usertoken detail on" "ggstoken detail on" "headertoken detail on" "detail on" "sfh" "fileheader detail") ;;
    D) commands_only=true ;;
    *) usage; exit 2 ;;
  esac
done
shift $((OPTIND - 1))

[[ $# -gt 0 ]] || { usage; exit 2; }

for arg in "$@"; do
  if [[ -f "$arg" ]]; then
    trails+=("$arg")
  else
    opts+=("$arg")
  fi
done

count_records() {
  local trail=$1
  printf 'count\n' | "$LOGDUMP_BIN" OPEN "$trail" 2>/dev/null \
    | awk '/has.*records/ { value=$(NF-1) } END { if (value ~ /^[0-9]+$/) print value; else print 0 }'
}

dump_trail() {
  local trail=$1
  if [[ -n "$commands_only" ]]; then
    printf 'OPEN %s\n' "$trail"
    cat
  else
    "$LOGDUMP_BIN" OPEN "$trail" | sed 's/^Logdump.*Logdump.*Logdump.*> *//; s/Logdump .*>/&\n/'
  fi
}

for trail in "${trails[@]}"; do
  if [[ ! -f "$trail" ]]; then
    echo "WARNING: trail file not found: $trail" >&2
    continue
  fi
  if [[ -n "$max_num" ]]; then
    num=$max_num
  else
    num="$(count_records "$trail")"
  fi
  [[ "$num" =~ ^[0-9]+$ ]] || num=0
  [[ -n "$commands_only" ]] || printf 'trail %s => print %s records\n' "$trail" "$num" >&2
  {
    for opt in "${opts[@]}"; do
      printf '%s\n' "$opt"
    done
    x=1
    while (( x++ <= num )); do
      printf 'next\n'
    done
  } | dump_trail "$trail"
done
