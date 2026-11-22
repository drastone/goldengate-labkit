#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ogg_trail_parse.sh [-A] [-d DELIM] [-n NUM] [-t] [-T] TRAIL [TRAIL ...]

Parse GoldenGate trail/logdump output into a compact 13-column file for
Oracle external-table analysis. This is a single-file replacement for the old
print-trail-info.sh + print-trail-summary.sh pair.

Options:
  -A        Input is an already dumped ASCII logdump file, not a binary trail.
  -d DELIM  Output delimiter. Default: |
  -n NUM    Limit records per binary trail while dumping through logdump.
  -t        Print a '# trail=...' marker before each trail.
  -T        Do not print trail marker. This is the default.
  -h        Show help.

Environment:
  LOGDUMP=/path/to/logdump   Explicit logdump binary.

Output columns are resv1..resv13, matching the Field Kit external table.
EOF
}

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

process_ascii_dump() {
  local txt_file
  for txt_file in "$@"; do
    [[ -f "$txt_file" ]] || { echo "ERROR: file not found: $txt_file" >&2; continue; }
    $display_trail && printf '# trail=%s\n' "$txt_file"
    cat "$txt_file" | parse_stream
  done
}

process_binary_trails() {
  local logdump_bin trail fname t
  logdump_bin="$(resolve_logdump)"
  for trail in "$@"; do
    fname=${trail##*/}
    if [[ ! -e "$trail" && ${#fname} -eq 2 ]]; then
      trail=${trail}??????
    fi
    for t in $trail; do
      [[ -f "$t" ]] || { echo "ERROR: file not found: $t" >&2; continue; }
      $display_trail && printf '# trail=%s\n' "$t"
      dump_binary_trail "$logdump_bin" "$t" | parse_stream
    done
  done
}

if $is_binary_input; then
  process_binary_trails "$@"
else
  process_ascii_dump "$@"
fi
