#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ogg_trail_parse.sh [-A] [-d DELIM] [-n NUM] [-t] [-T] TRAIL [TRAIL ...]

Parse GoldenGate trail/logdump output into a compact 13-column file for
Oracle external-table analysis.

This is the single-file replacement for the old print-trail-info.sh +
print-trail-summary.sh pair. It calls logdump directly and then parses the
output in the same shell.

Options:
  -A        Input is an already dumped ASCII logdump file, not a binary trail.
  -d DELIM  Output delimiter. Default: |
  -n NUM    Limit records per binary trail while dumping through logdump.
  -t        Print a '# trail=...' marker before each trail.
  -T        Do not print trail marker. This is the default.
  -h        Show help.

Environment:
  LOGDUMP=/path/to/logdump   Explicit logdump binary.
  OGG_TRAIL_DIR=/path         Directory for bare trail names.
                            Default search includes current directory,
                            <script directory>/trails, and the OGG
                            Microservices deployment trail directory when
                            present.

Output columns are resv1..resv13, matching the Field Kit external table.
EOF
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_TRAIL_DIR="${OGG_TRAIL_DIR:-$SCRIPT_DIR/trails}"
DEFAULT_OGG_TRAIL_DIR="/u02/Deployment/var/lib/data"

type gawk >/dev/null 2>&1 && AWK=gawk || AWK=awk
delimiter='|'
is_binary_input=true
display_trail=false
record_limit=''

while getopts Ahd:n:tT opt; do
  case "$opt" in
    A) is_binary_input=false ;;
    d) delimiter=$OPTARG ;;
    n) record_limit=$OPTARG ;;
    t) display_trail=true ;;
    T) display_trail=false ;;
    h) usage; exit 0 ;;
    *) usage; exit 2 ;;
  esac
done
shift $((OPTIND - 1))
[[ $# -gt 0 ]] || { usage; exit 2; }

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

count_records() {
  local logdump_bin=$1
  local trail=$2
  printf 'count\n' | "$logdump_bin" OPEN "$trail" 2>/dev/null \
    | awk 'tolower($0) ~ /has.*records/ {
        for (i = 1; i <= NF; i++) {
          if ($i ~ /^[0-9]+$/ && tolower($(i + 1)) ~ /^records/) value = $i
        }
      }
      END { if (value ~ /^[0-9]+$/) print value; else print 0 }'
}


dump_binary_trail() {
  local logdump_bin=$1
  local trail=$2
  local num=$record_limit
  local opts=(
    "ghdr on"
    "detail data on"
    "usertoken detail on"
    "ggstoken detail on"
    "headertoken detail on"
    "detail on"
    "sfh"
    "fileheader detail"
  )
  if [[ -z "$num" ]]; then
    num="$(count_records "$logdump_bin" "$trail")"
  fi
  [[ "$num" =~ ^[0-9]+$ ]] || num=0
  printf 'trail %s => parse %s records\n' "$trail" "$num" >&2
  {
    for opt in "${opts[@]}"; do
      printf '%s\n' "$opt"
    done
    local x=1
    while (( x++ <= num )); do
      printf 'next\n'
    done
  } | "$logdump_bin" OPEN "$trail" \
    | sed 's/^Logdump.*Logdump.*Logdump.*> *//; s/Logdump .*>/&\n/'
}

do_summary1() {
  $AWK '/^Trans|^Undo|^20..\/|^Name:|^__/ { print $0 }'
}

do_strip2() {
  sed 's/^Undo.*After: */=/; s/^\(TransInd.*\) \((x[0-9]*)\) *FormatType.*/=\2/; s/^Name: /=/; s/^20..\//=&/'
}

do_paste3() {
  sed -e ':a' -e '$!N;s/\n=/ \* /;ta' -e 'P;D'
}

do_reorder4() {
  $AWK -F\* '{ print $3 "\t" $2 "\t" $4 "\t" $5 }'
}

emit_13_cols() {
  $AWK -v d="$delimiter" '{
    for (i = 1; i <= 13; i++) {
      value = (i <= NF ? $i : "")
      gsub(/[\r\n|]/, " ", value)
      printf "%s%s", value, (i < 13 ? d : ORS)
    }
  }'
}

parse_stream() {
  do_summary1 | do_strip2 | do_paste3 | do_reorder4 | emit_13_cols
}

expand_trail_arg() {
  local trail=$1
  local fname pattern dir
  if [[ "$trail" == */* ]]; then
    if [[ -f "$trail" ]]; then
      printf '%s\n' "$trail"
      return 0
    fi
    fname=${trail##*/}
    if [[ ! -e "$trail" && ${#fname} -eq 2 ]]; then
      pattern="${trail}?????????"
      compgen -G "$pattern" || true
      return 0
    fi
    printf '%s\n' "$trail"
    return 0
  fi

  if [[ -f "$trail" ]]; then
    printf '%s\n' "$trail"
    return 0
  fi
  for dir in "$DEFAULT_TRAIL_DIR" "$DEFAULT_OGG_TRAIL_DIR"; do
    [[ -d "$dir" ]] || continue
    if [[ -f "$dir/$trail" ]]; then
      printf '%s\n' "$dir/$trail"
      return 0
    fi
  done
  if [[ ${#trail} -eq 2 ]]; then
    for dir in "$DEFAULT_TRAIL_DIR" "$DEFAULT_OGG_TRAIL_DIR"; do
      [[ -d "$dir" ]] || continue
      compgen -G "$dir/$trail?????????" || true
    done
    compgen -G "$trail?????????" || true
    return 0
  fi
  printf '%s\n' "$trail"
}

process_ascii_dump() {
  local txt_file f
  for txt_file in "$@"; do
    while IFS= read -r f; do
      [[ -f "$f" ]] || { echo "ERROR: file not found: $f" >&2; continue; }
      $display_trail && printf '# trail=%s\n' "$f"
      cat "$f" | parse_stream
    done < <(expand_trail_arg "$txt_file")
  done
}

process_binary_trails() {
  local logdump_bin trail t
  logdump_bin="$(resolve_logdump)"
  for trail in "$@"; do
    while IFS= read -r t; do
      [[ -f "$t" ]] || { echo "ERROR: file not found: $t" >&2; continue; }
      $display_trail && printf '# trail=%s\n' "$t"
      dump_binary_trail "$logdump_bin" "$t" | parse_stream
    done < <(expand_trail_arg "$trail")
  done
}

if $is_binary_input; then
  process_binary_trails "$@"
else
  process_ascii_dump "$@"
fi
