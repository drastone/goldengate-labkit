#!/usr/bin/env bash
set -euo pipefail

VERSION="0.2.3-sh"
DEFAULT_BASE_DIR="/u01/oracle/msa/util"
DEFAULT_CONFIG_NAME="my-ogg.json"

REST_TRAILS_PATH="/services/v2/trails"
COMMON_REST_PATHS=(
  "/services/v2/deployments"
  "/services/v2/extracts"
  "/services/v2/replicats"
  "/services/v2/trails"
  "/services/v2/exttrails"
  "/services/v2/tasks"
  "/services/v2/messages"
)
DEFAULT_LOGDUMP_SETTINGS=(
  "ghdr on"
  "detail data on"
  "usertoken detail on"
  "ggstoken detail on"
  "headertoken detail on"
)

CONFIG_PATH=""
TARGET_NAME="${OGG_FK_TARGET:-}"
OPT_MODE=""
OPT_SSH=""
OPT_CONTAINER=""
OPT_DOCKER=""
OPT_OGG_HOME=""
OPT_ADMIN_URL=""
OPT_ADMIN_USER=""
OPT_CLI_MODE=""
OPT_CLI_SSH=""
OPT_CLI_CONTAINER=""
OPT_CLI_DOCKER=""
OPT_CLIENT_OGG_HOME=""
OPT_ADMINCLIENT_PATH=""
OPT_LOGDUMP_PATH=""
OPT_ADMIN_CLIENT_URL=""
OPT_DOWNLOAD_DIR=""
OPT_DOWNLOAD_CLIENT_OGG_HOME=""
OPT_DOWNLOAD_LOGDUMP_PATH=""
OPT_ORACLE_SCHEMA=""
OPT_ORACLE_ADMIN_CONNECT=""
OPT_ORACLE_PDB=""
OPT_ORACLE_SQLPLUS=""
OPT_ORACLE_EXT_DIR=""
OPT_ORACLE_EXT_DIR_NAME=""
OPT_INSECURE=0
OPT_NO_AUTH=0
OPT_TIMEOUT=20
OPT_TRAIL_DIRS=()
OPT_CLI_TRAIL_DIRS=()
OPT_CLI_TRAIL_SEARCH_ROOTS=()
REMAINING_ARGS=()

T_NAME=""
T_MODE=""
T_SSH=""
T_CONTAINER=""
T_DOCKER=""
T_OGG_HOME=""
T_ADMIN_URL=""
T_ADMIN_USER=""
T_CLI_MODE=""
T_CLI_SSH=""
T_CLI_CONTAINER=""
T_CLI_DOCKER=""
T_CLIENT_OGG_HOME=""
T_ADMINCLIENT_PATH=""
T_LOGDUMP_PATH=""
T_ADMIN_CLIENT_URL=""
T_DOWNLOAD_DIR=""
T_DOWNLOAD_CLIENT_OGG_HOME=""
T_DOWNLOAD_LOGDUMP_PATH=""
T_ORACLE_SCHEMA=""
T_ORACLE_ADMIN_CONNECT=""
T_ORACLE_PDB=""
T_ORACLE_SQLPLUS=""
T_ORACLE_EXT_DIR=""
T_ORACLE_EXT_DIR_NAME=""
T_TRAIL_DIRS=()
T_CLI_TRAIL_DIRS=()
T_CLI_TRAIL_SEARCH_ROOTS=()

LAST_TRAIL_NAMES=()
LAST_TRAIL_SEQ=()
LAST_TRAIL_PRODUCERS=()
LAST_TRAIL_CONSUMERS=()

REST_PASSWORD_CACHE=""
REST_BODY_FILE=""
REST_STATUS=""
REST_RC=0

DOCKER_CMD=()

die() {
  echo "ERROR: $*" >&2
  exit 1
}

have() {
  command -v "$1" >/dev/null 2>&1
}

sq() {
  local s=${1-}
  printf "'%s'" "${s//\'/\'\\\'\'}"
}

array_literal() {
  local value
  for value in "$@"; do
    printf " %s" "$(sq "$value")"
  done
}

usage() {
  cat <<'EOF'
GoldenGate Field Kit shell-only edition

Usage:
  ./ogg_fk.sh [--config my-ogg.json] [--target NAME] COMMAND [options]

Commands:
  init-config [--output FILE] [--force]
  targets
  snapshot [--insecure] [--no-auth]
  rest-get PATH [--insecure] [--no-auth]
  trails-list [--limit N] [--resolve-files] [--files-per-trail N] [--no-resolve-files]
  trail-download --trail-name NAME --seq N|START-END [--download-dir DIR]
  download-logdump-shell --trail-name NAME --seq N [--download-dir DIR]
  download-logdump-shell --trail FILE
  download-logdump-run --trail-name NAME --seq N [--cmd CMD ...]
  trail-sql-analyze [--trail FILE ... | --trail-range NAME:START-END] [--schema USER] [--limit N]
  loaded-tx-analyze [--schema USER] [--threshold N] [--report FILE]
  admin-shell [--connect] [--connect-url URL] [--connect-user USER]
  logdump-shell [--trail PATH | --trail-name NAME --seq N]
  logdump-run [--trail PATH | --trail-name NAME --seq N] [--cmd CMD ...]
  menu

Notes:
  - No Python, no jq, and no web server are required.
  - REST features require curl.
  - Trail download uses Admin Service REST and stores the sequence on the client side before logdump analysis.
  - SQL analysis uses local sqlplus and a DB-visible filesystem directory; Docker is not part of the field workflow.
  - JSON parsing is intentionally lightweight for GoldenGate target config and trail metadata.
EOF
}

find_config() {
  if [[ -n "$CONFIG_PATH" ]]; then
    [[ -f "$CONFIG_PATH" ]] || die "Config not found: $CONFIG_PATH"
    return
  fi
  if [[ -n "${OGG_FK_CONFIG:-}" && -f "${OGG_FK_CONFIG:-}" ]]; then
    CONFIG_PATH="$OGG_FK_CONFIG"
  elif [[ -f "./$DEFAULT_CONFIG_NAME" ]]; then
    CONFIG_PATH="./$DEFAULT_CONFIG_NAME"
  elif [[ -f "$DEFAULT_BASE_DIR/$DEFAULT_CONFIG_NAME" ]]; then
    CONFIG_PATH="$DEFAULT_BASE_DIR/$DEFAULT_CONFIG_NAME"
  else
    CONFIG_PATH="./$DEFAULT_CONFIG_NAME"
  fi
}

target_names() {
  [[ -f "$CONFIG_PATH" ]] || return 0
  sed -n 's/^[[:space:]]*"\([^"]*\)"[[:space:]]*:[[:space:]]*{[[:space:]]*$/\1/p' "$CONFIG_PATH" \
    | grep -v '^targets$' \
    | sort
}

target_block() {
  local target=$1
  local in_target=0
  local line
  while IFS= read -r line; do
    if [[ $in_target -eq 0 ]]; then
      case "$line" in
        *\""$target"\"*:*{*) in_target=1; continue ;;
      esac
    else
      printf '%s\n' "$line"
      if [[ "$line" =~ ^[[:space:]]*\},?[[:space:]]*$ ]]; then
        break
      fi
    fi
  done < "$CONFIG_PATH"
}

target_exists() {
  [[ -n "$(target_block "$1" | head -n 1)" ]]
}

json_field() {
  local key=$1
  target_block "$T_NAME" \
    | sed -n "s/^[[:space:]]*\"$key\"[[:space:]]*:[[:space:]]*\"\(.*\)\"[,]*/\1/p" \
    | head -n 1
}

json_array() {
  local key=$1
  target_block "$T_NAME" | awk -v key="$key" '
    $0 ~ "\"" key "\"" {
      in_array=1
      next
    }
    in_array && /\]/ {
      exit
    }
    in_array {
      line=$0
      sub(/^[ \t]*"/, "", line)
      sub(/",?[ \t]*$/, "", line)
      if (line != "") print line
    }
  '
}

choose_target() {
  if [[ -n "$TARGET_NAME" ]]; then
    return
  fi
  if target_exists "default"; then
    TARGET_NAME="default"
  elif target_exists "source"; then
    TARGET_NAME="source"
  else
    TARGET_NAME="$(target_names | head -n 1)"
  fi
  [[ -n "$TARGET_NAME" ]] || TARGET_NAME="default"
}

load_target() {
  find_config
  [[ -f "$CONFIG_PATH" ]] || die "Config not found: $CONFIG_PATH. Run: ./ogg_fk.sh init-config"
  choose_target
  target_exists "$TARGET_NAME" || die "Unknown target '$TARGET_NAME'. Available: $(target_names | tr '\n' ' ')"

  T_NAME="$TARGET_NAME"
  T_MODE="$(json_field mode)"
  T_SSH="$(json_field ssh)"
  T_CONTAINER="$(json_field container)"
  T_DOCKER="$(json_field docker)"
  T_OGG_HOME="$(json_field ogg_home)"
  T_ADMIN_URL="$(json_field admin_url)"
  T_ADMIN_USER="$(json_field admin_user)"
  T_CLI_MODE="$(json_field cli_mode)"
  T_CLI_SSH="$(json_field cli_ssh)"
  T_CLI_CONTAINER="$(json_field cli_container)"
  T_CLI_DOCKER="$(json_field cli_docker)"
  T_CLIENT_OGG_HOME="$(json_field client_ogg_home)"
  T_ADMINCLIENT_PATH="$(json_field adminclient_path)"
  T_LOGDUMP_PATH="$(json_field logdump_path)"
  T_ADMIN_CLIENT_URL="$(json_field admin_client_url)"
  T_DOWNLOAD_DIR="$(json_field download_dir)"
  T_DOWNLOAD_CLIENT_OGG_HOME="$(json_field download_client_ogg_home)"
  T_DOWNLOAD_LOGDUMP_PATH="$(json_field download_logdump_path)"
  T_ORACLE_SCHEMA="$(json_field oracle_schema)"
  T_ORACLE_ADMIN_CONNECT="$(json_field oracle_admin_connect)"
  T_ORACLE_PDB="$(json_field oracle_pdb)"
  T_ORACLE_SQLPLUS="$(json_field oracle_sqlplus)"
  T_ORACLE_EXT_DIR="$(json_field oracle_ext_dir)"
  T_ORACLE_EXT_DIR_NAME="$(json_field oracle_ext_dir_name)"

  mapfile -t T_TRAIL_DIRS < <(json_array trail_dirs)
  mapfile -t T_CLI_TRAIL_DIRS < <(json_array cli_trail_dirs)
  mapfile -t T_CLI_TRAIL_SEARCH_ROOTS < <(json_array cli_trail_search_roots)

  [[ -n "$OPT_MODE" ]] && T_MODE="$OPT_MODE"
  [[ -n "$OPT_SSH" ]] && T_SSH="$OPT_SSH"
  [[ -n "$OPT_CONTAINER" ]] && T_CONTAINER="$OPT_CONTAINER"
  [[ -n "$OPT_DOCKER" ]] && T_DOCKER="$OPT_DOCKER"
  [[ -n "$OPT_OGG_HOME" ]] && T_OGG_HOME="$OPT_OGG_HOME"
  [[ -n "$OPT_ADMIN_URL" ]] && T_ADMIN_URL="$OPT_ADMIN_URL"
  [[ -n "$OPT_ADMIN_USER" ]] && T_ADMIN_USER="$OPT_ADMIN_USER"
  [[ -n "$OPT_CLI_MODE" ]] && T_CLI_MODE="$OPT_CLI_MODE"
  [[ -n "$OPT_CLI_SSH" ]] && T_CLI_SSH="$OPT_CLI_SSH"
  [[ -n "$OPT_CLI_CONTAINER" ]] && T_CLI_CONTAINER="$OPT_CLI_CONTAINER"
  [[ -n "$OPT_CLI_DOCKER" ]] && T_CLI_DOCKER="$OPT_CLI_DOCKER"
  [[ -n "$OPT_CLIENT_OGG_HOME" ]] && T_CLIENT_OGG_HOME="$OPT_CLIENT_OGG_HOME"
  [[ -n "$OPT_ADMINCLIENT_PATH" ]] && T_ADMINCLIENT_PATH="$OPT_ADMINCLIENT_PATH"
  [[ -n "$OPT_LOGDUMP_PATH" ]] && T_LOGDUMP_PATH="$OPT_LOGDUMP_PATH"
  [[ -n "$OPT_ADMIN_CLIENT_URL" ]] && T_ADMIN_CLIENT_URL="$OPT_ADMIN_CLIENT_URL"
  [[ -n "$OPT_DOWNLOAD_DIR" ]] && T_DOWNLOAD_DIR="$OPT_DOWNLOAD_DIR"
  [[ -n "$OPT_DOWNLOAD_CLIENT_OGG_HOME" ]] && T_DOWNLOAD_CLIENT_OGG_HOME="$OPT_DOWNLOAD_CLIENT_OGG_HOME"
  [[ -n "$OPT_DOWNLOAD_LOGDUMP_PATH" ]] && T_DOWNLOAD_LOGDUMP_PATH="$OPT_DOWNLOAD_LOGDUMP_PATH"
  [[ -n "$OPT_ORACLE_SCHEMA" ]] && T_ORACLE_SCHEMA="$OPT_ORACLE_SCHEMA"
  [[ -n "$OPT_ORACLE_ADMIN_CONNECT" ]] && T_ORACLE_ADMIN_CONNECT="$OPT_ORACLE_ADMIN_CONNECT"
  [[ -n "$OPT_ORACLE_PDB" ]] && T_ORACLE_PDB="$OPT_ORACLE_PDB"
  [[ -n "$OPT_ORACLE_SQLPLUS" ]] && T_ORACLE_SQLPLUS="$OPT_ORACLE_SQLPLUS"
  [[ -n "$OPT_ORACLE_EXT_DIR" ]] && T_ORACLE_EXT_DIR="$OPT_ORACLE_EXT_DIR"
  [[ -n "$OPT_ORACLE_EXT_DIR_NAME" ]] && T_ORACLE_EXT_DIR_NAME="$OPT_ORACLE_EXT_DIR_NAME"
  ((${#OPT_TRAIL_DIRS[@]})) && T_TRAIL_DIRS=("${OPT_TRAIL_DIRS[@]}")
  ((${#OPT_CLI_TRAIL_DIRS[@]})) && T_CLI_TRAIL_DIRS=("${OPT_CLI_TRAIL_DIRS[@]}")
  ((${#OPT_CLI_TRAIL_SEARCH_ROOTS[@]})) && T_CLI_TRAIL_SEARCH_ROOTS=("${OPT_CLI_TRAIL_SEARCH_ROOTS[@]}")

  [[ -n "$T_MODE" ]] || T_MODE="local"
  [[ "$T_MODE" == "oci" ]] && T_MODE="rest"
  if [[ "$T_MODE" != "rest" ]]; then
    [[ -n "$T_OGG_HOME" ]] || T_OGG_HOME="${OGG_HOME:-$DEFAULT_BASE_DIR}"
    if ((${#T_TRAIL_DIRS[@]} == 0)); then
      T_TRAIL_DIRS=("/u02/Deployment/var/lib/data" "$T_OGG_HOME/dirdat")
    fi
  fi
}

cli_home() {
  if [[ -n "$T_CLIENT_OGG_HOME" ]]; then
    printf '%s\n' "$T_CLIENT_OGG_HOME"
  elif [[ -n "$T_OGG_HOME" ]]; then
    printf '%s\n' "$T_OGG_HOME"
  elif [[ -n "${OGG_HOME:-}" ]]; then
    printf '%s\n' "$OGG_HOME"
  else
    printf '%s\n' "$DEFAULT_BASE_DIR"
  fi
}

effective_cli_mode() {
  local base=${T_MODE:-local}
  if [[ -n "$T_CLI_MODE" ]]; then
    printf '%s\n' "$T_CLI_MODE"
    return
  fi
  if [[ "$base" == "rest" || "$base" == "oci" ]]; then
    if [[ -n "$T_CLI_CONTAINER" || -n "$T_CONTAINER" ]]; then
      printf 'docker\n'
    elif [[ -n "$T_CLI_SSH" ]]; then
      printf 'ssh\n'
    elif [[ -n "$T_CLIENT_OGG_HOME" || -n "$T_ADMINCLIENT_PATH" || -n "$T_LOGDUMP_PATH" ]]; then
      printf 'local\n'
    else
      printf 'none\n'
    fi
  else
    printf '%s\n' "$base"
  fi
}

has_cli_runner() {
  local mode
  mode="$(effective_cli_mode)"
  [[ "$mode" != "none" && "$mode" != "rest" && "$mode" != "oci" ]]
}

describe_cli() {
  local mode
  mode="$(effective_cli_mode)"
  case "$mode" in
    docker) printf 'docker:%s\n' "${T_CLI_CONTAINER:-${T_CONTAINER:--}}" ;;
    ssh) printf 'ssh:%s\n' "${T_CLI_SSH:-${T_SSH:--}}" ;;
    local) printf 'local:%s\n' "${T_CLIENT_OGG_HOME:-${T_OGG_HOME:-${OGG_HOME:-PATH}}}" ;;
    none) printf 'none\n' ;;
    *) printf '%s\n' "${mode:--}" ;;
  esac
}

tool_path() {
  local tool=$1
  local configured=""
  case "$tool" in
    adminclient) configured="$T_ADMINCLIENT_PATH" ;;
    logdump) configured="$T_LOGDUMP_PATH" ;;
  esac
  if [[ -n "$configured" ]]; then
    printf '%s\n' "$configured"
  else
    printf '%s/bin/%s\n' "$(cli_home)" "$tool"
  fi
}

local_tool_path() {
  local tool=$1
  local path
  path="$(tool_path "$tool")"
  if [[ "$path" != */* ]] && have "$path"; then
    command -v "$path"
  elif [[ -x "$path" ]]; then
    printf '%s\n' "$path"
  elif have "$tool"; then
    command -v "$tool"
  else
    die "Cannot find local $tool. Configure client_ogg_home/${tool}_path, put $tool in PATH, or set cli_mode to ssh for a remote OGG host."
  fi
}

docker_prefix_array() {
  local raw="${T_CLI_DOCKER:-${T_DOCKER:-docker}}"
  # shellcheck disable=SC2206
  DOCKER_CMD=($raw)
}

filter_stty_stdin() {
  grep -v "stty: 'standard input': Inappropriate ioctl for device" >&2 || true
}

run_cli_capture() {
  local remote_script=$1
  local mode home remote container ssh_target
  mode="$(effective_cli_mode)"
  home="$(cli_home)"
  remote="cd $(sq "$home") && $remote_script"
  case "$mode" in
    local)
      bash -lc "$remote" 2> >(filter_stty_stdin)
      ;;
    ssh)
      ssh_target="${T_CLI_SSH:-$T_SSH}"
      [[ -n "$ssh_target" ]] || die "Target '$T_NAME' has no cli_ssh or ssh value."
      ssh -T "$ssh_target" "$remote" 2> >(filter_stty_stdin)
      ;;
    docker)
      container="${T_CLI_CONTAINER:-$T_CONTAINER}"
      [[ -n "$container" ]] || die "Target '$T_NAME' has no cli_container or container value."
      docker_prefix_array
      "${DOCKER_CMD[@]}" exec -i "$container" bash -lc "$remote" 2> >(filter_stty_stdin)
      ;;
    none)
      die "Target $T_NAME has no CLI runner. Use REST metadata only."
      ;;
    *)
      die "Unsupported cli_mode: $mode"
      ;;
  esac
}

run_attached_tool() {
  local tool=$1
  local mode home remote container ssh_target path
  mode="$(effective_cli_mode)"
  home="$(cli_home)"
  path="$(tool_path "$tool")"
  remote="cd $(sq "$home") && exec $(sq "$path")"
  case "$mode" in
    local)
      "$(local_tool_path "$tool")"
      ;;
    ssh)
      ssh_target="${T_CLI_SSH:-$T_SSH}"
      [[ -n "$ssh_target" ]] || die "Target '$T_NAME' has no cli_ssh or ssh value."
      echo "Running: ssh -tt $ssh_target $remote" >&2
      ssh -tt "$ssh_target" "$remote"
      ;;
    docker)
      container="${T_CLI_CONTAINER:-$T_CONTAINER}"
      [[ -n "$container" ]] || die "Target '$T_NAME' has no cli_container or container value."
      docker_prefix_array
      echo "Running: ${DOCKER_CMD[*]} exec -it $container bash -lc $remote" >&2
      "${DOCKER_CMD[@]}" exec -it "$container" bash -lc "$remote"
      ;;
    none)
      die "Target $T_NAME has no CLI runner. Use REST metadata only."
      ;;
    *)
      die "Unsupported cli_mode: $mode"
      ;;
  esac
}

pipe_tool() {
  local tool=$1
  shift
  local mode home remote container ssh_target path rc
  mode="$(effective_cli_mode)"
  home="$(cli_home)"
  path="$(tool_path "$tool")"
  remote="cd $(sq "$home") && exec $(sq "$path")"
  case "$mode" in
    local)
      set +e
      {
        printf '%s\n' "$@"
        cat
      } | "$(local_tool_path "$tool")" 2> >(filter_stty_stdin)
      rc=${PIPESTATUS[1]}
      set -e
      return "$rc"
      ;;
    ssh)
      ssh_target="${T_CLI_SSH:-$T_SSH}"
      [[ -n "$ssh_target" ]] || die "Target '$T_NAME' has no cli_ssh or ssh value."
      echo "Running: ssh -T $ssh_target $remote" >&2
      set +e
      {
        printf '%s\n' "$@"
        cat
      } | ssh -T "$ssh_target" "$remote" 2> >(filter_stty_stdin)
      rc=${PIPESTATUS[1]}
      set -e
      return "$rc"
      ;;
    docker)
      container="${T_CLI_CONTAINER:-$T_CONTAINER}"
      [[ -n "$container" ]] || die "Target '$T_NAME' has no cli_container or container value."
      docker_prefix_array
      echo "Running: ${DOCKER_CMD[*]} exec -i $container bash -lc $remote" >&2
      set +e
      {
        printf '%s\n' "$@"
        cat
      } | "${DOCKER_CMD[@]}" exec -i "$container" bash -lc "$remote" 2> >(filter_stty_stdin)
      rc=${PIPESTATUS[1]}
      set -e
      return "$rc"
      ;;
    none)
      die "Target $T_NAME has no CLI runner. Use REST metadata only."
      ;;
    *)
      die "Unsupported cli_mode: $mode"
      ;;
  esac
}

effective_cli_trail_dirs() {
  if ((${#T_CLI_TRAIL_DIRS[@]})); then
    printf '%s\n' "${T_CLI_TRAIL_DIRS[@]}"
  elif [[ "$T_MODE" != "rest" && "$T_MODE" != "oci" ]]; then
    printf '%s\n' "${T_TRAIL_DIRS[@]}"
  fi
}

trail_sequence_filename() {
  local prefix=$1
  local seq=$2
  [[ -n "$prefix" && -n "$seq" ]] || die "Trail name and sequence are required, for example c1 and 6186."
  if [[ "$seq" == "$prefix"* && "$seq" =~ [0-9]{9}$ ]]; then
    printf '%s\n' "$seq"
  elif [[ "$seq" =~ ^[0-9]+$ ]]; then
    printf '%s%09d\n' "$prefix" "$seq"
  else
    die "Trail sequence must be numeric, for example 6186."
  fi
}

resolve_trail_file() {
  local fname=$1
  if [[ "$fname" == */* ]]; then
    printf '%s\n' "$fname"
    return
  fi
  local exact_dirs=()
  mapfile -t exact_dirs < <(effective_cli_trail_dirs)
  local dirs_literal roots_literal script out found
  dirs_literal="$(array_literal "${exact_dirs[@]}")"
  roots_literal="$(array_literal "${T_CLI_TRAIL_SEARCH_ROOTS[@]}")"
  script=$(cat <<EOF
fname=$(sq "$fname")
exact_dirs=($dirs_literal)
search_roots=($roots_literal)

for d in "\${exact_dirs[@]}" \
  "\${OGG_VAR_HOME:-}/lib/data" \
  "\${OGG_VAR_HOME:-}/data" \
  "\${OGG_HOME:-}/var/lib/data" \
  "\${OGG_HOME:-}/dirdat" \
  "./var/lib/data" \
  "./dirdat" \
  "/u02/Deployment/var/lib/data" \
  "/u01/ogg/var/lib/data" \
  "/u01/ogg/dirdat" \
  "/u01/app/ogg/var/lib/data" \
  "/u01/app/ogg/dirdat" \
  "/opt/oracle/ogg/var/lib/data" \
  "/opt/oracle/ogg/dirdat"
do
  [ -n "\$d" ] || continue
  [ -d "\$d" ] || continue
  f=\$(find "\$d" -maxdepth 2 -type f -name "\$fname" -print -quit 2>/dev/null)
  [ -n "\$f" ] && printf '%s\n' "\$f" && exit 0
done

if [ \${#search_roots[@]} -eq 0 ]; then
  search_roots=("\${OGG_VAR_HOME:-}" "\${OGG_HOME:-}" "/u02" "/u01/ogg" "/u01/oracle" "/opt/oracle")
fi
for r in "\${search_roots[@]}"
do
  [ -n "\$r" ] || continue
  [ -d "\$r" ] || continue
  f=\$(find "\$r" -maxdepth 8 -type f -name "\$fname" -print -quit 2>/dev/null)
  [ -n "\$f" ] && printf '%s\n' "\$f" && exit 0
done
true
EOF
)
  out="$(run_cli_capture "$script")"
  found="$(printf '%s\n' "$out" | sed -n '/^\//{p;q}')"
  [[ -n "$found" ]] || die "Trail file $fname was not found by CLI runner."
  printf '%s\n' "$found"
}

list_cli_trail_files() {
  local trail_name=$1
  local limit=${2:-5}
  local pattern="${trail_name}[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]"
  local exact_dirs=()
  mapfile -t exact_dirs < <(effective_cli_trail_dirs)
  local dirs_literal roots_literal script
  dirs_literal="$(array_literal "${exact_dirs[@]}")"
  roots_literal="$(array_literal "${T_CLI_TRAIL_SEARCH_ROOTS[@]}")"
  script=$(cat <<EOF
pattern=$(sq "$pattern")
limit=$limit
exact_dirs=($dirs_literal)
search_roots=($roots_literal)
tmp=\${TMPDIR:-/tmp}/ogg_fk_trails_\$\$.lst
: > "\$tmp"

for d in "\${exact_dirs[@]}" \
  "\${OGG_VAR_HOME:-}/lib/data" \
  "\${OGG_VAR_HOME:-}/data" \
  "\${OGG_HOME:-}/var/lib/data" \
  "\${OGG_HOME:-}/dirdat" \
  "./var/lib/data" \
  "./dirdat" \
  "/u02/Deployment/var/lib/data" \
  "/u01/ogg/var/lib/data" \
  "/u01/ogg/dirdat" \
  "/u01/app/ogg/var/lib/data" \
  "/u01/app/ogg/dirdat" \
  "/opt/oracle/ogg/var/lib/data" \
  "/opt/oracle/ogg/dirdat"
do
  [ -n "\$d" ] || continue
  [ -d "\$d" ] || continue
  find "\$d" -maxdepth 2 -type f -name "\$pattern" -printf '%f\t%p\t%s\t%TY-%Tm-%Td %TH:%TM\n' 2>/dev/null >> "\$tmp"
done

if [ ! -s "\$tmp" ]; then
  if [ \${#search_roots[@]} -eq 0 ]; then
    search_roots=("\${OGG_VAR_HOME:-}" "\${OGG_HOME:-}" "/u02" "/u01/ogg" "/u01/oracle" "/opt/oracle")
  fi
  for r in "\${search_roots[@]}"
  do
    [ -n "\$r" ] || continue
    [ -d "\$r" ] || continue
    find "\$r" -maxdepth 8 -type f -name "\$pattern" -printf '%f\t%p\t%s\t%TY-%Tm-%Td %TH:%TM\n' 2>/dev/null >> "\$tmp"
  done
fi

sort -u "\$tmp" | sort -k1,1 | tail -n "\$limit"
rm -f "\$tmp"
EOF
)
  run_cli_capture "$script"
}

print_resolved_trail_files() {
  local limit=${1:-5}
  has_cli_runner || return 0
  ((${#LAST_TRAIL_NAMES[@]})) || return 0
  local printed=0
  local i name rows last_path
  for i in "${!LAST_TRAIL_NAMES[@]}"; do
    name="${LAST_TRAIL_NAMES[$i]}"
    [[ -n "$name" ]] || continue
    if ! rows="$(list_cli_trail_files "$name" "$limit" 2>&1)"; then
      if [[ $printed -eq 0 ]]; then
        echo
        echo "Resolved trail files visible to logdump:"
        printed=1
      fi
      echo "  $name: unable to list files: $rows"
      continue
    fi
    [[ -n "$rows" ]] || continue
    if [[ $printed -eq 0 ]]; then
      echo
      echo "Resolved trail files visible to logdump:"
      printed=1
    fi
    echo "  $name:"
    printf '%s\n' "$rows" | awk -F '\t' '{printf "    %-19s %12s  %s\n", $4, $3, $2}'
    last_path="$(printf '%s\n' "$rows" | awk -F '\t' 'NF >= 2 {p=$2} END {print p}')"
    [[ -n "$last_path" ]] && echo "    Example: open $last_path"
  done
}

curl_escape() {
  sed 's/\\/\\\\/g; s/"/\\"/g'
}

prompt_rest_password() {
  [[ -n "$REST_PASSWORD_CACHE" ]] && return
  if [[ -n "${OGG_FK_PASSWORD:-}" ]]; then
    REST_PASSWORD_CACHE="$OGG_FK_PASSWORD"
    return
  fi
  printf 'GoldenGate REST password for %s: ' "${T_ADMIN_USER:-user}" >&2
  IFS= read -r -s REST_PASSWORD_CACHE
  printf '\n' >&2
}

rest_url() {
  local path=$1
  local base=${T_ADMIN_URL%/}
  [[ -n "$base" ]] || die "Target $T_NAME has no admin_url."
  if [[ "$base" == */services/v2 && "$path" == /services/v2/* ]]; then
    path="${path#/services/v2}"
  fi
  printf '%s%s\n' "$base" "$path"
}

rest_get() {
  local path=$1
  have curl || die "curl is required for REST commands."
  REST_BODY_FILE="$(mktemp "${TMPDIR:-/tmp}/ogg_fk_rest.XXXXXX")"
  local url curl_args=()
  url="$(rest_url "$path")"
  curl_args=(-sS -o "$REST_BODY_FILE" -w "%{http_code}" --max-time "$OPT_TIMEOUT")
  [[ "$OPT_INSECURE" -eq 1 ]] && curl_args+=(-k)
  if [[ "$OPT_NO_AUTH" -eq 0 && -n "$T_ADMIN_USER" ]]; then
    prompt_rest_password
    local eu ep
    eu="$(printf '%s' "$T_ADMIN_USER" | curl_escape)"
    ep="$(printf '%s' "$REST_PASSWORD_CACHE" | curl_escape)"
    REST_STATUS="$(printf 'user = "%s:%s"\n' "$eu" "$ep" | curl "${curl_args[@]}" -K - "$url")"
    REST_RC=$?
  else
    REST_STATUS="$(curl "${curl_args[@]}" "$url")"
    REST_RC=$?
  fi
}

rest_ok_marker() {
  local status=$1
  if [[ "$status" =~ ^2 ]]; then
    printf 'OK'
  else
    printf 'WARN'
  fi
}

json_value_file() {
  local key=$1
  local file=$2
  tr '\n' ' ' < "$file" \
    | sed "s/\"$key\"/\n\"$key\"/g" \
    | sed -n "2{s/.*\"$key\"[[:space:]]*:[[:space:]]*\"\\{0,1\\}\\([^\",} ]*\\).*/\\1/p;q}"
}

json_names_file() {
  local file=$1
  tr '{' '\n' < "$file" \
    | sed -n 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' \
    | sort -u
}

json_process_names_file() {
  local file=$1
  tr '\n' ' ' < "$file" \
    | sed 's/"processName"/\n"processName"/g' \
    | sed -n '2,$s/.*"processName"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p'
}

cmd_targets() {
  find_config
  [[ -f "$CONFIG_PATH" ]] || die "Config not found: $CONFIG_PATH"
  choose_target
  local old_target=$TARGET_NAME
  local active_target=$TARGET_NAME
  local name mode trails cli dirs roots marker admin_connect
  while IFS= read -r name; do
    [[ -n "$name" ]] || continue
    TARGET_NAME="$name"
    load_target
    mode="$T_MODE"
    cli="$(describe_cli)"
    admin_connect="$(default_admin_client_url)"
    marker=" "
    [[ "$name" == "$active_target" ]] && marker="*"
    if [[ "$mode" == "rest" || "$mode" == "oci" ]]; then
      dirs="$(IFS=,; echo "${T_CLI_TRAIL_DIRS[*]-}")"
      roots="$(IFS=,; echo "${T_CLI_TRAIL_SEARCH_ROOTS[*]-}")"
      if ! has_cli_runner; then
        trails="REST metadata/download only"
      elif [[ -n "$dirs" ]]; then
        trails="REST metadata/download; advanced cli_dirs=$dirs"
      elif [[ -n "$roots" ]]; then
        trails="REST metadata/download; advanced auto roots=$roots"
      else
        trails="REST metadata/download to client; local logdump"
      fi
    else
      trails="$(IFS=,; echo "${T_TRAIL_DIRS[*]-}")"
    fi
    printf '%s %-14s mode=%-7s cli=%-24s rest_url=%s admin_connect=%s ssh=%s trails=%s
'       "$marker" "$name" "$mode" "$cli" "${T_ADMIN_URL:--}" "${admin_connect:--}" "${T_SSH:--}" "${trails:--}"
  done < <(target_names)
  TARGET_NAME=$old_target
  load_target
}

cmd_snapshot() {
  load_target
  local path marker
  echo "REST snapshot target=$T_NAME mode=$T_MODE url=${T_ADMIN_URL:--}"
  for path in "${COMMON_REST_PATHS[@]}"; do
    if rest_get "$path"; then
      marker="$(rest_ok_marker "$REST_STATUS")"
      echo "[$marker] $REST_STATUS $path"
    else
      echo "[WARN] curl failed $path"
    fi
    rm -f "${REST_BODY_FILE:-}"
  done
}

cmd_rest_get() {
  load_target
  local path=${1:-}
  [[ -n "$path" ]] || die "rest-get requires PATH"
  rest_get "$path" || true
  echo "HTTP $REST_STATUS $(rest_url "$path")"
  cat "$REST_BODY_FILE"
  echo
  rm -f "$REST_BODY_FILE"
}

cmd_trails_list() {
  local limit=50 files_per_trail=5 no_resolve=1
  while (($#)); do
    case "$1" in
      --limit) limit=$2; shift 2 ;;
      --files-per-trail) files_per_trail=$2; shift 2 ;;
      --resolve-files) no_resolve=0; shift ;;
      --no-resolve-files) no_resolve=1; shift ;;
      --insecure) OPT_INSECURE=1; shift ;;
      --no-auth) OPT_NO_AUTH=1; shift ;;
      --timeout) OPT_TIMEOUT=$2; shift 2 ;;
      *) die "Unknown trails-list option: $1" ;;
    esac
  done
  load_target
  LAST_TRAIL_NAMES=()
  LAST_TRAIL_SEQ=()
  LAST_TRAIL_PRODUCERS=()
  LAST_TRAIL_CONSUMERS=()
  if [[ "$T_MODE" == "rest" || "$T_MODE" == "oci" ]]; then
    rest_get "$REST_TRAILS_PATH" || true
    echo "Trail metadata target=$T_NAME mode=$T_MODE url=${T_ADMIN_URL:--}"
    echo "APEX Page 159 compatible flow: GET /trails, then GET /trails/<trail-name>."
    echo "Note: REST metadata does not expose OS trail directories. Download a selected sequence to this client, then analyze it with local logdump."
    echo "[$(rest_ok_marker "$REST_STATUS")] $REST_STATUS $REST_TRAILS_PATH"
    if [[ ! "$REST_STATUS" =~ ^2 ]]; then
      cat "$REST_BODY_FILE"
      echo
      rm -f "$REST_BODY_FILE"
      return 1
    fi
    local names=()
    mapfile -t names < <(json_names_file "$REST_BODY_FILE" | head -n "$limit")
    rm -f "$REST_BODY_FILE"
    if ((${#names[@]} == 0)); then
      echo "No trail names found in REST response."
      return 0
    fi
    printf '%-18s %-18s %-18s %-18s %-10s %s\n' "TRAIL" "PRODUCER" "CONSUMER" "DISTPATH" "SIZE_MB" "SEQUENCES"
    local name producer consumer distpath size seq_min seq_max seq processes=()
    for name in "${names[@]}"; do
      rest_get "$REST_TRAILS_PATH/$name" || true
      if [[ ! "$REST_STATUS" =~ ^2 ]]; then
        printf '%-18s detail fetch failed: %s\n' "$name" "$REST_STATUS"
        rm -f "$REST_BODY_FILE"
        continue
      fi
      mapfile -t processes < <(json_process_names_file "$REST_BODY_FILE")
      producer="${processes[0]:-}"
      consumer="${processes[1]:-}"
      distpath="${processes[2]:-}"
      size="$(json_value_file sizeMB "$REST_BODY_FILE")"
      seq_min="$(json_value_file sequenceMin "$REST_BODY_FILE")"
      seq_max="$(json_value_file sequenceMax "$REST_BODY_FILE")"
      seq="${seq_min} to ${seq_max}"
      seq="${seq# to }"
      seq="${seq% to }"
      printf '%-18.18s %-18.18s %-18.18s %-18.18s %-10s %s\n' \
        "${name:--}" "${producer:--}" "${consumer:--}" "${distpath:--}" "${size:--}" "${seq:--}"
      LAST_TRAIL_NAMES+=("$name")
      LAST_TRAIL_SEQ+=("${seq_max:-$seq_min}")
      LAST_TRAIL_PRODUCERS+=("$producer")
      LAST_TRAIL_CONSUMERS+=("$consumer")
      rm -f "$REST_BODY_FILE"
    done
    [[ "$no_resolve" -eq 1 ]] || print_resolved_trail_files "$files_per_trail"
  else
    local dirs_literal script
    dirs_literal="$(array_literal "${T_TRAIL_DIRS[@]}")"
    script=$(cat <<EOF
dirs=($dirs_literal)
for d in "\${dirs[@]}"
do
  [ -d "\$d" ] || continue
  find "\$d" -maxdepth 2 -type f -printf '%T@\t%p\t%s\t%TY-%Tm-%Td %TH:%TM\n'
done | sort -n | tail -n $limit
EOF
)
    echo "Trail files target=$T_NAME mode=$T_MODE"
    run_cli_capture "$script" | awk -F '\t' '{printf "%-19s %12s  %s\n", $4, $3, $2}'
  fi
}

default_admin_client_url() {
  local url="${T_ADMIN_CLIENT_URL:-${T_ADMIN_URL:-}}"
  url="${url%/}"
  url="${url%/services/v2}"
  printf '%s\n' "$url"
}

cmd_admin_shell() {
  local auto_connect=0 connect_url="" connect_user=""
  while (($#)); do
    case "$1" in
      --connect) auto_connect=1; shift ;;
      --connect-url) connect_url=$2; shift 2 ;;
      --connect-user) connect_user=$2; shift 2 ;;
      --no-connect) auto_connect=0; shift ;;
      *) die "Unknown admin-shell option: $1" ;;
    esac
  done
  load_target
  [[ -n "$connect_url" ]] || connect_url="$(default_admin_client_url)"
  [[ -n "$connect_user" ]] || connect_user="${T_ADMIN_USER:-oggadmin}"
  if [[ "$auto_connect" -eq 1 ]]; then
    if have python3 && [[ -f "$(dirname "$0")/ogg_field_kit.py" ]]; then
      echo "Auto-connect: connect $connect_url as $connect_user !" >&2
      python3 "$(dirname "$0")/ogg_field_kit.py" --config "$CONFIG_PATH" --target "$T_NAME" admin-shell --connect --connect-url "$connect_url" --connect-user "$connect_user"
      return $?
    fi
    echo "Auto-connect needs python3 PTY support to keep password input hidden." >&2
    echo "Fallback: type this command at the Admin Client prompt:" >&2
    echo "  connect $connect_url as $connect_user !" >&2
  elif [[ -n "$connect_url" ]]; then
    echo "Hint: connect $connect_url as $connect_user !" >&2
  fi
  run_attached_tool adminclient
}

cmd_admin_run() {
  load_target
  echo "Shell edition does not automate Admin Client password entry." >&2
  echo "Use admin-shell for secure interactive login, or pass commands that do not require a password prompt." >&2
  local commands=()
  while (($#)); do
    case "$1" in
      --cmd) commands+=("$2"); shift 2 ;;
      *) die "Unknown admin-run option: $1" ;;
    esac
  done
  ((${#commands[@]})) || commands=("info all")
  commands+=("exit")
  pipe_tool adminclient "${commands[@]}"
}

run_logdump_batch() {
  local mode home remote container ssh_target path
  mode="$(effective_cli_mode)"
  home="$(cli_home)"
  path="$(tool_path logdump)"
  remote="cd $(sq "$home") && exec $(sq "$path")"
  case "$mode" in
    local)
      "$(local_tool_path logdump)" 2> >(filter_stty_stdin)
      ;;
    ssh)
      ssh_target="${T_CLI_SSH:-$T_SSH}"
      [[ -n "$ssh_target" ]] || die "Target '$T_NAME' has no cli_ssh or ssh value."
      ssh -T "$ssh_target" "$remote" 2> >(filter_stty_stdin)
      ;;
    docker)
      container="${T_CLI_CONTAINER:-$T_CONTAINER}"
      [[ -n "$container" ]] || die "Target '$T_NAME' has no cli_container or container value."
      docker_prefix_array
      "${DOCKER_CMD[@]}" exec -i "$container" bash -lc "$remote" 2> >(filter_stty_stdin)
      ;;
    none)
      die "Target $T_NAME has no CLI runner. Use REST metadata only."
      ;;
    *)
      die "Unsupported cli_mode: $mode"
      ;;
  esac
}

cmd_logdump_shell() {
  local trail="" trail_name="" seq="" fname=""
  while (($#)); do
    case "$1" in
      --trail) trail=$2; shift 2 ;;
      --trail-name) trail_name=$2; shift 2 ;;
      --sequence|--seq) seq=$2; shift 2 ;;
      *) die "Unknown logdump-shell option: $1" ;;
    esac
  done
  load_target
  local commands=("${DEFAULT_LOGDUMP_SETTINGS[@]}")
  if [[ -z "$trail" && -n "$trail_name" && -n "$seq" ]]; then
    fname="$(trail_sequence_filename "$trail_name" "$seq")"
    trail="$(resolve_trail_file "$fname")"
    echo "Resolved trail file: $trail" >&2
  elif [[ -n "$trail" && "$trail" != */* ]]; then
    trail="$(resolve_trail_file "$trail")"
    echo "Resolved trail file: $trail" >&2
  fi
  [[ -n "$trail" ]] && commands+=("open $trail")
  if [[ -n "$trail" ]]; then
    echo "Logdump interactive. Default detail settings are enabled and the trail is opened automatically." >&2
  else
    echo "Logdump interactive. Default detail settings are enabled; open a trail file, then use real logdump commands." >&2
  fi
  pipe_tool logdump "${commands[@]}"
}

cmd_logdump_run() {
  local trail="" trail_name="" seq="" fname=""
  local commands=()
  while (($#)); do
    case "$1" in
      --trail) trail=$2; shift 2 ;;
      --trail-name) trail_name=$2; shift 2 ;;
      --sequence|--seq) seq=$2; shift 2 ;;
      --cmd) commands+=("$2"); shift 2 ;;
      *) die "Unknown logdump-run option: $1" ;;
    esac
  done
  load_target
  local pre=("${DEFAULT_LOGDUMP_SETTINGS[@]}")
  if [[ -z "$trail" && -n "$trail_name" && -n "$seq" ]]; then
    fname="$(trail_sequence_filename "$trail_name" "$seq")"
    trail="$(resolve_trail_file "$fname")"
    echo "Resolved trail file: $trail"
  elif [[ -n "$trail" && "$trail" != */* ]]; then
    trail="$(resolve_trail_file "$trail")"
    echo "Resolved trail file: $trail"
  fi
  [[ -n "$trail" ]] && pre+=("open $trail")
  ((${#commands[@]})) || commands=("env")
  pre+=("${commands[@]}" "exit")
  printf '%s\n' "${pre[@]}" | run_logdump_batch
}


default_download_dir() {
  local trail_name=${1:-trail}
  if [[ -n "$T_DOWNLOAD_DIR" ]]; then
    printf '%s\n' "$T_DOWNLOAD_DIR"
  elif [[ -n "${OGG_FK_DOWNLOAD_DIR:-}" ]]; then
    printf '%s\n' "${OGG_FK_DOWNLOAD_DIR%/}/$T_NAME/$trail_name"
  else
    printf '%s\n' "./trail-downloads/$T_NAME/$trail_name"
  fi
}

download_root_candidates() {
  [[ -n "$T_DOWNLOAD_DIR" ]] && printf '%s\n' "$T_DOWNLOAD_DIR"
  [[ -n "${OGG_FK_DOWNLOAD_DIR:-}" ]] && printf '%s\n' "${OGG_FK_DOWNLOAD_DIR%/}/$T_NAME"
  printf '%s\n' "./trail-downloads/$T_NAME"
  [[ "$(pwd)" != "$DEFAULT_BASE_DIR" ]] && printf '%s\n' "$DEFAULT_BASE_DIR/trail-downloads/$T_NAME"
}

find_downloaded_trails() {
  local limit=${1:-20}
  local root f abs base prefix seq9 seq size mtime
  declare -A seen=()
  while IFS= read -r root; do
    [[ -d "$root" ]] || continue
    while IFS= read -r f; do
      [[ -f "$f" ]] || continue
      base=${f##*/}
      [[ "$base" == *.tmp.* ]] && continue
      if [[ "$base" =~ ^(.+)([0-9]{9})$ ]]; then
        prefix="${BASH_REMATCH[1]}"
        seq9="${BASH_REMATCH[2]}"
        seq=$((10#$seq9))
      else
        continue
      fi
      abs="$(readlink -f "$f" 2>/dev/null || printf '%s\n' "$f")"
      [[ -n "${seen[$abs]:-}" ]] && continue
      seen[$abs]=1
      size="$(stat -c '%s' "$f" 2>/dev/null || printf '0')"
      mtime="$(stat -c '%Y' "$f" 2>/dev/null || printf '0')"
      printf '%s\t%s\t%s\t%s\t%s\n' "$mtime" "$prefix" "$seq" "$size" "$abs"
    done < <(find "$root" -maxdepth 5 -type f -print 2>/dev/null)
  done < <(download_root_candidates) | sort -nr | head -n "$limit"
}

choose_downloaded_trail_file() {
  local limit=${1:-20}
  local rows=() row idx mtime prefix seq size path mtime_text size_mb choice
  mapfile -t rows < <(find_downloaded_trails "$limit")
  if ((${#rows[@]})); then
    {
      echo "Downloaded/local trail files (newest first):"
      idx=1
      for row in "${rows[@]}"; do
        IFS=$'\t' read -r mtime prefix seq size path <<< "$row"
        mtime_text="$(date -d "@$mtime" '+%Y-%m-%d %H:%M' 2>/dev/null || printf '%s' "$mtime")"
        size_mb=$(( (size + 1048575) / 1048576 ))
        printf '  %2d. trail=%s sequence=%s size=%sMB mtime=%s\n      %s\n' \
          "$idx" "$prefix" "$seq" "$size_mb" "$mtime_text" "$path"
        idx=$((idx + 1))
      done
    } >&2
    choice="$(ask "Trail number/local file path" "1")"
    if [[ "$choice" =~ ^[0-9]+$ ]] && ((choice >= 1 && choice <= ${#rows[@]})); then
      IFS=$'\t' read -r mtime prefix seq size path <<< "${rows[$((choice - 1))]}"
      printf '%s\n' "$path"
      return 0
    fi
    [[ -n "$choice" ]] && printf '%s\n' "$choice" && return 0
  fi
  echo "No downloaded trail files found under:" >&2
  download_root_candidates | sed 's/^/  /' >&2
  ask "Local trail file" ""
}


trail_file_sort_record() {
  local path=$1
  local ordinal=${2:-0}
  local base prefix seq9 seq
  base=${path##*/}
  if [[ "$base" =~ ^(.+)([0-9]{9})$ ]]; then
    prefix="${BASH_REMATCH[1]}"
    seq9="${BASH_REMATCH[2]}"
    seq=$((10#$seq9))
    printf '%s\t%012d\t%06d\t%s\n' "$prefix" "$seq" "$ordinal" "$path"
  else
    printf '~\t%012d\t%06d\t%s\n' "$ordinal" "$ordinal" "$path"
  fi
}

sort_trail_files() {
  local path abs idx=0 record
  local -a records=()
  declare -A seen_sort=()
  for path in "$@"; do
    [[ -n "$path" ]] || continue
    [[ -f "$path" ]] || die "Trail file not found: $path"
    abs="$(readlink -f "$path" 2>/dev/null || printf '%s\n' "$path")"
    [[ -n "${seen_sort[$abs]:-}" ]] && continue
    seen_sort[$abs]=1
    records+=("$(trail_file_sort_record "$abs" "$idx")")
    idx=$((idx + 1))
  done
  ((${#records[@]})) || return 0
  printf '%s\n' "${records[@]}" | sort -t $'\t' -k1,1 -k2,2n -k3,3n | cut -f4-
}

downloaded_trail_path_for_sequence() {
  local trail_name=$1
  local seq=$2
  local seq9 root candidate found
  [[ -n "$trail_name" && "$seq" =~ ^[0-9]+$ ]] || return 1
  seq9="$(printf '%09d' "$((10#$seq))")"
  while IFS= read -r root; do
    [[ -d "$root" ]] || continue
    candidate="$root/$trail_name/${trail_name}${seq9}"
    if [[ -f "$candidate" ]]; then
      readlink -f "$candidate" 2>/dev/null || printf '%s\n' "$candidate"
      return 0
    fi
    found="$(find "$root" -maxdepth 5 -type f -name "${trail_name}${seq9}" -print -quit 2>/dev/null || true)"
    if [[ -n "$found" ]]; then
      readlink -f "$found" 2>/dev/null || printf '%s\n' "$found"
      return 0
    fi
  done < <(download_root_candidates)
  return 1
}

resolve_downloaded_trail_range() {
  local spec=$1
  local trail_name start_seq end_seq seq path
  if [[ "$spec" =~ ^([A-Za-z0-9._-]+):([0-9]+)[-~]([0-9]+)$ ]]; then
    trail_name="${BASH_REMATCH[1]}"
    start_seq=$((10#${BASH_REMATCH[2]}))
    end_seq=$((10#${BASH_REMATCH[3]}))
  else
    die "Trail range must look like c1:6012-6015."
  fi
  if ((start_seq <= end_seq)); then
    for ((seq=start_seq; seq<=end_seq; seq++)); do
      path="$(downloaded_trail_path_for_sequence "$trail_name" "$seq")" || die "Downloaded trail not found: $trail_name sequence $seq. Download it first with menu 6 or trail-download --seq ${start_seq}-${end_seq}."
      printf '%s\n' "$path"
    done
  else
    for ((seq=start_seq; seq>=end_seq; seq--)); do
      path="$(downloaded_trail_path_for_sequence "$trail_name" "$seq")" || die "Downloaded trail not found: $trail_name sequence $seq. Download it first with menu 6 or trail-download --seq ${start_seq}-${end_seq}."
      printf '%s\n' "$path"
    done
  fi
}

choose_downloaded_trail_files() {
  local limit=${1:-20}
  local rows=() row idx mtime prefix seq size path mtime_text size_mb choice token
  local single_prefix="" prefix_seen=""
  local -a selected_paths=() range_paths=()
  declare -A seen_paths=()

  add_selected_path() {
    local selected=$1
    local abs
    [[ -f "$selected" ]] || die "Trail file not found: $selected"
    abs="$(readlink -f "$selected" 2>/dev/null || printf '%s\n' "$selected")"
    [[ -n "${seen_paths[$abs]:-}" ]] && return 0
    seen_paths[$abs]=1
    selected_paths+=("$abs")
  }

  add_selected_index() {
    local n=$1
    local r p
    ((n >= 1 && n <= ${#rows[@]})) || die "Trail list number out of range: $n"
    r="${rows[$((n - 1))]}"
    IFS=$'\t' read -r _ _ _ _ p <<< "$r"
    add_selected_path "$p"
  }

  mapfile -t rows < <(find_downloaded_trails "$limit")
  if ((${#rows[@]})); then
    {
      echo "Downloaded/local trail files (newest first):"
      idx=1
      for row in "${rows[@]}"; do
        IFS=$'\t' read -r mtime prefix seq size path <<< "$row"
        if [[ "$prefix" != "-" ]]; then
          if [[ -z "$prefix_seen" ]]; then
            prefix_seen="$prefix"
            single_prefix="$prefix"
          elif [[ "$prefix_seen" != "$prefix" ]]; then
            single_prefix=""
          fi
        fi
        mtime_text="$(date -d "@$mtime" '+%Y-%m-%d %H:%M' 2>/dev/null || printf '%s' "$mtime")"
        size_mb=$(( (size + 1048575) / 1048576 ))
        printf '  %2d. trail=%s sequence=%s size=%sMB mtime=%s\n      %s\n' \
          "$idx" "$prefix" "$seq" "$size_mb" "$mtime_text" "$path"
        idx=$((idx + 1))
      done
      echo "Input examples: 1  |  1,2,3  |  1-4  |  c1:6012-6015  |  6012-6015 when one trail name is listed"
    } >&2
    choice="$(ask "Trail numbers/ranges/local paths" "1")"
    choice="${choice//,/ }"
    for token in $choice; do
      if [[ "$token" =~ ^[0-9]+$ ]]; then
        add_selected_index "$token"
      elif [[ "$token" =~ ^([0-9]+)-([0-9]+)$ && ${#rows[@]} -gt 0 ]]; then
        local start_idx end_idx i
        start_idx=$((10#${BASH_REMATCH[1]}))
        end_idx=$((10#${BASH_REMATCH[2]}))
        if ((start_idx <= end_idx)); then
          for ((i=start_idx; i<=end_idx; i++)); do add_selected_index "$i"; done
        else
          for ((i=start_idx; i>=end_idx; i--)); do add_selected_index "$i"; done
        fi
      elif [[ "$token" =~ ^([A-Za-z0-9._-]+):[0-9]+[-~][0-9]+$ ]]; then
        mapfile -t range_paths < <(resolve_downloaded_trail_range "$token")
        for path in "${range_paths[@]}"; do add_selected_path "$path"; done
      elif [[ "$token" =~ ^([0-9]+)[-~]([0-9]+)$ ]]; then
        [[ -n "$single_prefix" ]] || die "Sequence range $token is ambiguous. Use trail-name syntax, for example c1:$token."
        mapfile -t range_paths < <(resolve_downloaded_trail_range "$single_prefix:$token")
        for path in "${range_paths[@]}"; do add_selected_path "$path"; done
      elif [[ "$token" =~ ^([A-Za-z0-9._-]+):([0-9]+)$ ]]; then
        path="$(downloaded_trail_path_for_sequence "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}")" || die "Downloaded trail not found: ${BASH_REMATCH[1]} sequence ${BASH_REMATCH[2]}."
        add_selected_path "$path"
      else
        add_selected_path "$token"
      fi
    done
    sort_trail_files "${selected_paths[@]}"
    return 0
  fi
  echo "No downloaded trail files found under:" >&2
  download_root_candidates | sed 's/^/  /' >&2
  choice="$(ask "Local trail file(s)" "")"
  [[ -n "$choice" ]] || return 0
  choice="${choice//,/ }"
  for token in $choice; do add_selected_path "$token"; done
  sort_trail_files "${selected_paths[@]}"
}


rest_trail_path() {
  local trail_name=$1
  local path=""
  rest_get "$REST_TRAILS_PATH/$trail_name" || true
  if [[ "$REST_STATUS" =~ ^2 ]]; then
    path="$(json_value_file path "$REST_BODY_FILE")"
  fi
  rm -f "${REST_BODY_FILE:-}"
  printf '%s\n' "$path"
}

download_trail_sequence() {
  local trail_name=$1
  local seq=$2
  local output_file=${3:-}
  local download_dir=${4:-}
  local trail_path=${5:-}
  local use_download_param=${6:-1}
  [[ -n "$trail_name" && -n "$seq" ]] || die "trail name and sequence are required."
  have curl || die "curl is required for REST trail download."

  local fname out dir tmp url status http_status content_type curl_args=()
  fname="$(trail_sequence_filename "$trail_name" "$seq")"
  if [[ -z "$output_file" ]]; then
    dir="${download_dir:-$(default_download_dir "$trail_name") }"
    dir="${dir% }"
    mkdir -p "$dir"
    out="$dir/$fname"
  else
    out="$output_file"
    mkdir -p "$(dirname "$out")"
  fi

  if [[ -z "$trail_path" ]]; then
    trail_path="$(rest_trail_path "$trail_name")"
  fi

  url="$(rest_url "$REST_TRAILS_PATH/$trail_name/sequences/$seq")"
  tmp="$out.tmp.$$"
  curl_args=(-sS -L -o "$tmp" -w "%{http_code} %{content_type}" --max-time "$OPT_TIMEOUT" -H "Accept: application/binary" -G)
  [[ "$OPT_INSECURE" -eq 1 ]] && curl_args+=(-k)
  [[ "$use_download_param" -eq 1 ]] && curl_args+=(--data-urlencode "download=true")
  [[ -n "$trail_path" ]] && curl_args+=(--data-urlencode "path=$trail_path")

  echo "Downloading trail sequence via REST: $trail_name sequence $seq" >&2
  [[ -n "$trail_path" ]] && echo "REST trail path parameter: $trail_path" >&2
  if [[ "$OPT_NO_AUTH" -eq 0 && -n "$T_ADMIN_USER" ]]; then
    prompt_rest_password
    local eu ep
    eu="$(printf '%s' "$T_ADMIN_USER" | curl_escape)"
    ep="$(printf '%s' "$REST_PASSWORD_CACHE" | curl_escape)"
    status="$(printf 'user = "%s:%s"\n' "$eu" "$ep" | curl "${curl_args[@]}" -K - "$url")"
  else
    status="$(curl "${curl_args[@]}" "$url")"
  fi
  http_status="${status%% *}"
  content_type="${status#* }"
  if [[ ! "$http_status" =~ ^2 ]]; then
    echo "REST download failed: HTTP $http_status $url" >&2
    [[ -s "$tmp" ]] && cat "$tmp" >&2
    rm -f "$tmp"
    return 1
  fi
  if [[ "$content_type" == *json* || "$content_type" == text/* ]]; then
    echo "REST returned $content_type instead of binary trail content." >&2
    cat "$tmp" >&2
    rm -f "$tmp"
    return 1
  fi
  mv -f "$tmp" "$out"
  echo "Downloaded: $out" >&2
  printf '%s\n' "$out"
}

local_download_logdump_path() {
  local path home
  if [[ -n "$T_DOWNLOAD_LOGDUMP_PATH" ]]; then
    [[ -x "$T_DOWNLOAD_LOGDUMP_PATH" ]] || die "download_logdump_path is not executable: $T_DOWNLOAD_LOGDUMP_PATH"
    printf '%s\n' "$T_DOWNLOAD_LOGDUMP_PATH"
    return
  fi
  if [[ -n "$T_DOWNLOAD_CLIENT_OGG_HOME" ]]; then
    path="$T_DOWNLOAD_CLIENT_OGG_HOME/bin/logdump"
    [[ -x "$path" ]] || die "download_client_ogg_home does not contain executable bin/logdump: $T_DOWNLOAD_CLIENT_OGG_HOME"
    printf '%s\n' "$path"
    return
  fi
  if [[ "$(effective_cli_mode)" == "local" ]]; then
    local_tool_path logdump
    return
  fi
  if have logdump; then
    command -v logdump
    return
  fi
  for path in /u01/app/ogg/ogg*/bin/logdump /u01/ogg/bin/logdump; do
    if [[ -x "$path" ]]; then
      printf '%s\n' "$path"
      return
    fi
  done
  die "Cannot find local logdump for downloaded trail analysis. Configure download_client_ogg_home or download_logdump_path."
}

run_downloaded_logdump_shell() {
  local trail_file=$1
  [[ -f "$trail_file" ]] || die "Downloaded/local trail file not found: $trail_file"
  local logdump_path rc
  logdump_path="$(local_download_logdump_path)"
  echo "Running local logdump: $logdump_path" >&2
  set +e
  {
    printf '%s\n' "${DEFAULT_LOGDUMP_SETTINGS[@]}"
    printf 'open %s\n' "$trail_file"
    cat
  } | "$logdump_path" 2> >(filter_stty_stdin)
  rc=${PIPESTATUS[1]}
  set -e
  return "$rc"
}

run_downloaded_logdump_batch() {
  local trail_file=$1
  shift
  [[ -f "$trail_file" ]] || die "Downloaded/local trail file not found: $trail_file"
  local logdump_path
  logdump_path="$(local_download_logdump_path)"
  {
    printf '%s\n' "${DEFAULT_LOGDUMP_SETTINGS[@]}"
    printf 'open %s\n' "$trail_file"
    if (($#)); then
      printf '%s\n' "$@"
    else
      printf 'env\n'
    fi
    printf 'exit\n'
  } | "$logdump_path" 2> >(filter_stty_stdin)
}

cmd_trail_download() {
  local trail_name="" seq="" output_file="" download_dir="" trail_path="" use_download_param=1
  while (($#)); do
    case "$1" in
      --trail-name) trail_name=$2; shift 2 ;;
      --sequence|--seq) seq=$2; shift 2 ;;
      --output|--file) output_file=$2; shift 2 ;;
      --download-dir) download_dir=$2; shift 2 ;;
      --trail-path|--path) trail_path=$2; shift 2 ;;
      --no-download-param) use_download_param=0; shift ;;
      --insecure) OPT_INSECURE=1; shift ;;
      --no-auth) OPT_NO_AUTH=1; shift ;;
      --timeout) OPT_TIMEOUT=$2; shift 2 ;;
      *) die "Unknown trail-download option: $1" ;;
    esac
  done
  load_target
  local out start_seq end_seq s
  if [[ "$seq" =~ ^([0-9]+)[-~]([0-9]+)$ ]]; then
    [[ -z "$output_file" ]] || die "--output cannot be used with a sequence range. Use --download-dir instead."
    start_seq=$((10#${BASH_REMATCH[1]}))
    end_seq=$((10#${BASH_REMATCH[2]}))
    if ((start_seq <= end_seq)); then
      for ((s=start_seq; s<=end_seq; s++)); do
        out="$(download_trail_sequence "$trail_name" "$s" "" "$download_dir" "$trail_path" "$use_download_param")"
        echo "Trail sequence saved on client: $out"
      done
    else
      for ((s=start_seq; s>=end_seq; s--)); do
        out="$(download_trail_sequence "$trail_name" "$s" "" "$download_dir" "$trail_path" "$use_download_param")"
        echo "Trail sequence saved on client: $out"
      done
    fi
    return 0
  fi
  out="$(download_trail_sequence "$trail_name" "$seq" "$output_file" "$download_dir" "$trail_path" "$use_download_param")"
  echo "Trail sequence saved on client: $out"
}

cmd_download_logdump_shell() {
  local trail="" trail_name="" seq="" output_file="" download_dir="" trail_path="" use_download_param=1
  while (($#)); do
    case "$1" in
      --trail) trail=$2; shift 2 ;;
      --trail-name) trail_name=$2; shift 2 ;;
      --sequence|--seq) seq=$2; shift 2 ;;
      --output|--file) output_file=$2; shift 2 ;;
      --download-dir) download_dir=$2; shift 2 ;;
      --trail-path|--path) trail_path=$2; shift 2 ;;
      --no-download-param) use_download_param=0; shift ;;
      --insecure) OPT_INSECURE=1; shift ;;
      --no-auth) OPT_NO_AUTH=1; shift ;;
      --timeout) OPT_TIMEOUT=$2; shift 2 ;;
      *) die "Unknown download-logdump-shell option: $1" ;;
    esac
  done
  load_target
  local file="$trail"
  if [[ -z "$file" ]]; then
    if [[ "$seq" =~ ^[0-9]+[-~][0-9]+$ ]]; then
      die "Interactive logdump opens one trail sequence at a time. Use menu 6 to download the range, then menu 7 or 9."
    fi
    file="$(download_trail_sequence "$trail_name" "$seq" "$output_file" "$download_dir" "$trail_path" "$use_download_param")"
  fi
  echo "Opening client-local trail file with local logdump: $file" >&2
  run_downloaded_logdump_shell "$file"
}

cmd_download_logdump_run() {
  local trail="" trail_name="" seq="" output_file="" download_dir="" trail_path="" use_download_param=1
  local commands=()
  while (($#)); do
    case "$1" in
      --trail) trail=$2; shift 2 ;;
      --trail-name) trail_name=$2; shift 2 ;;
      --sequence|--seq) seq=$2; shift 2 ;;
      --cmd) commands+=("$2"); shift 2 ;;
      --output|--file) output_file=$2; shift 2 ;;
      --download-dir) download_dir=$2; shift 2 ;;
      --trail-path|--path) trail_path=$2; shift 2 ;;
      --no-download-param) use_download_param=0; shift ;;
      --insecure) OPT_INSECURE=1; shift ;;
      --no-auth) OPT_NO_AUTH=1; shift ;;
      --timeout) OPT_TIMEOUT=$2; shift 2 ;;
      *) die "Unknown download-logdump-run option: $1" ;;
    esac
  done
  load_target
  local file="$trail"
  if [[ -z "$file" ]]; then
    if [[ "$seq" =~ ^[0-9]+[-~][0-9]+$ ]]; then
      die "download-logdump-run handles one trail sequence at a time. Use trail-download for the range, then trail-sql-analyze or local logdump."
    fi
    file="$(download_trail_sequence "$trail_name" "$seq" "$output_file" "$download_dir" "$trail_path" "$use_download_param")"
  fi
  echo "Analyzing client-local trail file with local logdump: $file" >&2
  run_downloaded_logdump_batch "$file" "${commands[@]}"
}

sql_name() {
  local value=${1:-}
  [[ "$value" =~ ^[A-Za-z][A-Za-z0-9_$#]*$ ]] || die "Invalid Oracle identifier: $value"
  printf '%s\n' "${value^^}"
}

sql_literal() {
  local value=${1:-}
  value=${value//\'/\'\'}
  printf "'%s'" "$value"
}

sqlplus_path() {
  if [[ -n "$T_ORACLE_SQLPLUS" ]]; then
    [[ -x "$T_ORACLE_SQLPLUS" ]] || die "oracle_sqlplus is not executable: $T_ORACLE_SQLPLUS"
    readlink -f "$T_ORACLE_SQLPLUS" 2>/dev/null || printf '%s\n' "$T_ORACLE_SQLPLUS"
    return
  fi
  if have sqlplus; then
    command -v sqlplus
    return
  fi
  local path
  for path in /u01/app/oracle/product/*/*/bin/sqlplus /u01/app/oracle/product/*/dbhome*/bin/sqlplus /opt/oracle/product/*/dbhome*/bin/sqlplus; do
    if [[ -x "$path" ]]; then
      readlink -f "$path" 2>/dev/null || printf '%s\n' "$path"
      return
    fi
  done
  die "sqlplus not found. Configure oracle_sqlplus or put sqlplus in PATH. Docker is not used by this feature."
}

oracle_sid_from_oratab() {
  local home=$1 sid oh rest
  [[ -r /etc/oratab ]] || return 0
  while IFS=: read -r sid oh rest; do
    [[ -n "$sid" && "$sid" != \#* && "$oh" == "$home" ]] || continue
    printf '%s\n' "$sid"
    return 0
  done < /etc/oratab
}

prepare_sqlplus_env() {
  local sqlplus_bin=$1 oracle_home sid
  if [[ -z "${ORACLE_HOME:-}" && "$sqlplus_bin" == */bin/sqlplus ]]; then
    oracle_home="${sqlplus_bin%/bin/sqlplus}"
    if [[ -d "$oracle_home/sqlplus/mesg" ]]; then
      export ORACLE_HOME="$oracle_home"
      export PATH="$ORACLE_HOME/bin:$PATH"
      case ":${LD_LIBRARY_PATH:-}:" in
        *":$ORACLE_HOME/lib:"*) ;;
        *) export LD_LIBRARY_PATH="$ORACLE_HOME/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}" ;;
      esac
      echo "Using ORACLE_HOME=$ORACLE_HOME" >&2
    fi
  fi
  if [[ -z "${ORACLE_SID:-}" && -n "${ORACLE_HOME:-}" ]]; then
    sid="$(oracle_sid_from_oratab "$ORACLE_HOME" || true)"
    if [[ -n "$sid" ]]; then
      export ORACLE_SID="$sid"
      echo "Using ORACLE_SID=$ORACLE_SID" >&2
    fi
  fi
}

sqlplus_run_file() {
  local sql_file=$1
  local sqlplus_bin
  sqlplus_bin="$(sqlplus_path)"
  prepare_sqlplus_env "$sqlplus_bin"
  "$sqlplus_bin" -L -s /nolog < "$sql_file"
}

cmd_trail_sql_analyze() {
  local schema="" connect="" pdb="" sqlplus_override="" ext_dir="" dir_name="" limit="" dat_file="" report_file=""
  local trail_arg trail_list_file range_spec item
  local -a trails=() chosen=() split_items=()
  while (($#)); do
    case "$1" in
      --trail) trails+=("$2"); shift 2 ;;
      --trails)
        trail_arg="${2//,/ }"
        for item in $trail_arg; do trails+=("$item"); done
        shift 2 ;;
      --trail-list)
        trail_list_file=$2
        [[ -f "$trail_list_file" ]] || die "Trail list file not found: $trail_list_file"
        while IFS= read -r item; do
          [[ -n "$item" && ! "$item" =~ ^[[:space:]]*# ]] || continue
          trails+=("$item")
        done < "$trail_list_file"
        shift 2 ;;
      --trail-range)
        range_spec=$2
        mapfile -t split_items < <(resolve_downloaded_trail_range "$range_spec")
        trails+=("${split_items[@]}")
        shift 2 ;;
      --schema|--oracle-schema) schema=$2; shift 2 ;;
      --connect|--oracle-admin-connect) connect=$2; shift 2 ;;
      --pdb|--oracle-pdb) pdb=$2; shift 2 ;;
      --sqlplus|--oracle-sqlplus) sqlplus_override=$2; shift 2 ;;
      --ext-dir|--oracle-ext-dir) ext_dir=$2; shift 2 ;;
      --dir-name|--oracle-ext-dir-name) dir_name=$2; shift 2 ;;
      --limit) limit=$2; shift 2 ;;
      --dat-file) dat_file=$2; shift 2 ;;
      --report) report_file=$2; shift 2 ;;
      *) die "Unknown trail-sql-analyze option: $1" ;;
    esac
  done
  load_target
  [[ -n "$sqlplus_override" ]] && T_ORACLE_SQLPLUS="$sqlplus_override"
  [[ -n "$schema" ]] || schema="${T_ORACLE_SCHEMA:-SOE}"
  [[ -n "$connect" ]] || connect="${T_ORACLE_ADMIN_CONNECT:-/ as sysdba}"
  [[ -n "$pdb" ]] || pdb="${T_ORACLE_PDB:-}"
  [[ -n "$dir_name" ]] || dir_name="${T_ORACLE_EXT_DIR_NAME:-OGG_FK_TRAIL_DIR}"
  schema="$(sql_name "$schema")"
  dir_name="$(sql_name "$dir_name")"

  if ((${#trails[@]} == 0)); then
    mapfile -t chosen < <(choose_downloaded_trail_files 30)
    trails+=("${chosen[@]}")
  fi
  ((${#trails[@]})) || die "Trail file is required."
  mapfile -t trails < <(sort_trail_files "${trails[@]}")
  ((${#trails[@]})) || die "Trail file is required."

  local first_trail label base dat_path sql_file rows parser logdump_bin ext_dir_lit dat_file_lit pdb_sql report_path trail_prompt_lines
  local file_no trail_file trail_base
  first_trail="${trails[0]}"
  [[ -n "$ext_dir" ]] || ext_dir="${T_ORACLE_EXT_DIR:-$(dirname "$first_trail")}"
  mkdir -p "$ext_dir"
  ext_dir="$(readlink -f "$ext_dir" 2>/dev/null || printf '%s\n' "$ext_dir")"
  [[ -d "$ext_dir" ]] || die "External-table directory does not exist: $ext_dir"

  label="$(trail_set_label "${trails[@]}")"
  [[ -n "$dat_file" ]] || dat_file="lgd_${label}.dat"
  dat_path="$ext_dir/$dat_file"
  parser="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/ogg_trail_parse.sh"
  [[ -x "$parser" ]] || die "Parser not found or not executable: $parser"
  logdump_bin="$(local_download_logdump_path)"

  echo "Parsing trail set for external table:" >&2
  file_no=0
  : > "$dat_path"
  local parser_rc
  for trail_file in "${trails[@]}"; do
    file_no=$((file_no + 1))
    trail_base=${trail_file##*/}
    echo "  [$file_no/${#trails[@]}] $trail_file" >&2
    set +e
    if [[ -n "$limit" ]]; then
      LOGDUMP="$logdump_bin" "$parser" -n "$limit" "$trail_file" \
        | awk -v no="$file_no" -v file="$trail_base" 'BEGIN{FS=OFS="|"} {print no, file, $0}' >> "$dat_path"
      parser_rc=${PIPESTATUS[0]}
    else
      LOGDUMP="$logdump_bin" "$parser" "$trail_file" \
        | awk -v no="$file_no" -v file="$trail_base" 'BEGIN{FS=OFS="|"} {print no, file, $0}' >> "$dat_path"
      parser_rc=${PIPESTATUS[0]}
    fi
    set -e
    [[ "$parser_rc" -eq 0 ]] || die "Parser failed for trail file: $trail_file"
  done
  echo "Output DAT: $dat_path" >&2
  rows="$(wc -l < "$dat_path" | tr -d ' ')"
  echo "Parsed rows: $rows" >&2
  [[ "$rows" -gt 0 ]] || die "Parser produced no rows: $dat_path"

  sql_file="$ext_dir/ogg_fk_trail_analyze_${label}.sql"
  [[ -n "$report_file" ]] || report_file="$ext_dir/ogg_fk_trail_analyze_${label}.lst"
  ext_dir_lit="$(sql_literal "$ext_dir")"
  dat_file_lit="$(sql_literal "$dat_file")"
  report_path="$(readlink -f "$report_file" 2>/dev/null || printf '%s\n' "$report_file")"
  pdb_sql=""
  [[ -n "$pdb" ]] && pdb_sql="alter session set container = $(sql_name "$pdb");"
  trail_prompt_lines=""
  for file_no in "${!trails[@]}"; do
    trail_prompt_lines+="prompt trail_file_$((file_no + 1))=${trails[$file_no]}"$'\n'
  done

  cat > "$sql_file" <<SQL
whenever sqlerror exit sql.sqlcode
set echo off feedback on heading on pages 100 lines 260 trimspool on tab off
connect $connect
$pdb_sql
create or replace directory $dir_name as $ext_dir_lit;
grant read, write on directory $dir_name to $schema;
begin
  execute immediate 'drop table $schema.OGG_FK_LGD_EXT purge';
exception when others then
  if sqlcode != -942 then raise; end if;
end;
/
begin
  execute immediate 'drop table $schema.OGG_FK_LGD_TMP purge';
exception when others then
  if sqlcode != -942 then raise; end if;
end;
/
create table $schema.OGG_FK_LGD_EXT (
  file_no varchar2(40), file_name varchar2(512),
  resv1 varchar2(4000), resv2 varchar2(4000), resv3 varchar2(4000),
  resv4 varchar2(4000), resv5 varchar2(4000), resv6 varchar2(4000),
  resv7 varchar2(4000), resv8 varchar2(4000), resv9 varchar2(4000),
  resv10 varchar2(4000), resv11 varchar2(4000), resv12 varchar2(4000), resv13 varchar2(4000)
)
organization external (
  type oracle_loader
  default directory $dir_name
  access parameters (
    records delimited by newline
    fields terminated by '|'
    missing field values are null
    reject rows with all null fields
    (file_no char(40), file_name char(512),
     resv1 char(4000), resv2 char(4000), resv3 char(4000), resv4 char(4000), resv5 char(4000),
     resv6 char(4000), resv7 char(4000), resv8 char(4000), resv9 char(4000), resv10 char(4000),
     resv11 char(4000), resv12 char(4000), resv13 char(4000))
  )
  location ($dat_file_lit)
)
reject limit unlimited;
create table $schema.OGG_FK_LGD_TMP nologging as
select case when regexp_like(trim(file_no), '^[0-9]+$') then to_number(trim(file_no)) end file_no,
       trim(file_name) file_name,
       trim(resv1) resv1, trim(resv2) resv2, trim(resv3) resv3,
       trim(resv4) resv4, trim(resv5) resv5, trim(resv6) resv6,
       trim(resv7) resv7, trim(resv8) resv8, trim(resv9) resv9,
       case when regexp_like(trim(resv10), '^[-]?[0-9]+$') then to_number(trim(resv10)) end resv10,
       trim(resv11) resv11, trim(resv12) resv12, trim(resv13) resv13,
       case when regexp_like(trim(file_no), '^[0-9]+$') and regexp_like(trim(resv10), '^[-]?[0-9]+$')
            then to_number(trim(file_no)) * 1000000000000000 + to_number(trim(resv10)) end global_rba
from $schema.OGG_FK_LGD_EXT
where resv1 is not null;
create index $schema.OGG_FK_LGD_TMP_I01 on $schema.OGG_FK_LGD_TMP(global_rba, resv1);
create index $schema.OGG_FK_LGD_TMP_I02 on $schema.OGG_FK_LGD_TMP(file_no, resv10, resv1);
begin
  dbms_stats.gather_table_stats(ownname => '$schema', tabname => 'OGG_FK_LGD_TMP', cascade => true);
exception when others then null;
end;
/
spool $report_path
prompt === Field Kit Trail SQL Analysis ===
prompt trail_count=${#trails[@]}
${trail_prompt_lines}prompt dat_file=$dat_path
prompt schema=$schema
prompt directory=$dir_name path=$ext_dir
prompt order_key=global_rba(file_no + rba), for multi-trail transaction analysis
prompt
prompt === Loaded Rows ===
select count(*) loaded_rows from $schema.OGG_FK_LGD_TMP;
prompt
prompt === Rows By Trail File ===
column file_name format a36
select file_no, file_name, count(*) rows_loaded, min(resv10) min_rba, max(resv10) max_rba
from $schema.OGG_FK_LGD_TMP
group by file_no, file_name
order by file_no;
prompt
prompt === Operation/Table Summary ===
column operation format a28
column table_name format a80
select nvl(resv6,'-') operation, nvl(resv11,'-') table_name, count(*) cnt
from $schema.OGG_FK_LGD_TMP
group by nvl(resv6,'-'), nvl(resv11,'-')
order by cnt desc fetch first 30 rows only;
prompt
prompt === Top Commit Size Candidates ===
column times format a28
column file_name format a36
column related_tables format a120
with ordered as (
  select t.*,
         max(case when resv1 = '(x00)' then global_rba end)
           over (order by global_rba rows between unbounded preceding and 1 preceding) begin_global_rba
  from $schema.OGG_FK_LGD_TMP t
  where global_rba is not null
), commits as (
  select b.*,
         (select count(*) from $schema.OGG_FK_LGD_TMP x
          where x.global_rba between nvl(b.begin_global_rba, b.global_rba) and b.global_rba) cnt,
         (select listagg(distinct substr(trim(x.resv6)||' '||trim(x.resv11),1,180), ', ' on overflow truncate)
          within group (order by substr(trim(x.resv6)||' '||trim(x.resv11),1,180))
          from $schema.OGG_FK_LGD_TMP x
          where x.global_rba between nvl(b.begin_global_rba, b.global_rba) and b.global_rba) related_tables
  from ordered b
  where b.resv1 = '(x02)'
)
select * from (
  select resv4||' '||resv5 times, file_name, resv10 commit_rba, cnt, resv11, related_tables
  from commits
  order by cnt desc, global_rba
) where rownum <= 20;
prompt
prompt === PK Update Candidates ===
with ordered as (
  select t.*,
         max(case when resv1 = '(x00)' then global_rba end)
           over (order by global_rba rows between unbounded preceding and current row) begin_global_rba,
         min(case when resv1 = '(x02)' then global_rba end)
           over (order by global_rba rows between current row and unbounded following) end_global_rba
  from $schema.OGG_FK_LGD_TMP t
  where global_rba is not null
), pk_rows as (
  select * from ordered
  where resv1 <> '(x03)' and upper(nvl(resv6,'-')) like '%PKUPDATE%'
)
select * from (
  select resv4||' '||resv5 times, file_name, resv10 rba, begin_global_rba, end_global_rba, resv6 operation, resv11 table_name
  from pk_rows
  order by global_rba
) where rownum <= 50;
spool off
exit
SQL

  echo "Running sqlplus external-table analysis. SQL: $sql_file" >&2
  local sqlplus_rc
  set +e
  sqlplus_run_file "$sql_file"
  sqlplus_rc=$?
  set -e
  if [[ "$sqlplus_rc" -ne 0 ]]; then
    echo "ERROR: sqlplus failed with exit code $sqlplus_rc" >&2
    echo "SQL file kept for review: $sql_file" >&2
    echo "DAT file kept for review: $dat_path" >&2
    return "$sqlplus_rc"
  fi
  echo "Analysis report: $report_file"
}

cmd_loaded_tx_analyze() {
  local schema="" connect="" pdb="" sqlplus_override="" threshold="" report_file="" report_dir=""
  while (($#)); do
    case "$1" in
      --schema|--oracle-schema) schema=$2; shift 2 ;;
      --connect|--oracle-admin-connect) connect=$2; shift 2 ;;
      --pdb|--oracle-pdb) pdb=$2; shift 2 ;;
      --sqlplus|--oracle-sqlplus) sqlplus_override=$2; shift 2 ;;
      --threshold|--large-tx-threshold|--tx-threshold) threshold=$2; shift 2 ;;
      --report) report_file=$2; shift 2 ;;
      --report-dir) report_dir=$2; shift 2 ;;
      *) die "Unknown loaded-tx-analyze option: $1" ;;
    esac
  done
  load_target
  [[ -n "$sqlplus_override" ]] && T_ORACLE_SQLPLUS="$sqlplus_override"
  [[ -n "$schema" ]] || schema="${T_ORACLE_SCHEMA:-SOE}"
  [[ -n "$connect" ]] || connect="${T_ORACLE_ADMIN_CONNECT:-/ as sysdba}"
  [[ -n "$pdb" ]] || pdb="${T_ORACLE_PDB:-}"
  [[ -n "$threshold" ]] || threshold="${OGG_FK_LARGE_TX_THRESHOLD:-1000}"
  [[ "$threshold" =~ ^[0-9]+$ ]] || die "Threshold must be a positive integer."
  ((threshold > 0)) || die "Threshold must be greater than zero."
  schema="$(sql_name "$schema")"

  [[ -n "$report_dir" ]] || report_dir="${T_ORACLE_EXT_DIR:-$(default_download_dir "sql-analysis")}"
  mkdir -p "$report_dir"
  report_dir="$(readlink -f "$report_dir" 2>/dev/null || printf '%s\n' "$report_dir")"
  [[ -n "$report_file" ]] || report_file="$report_dir/ogg_fk_loaded_tx_over_${threshold}.lst"
  local sql_file report_path pdb_sql
  sql_file="$report_dir/ogg_fk_loaded_tx_over_${threshold}.sql"
  report_path="$(readlink -f "$report_file" 2>/dev/null || printf '%s\n' "$report_file")"
  pdb_sql=""
  [[ -n "$pdb" ]] && pdb_sql="alter session set container = $(sql_name "$pdb");"

  cat > "$sql_file" <<SQL
whenever sqlerror exit sql.sqlcode
set echo off feedback on heading on pages 100 lines 280 trimspool on tab off verify off
connect $connect
$pdb_sql
declare
  l_count number;
begin
  select count(*)
    into l_count
    from all_tables
   where owner = '$schema'
     and table_name = 'OGG_FK_LGD_TMP';
  if l_count = 0 then
    raise_application_error(-20010, 'Run menu 9 first. $schema.OGG_FK_LGD_TMP does not exist.');
  end if;
end;
/
spool $report_path
prompt === Loaded Trail Large Transaction Analysis ===
prompt schema=$schema
prompt threshold_dml_records=$threshold
prompt source_table=$schema.OGG_FK_LGD_TMP
prompt
prompt === Loaded Rows ===
select count(*) loaded_rows,
       count(distinct file_name) loaded_files,
       min(global_rba) min_global_rba,
       max(global_rba) max_global_rba
  from $schema.OGG_FK_LGD_TMP;
prompt
prompt === Rows By Trail File ===
column file_name format a36
select file_no, file_name, count(*) rows_loaded, min(resv10) min_rba, max(resv10) max_rba
  from $schema.OGG_FK_LGD_TMP
 group by file_no, file_name
 order by file_no;
prompt
prompt === Transactions With DML Records >= $threshold ===
column commit_time format a25
column begin_file format a32
column commit_file format a32
column related_tables format a130
with ordered as (
  select t.*,
         max(case when resv1 = '(x00)' then global_rba end)
           over (order by global_rba rows between unbounded preceding and 1 preceding) begin_global_rba
    from $schema.OGG_FK_LGD_TMP t
   where global_rba is not null
), commits as (
  select global_rba commit_global_rba,
         nvl(begin_global_rba, global_rba) tx_begin_global_rba,
         file_name commit_file,
         resv10 commit_rba,
         resv4||' '||resv5 commit_time
    from ordered
   where resv1 = '(x02)'
), tx_stats as (
  select c.commit_time,
         min(x.file_name) keep (dense_rank first order by x.global_rba) begin_file,
         min(x.resv10) keep (dense_rank first order by x.global_rba) begin_rba,
         c.commit_file,
         c.commit_rba,
         c.tx_begin_global_rba,
         c.commit_global_rba,
         count(*) total_records,
         sum(case when x.resv11 is not null then 1 else 0 end) dml_records,
         count(distinct case when x.resv11 is not null then x.resv11 end) table_count,
         listagg(distinct case when x.resv11 is not null then substr(trim(x.resv6)||' '||trim(x.resv11),1,180) end,
                 ', ' on overflow truncate)
           within group (order by case when x.resv11 is not null then substr(trim(x.resv6)||' '||trim(x.resv11),1,180) end) related_tables
    from commits c
    join $schema.OGG_FK_LGD_TMP x
      on x.global_rba between c.tx_begin_global_rba and c.commit_global_rba
   group by c.commit_time, c.commit_file, c.commit_rba, c.tx_begin_global_rba, c.commit_global_rba
)
select *
  from (
    select commit_time, begin_file, begin_rba, commit_file, commit_rba,
           total_records, dml_records, table_count,
           tx_begin_global_rba, commit_global_rba,
           nvl(related_tables, '-') related_tables
      from tx_stats
     where dml_records >= $threshold
     order by dml_records desc, total_records desc, commit_global_rba
  )
 where rownum <= 100;
prompt
prompt === Top Transactions By DML Records ===
with ordered as (
  select t.*,
         max(case when resv1 = '(x00)' then global_rba end)
           over (order by global_rba rows between unbounded preceding and 1 preceding) begin_global_rba
    from $schema.OGG_FK_LGD_TMP t
   where global_rba is not null
), commits as (
  select global_rba commit_global_rba,
         nvl(begin_global_rba, global_rba) tx_begin_global_rba,
         file_name commit_file,
         resv10 commit_rba,
         resv4||' '||resv5 commit_time
    from ordered
   where resv1 = '(x02)'
), tx_stats as (
  select c.commit_time, c.commit_file, c.commit_rba, c.commit_global_rba,
         count(*) total_records,
         sum(case when x.resv11 is not null then 1 else 0 end) dml_records,
         count(distinct case when x.resv11 is not null then x.resv11 end) table_count
    from commits c
    join $schema.OGG_FK_LGD_TMP x
      on x.global_rba between c.tx_begin_global_rba and c.commit_global_rba
   group by c.commit_time, c.commit_file, c.commit_rba, c.commit_global_rba
)
select *
  from (
    select commit_time, commit_file, commit_rba, total_records, dml_records, table_count
      from tx_stats
     order by dml_records desc, total_records desc, commit_global_rba
  )
 where rownum <= 20;
spool off
exit
SQL

  echo "Running loaded temp-table transaction analysis. SQL: $sql_file" >&2
  local sqlplus_rc
  set +e
  sqlplus_run_file "$sql_file"
  sqlplus_rc=$?
  set -e
  if [[ "$sqlplus_rc" -ne 0 ]]; then
    echo "ERROR: sqlplus failed with exit code $sqlplus_rc" >&2
    echo "SQL file kept for review: $sql_file" >&2
    return "$sqlplus_rc"
  fi
  echo "Large transaction report: $report_file"
}

trail_set_label() {
  local count=$#
  local path base prefix seq9 seq first_prefix="" first_seq="" last_seq="" first_base="" last_base="" all_seq=1 same_prefix=1 label
  ((count > 0)) || { printf 'trail\n'; return; }
  if ((count == 1)); then
    base=${1##*/}
    label="$base"
  else
    first_base=${1##*/}
    for path in "$@"; do
      base=${path##*/}
      last_base="$base"
      if [[ "$base" =~ ^(.+)([0-9]{9})$ ]]; then
        prefix="${BASH_REMATCH[1]}"
        seq9="${BASH_REMATCH[2]}"
        seq=$((10#$seq9))
        [[ -n "$first_seq" ]] || first_seq="$seq"
        last_seq="$seq"
        if [[ -z "$first_prefix" ]]; then
          first_prefix="$prefix"
        elif [[ "$first_prefix" != "$prefix" ]]; then
          same_prefix=0
        fi
      else
        all_seq=0
      fi
    done
    if ((all_seq == 1 && same_prefix == 1)); then
      label="${first_prefix}_${first_seq}_${last_seq}"
    else
      label="multi_${count}_${first_base}_${last_base}"
    fi
  fi
  label=${label//[^A-Za-z0-9_.-]/_}
  printf '%s\n' "$label"
}

cmd_init_config() {
  local output="$DEFAULT_CONFIG_NAME" force=0
  while (($#)); do
    case "$1" in
      --output) output=$2; shift 2 ;;
      --force) force=1; shift ;;
      *) die "Unknown init-config option: $1" ;;
    esac
  done
  if [[ -e "$output" && "$force" -ne 1 ]]; then
    die "Refusing to overwrite existing file: $output"
  fi
  cat > "$output" <<'JSON'
{
  "targets": {
    "onprem-rest": {
      "description": "On-prem GoldenGate Admin Service through REST, using host-local adminclient/logdump. No Docker or sudo required.",
      "admin_url": "https://onprem-ogg-host:9011/services/v2",
      "admin_user": "oggadmin",
      "mode": "rest",
      "cli_mode": "local",
      "client_ogg_home": "/u01/ogg",
      "admin_client_url": "https://onprem-ogg-host:9011",
      "oracle_schema": "SOE",
      "oracle_admin_connect": "/ as sysdba",
      "oracle_pdb": "",
      "oracle_ext_dir_name": "OGG_FK_TRAIL_DIR"
    },
    "remote-source": {
      "description": "Self-managed GoldenGate reached through SSH. Nothing is installed on the customer host.",
      "admin_url": "http://localhost:9011",
      "admin_user": "oggadmin",
      "mode": "ssh",
      "ssh": "ogg@customer-ogg-host",
      "ogg_home": "/u01/ogg",
      "trail_dirs": [
        "/u02/Deployment/var/lib/data",
        "/u01/ogg/dirdat"
      ]
    },
    "source": {
      "description": "Self-managed GoldenGate on the current host.",
      "admin_url": "http://localhost:9011",
      "admin_user": "oggadmin",
      "mode": "local",
      "ogg_home": "/u01/ogg",
      "trail_dirs": [
        "/u02/Deployment/var/lib/data",
        "/u01/ogg/dirdat"
      ]
    },
    "oci-managed": {
      "description": "OCI GoldenGate managed deployment through Admin Service REST only.",
      "admin_url": "https://deployment-console-host:9011",
      "admin_user": "oggadmin",
      "mode": "rest"
    }
  }
}
JSON
  echo "Wrote sample config: $output"
  echo "Edit target host/user/path values. Do not store customer passwords in this file."
}

ask() {
  local prompt=$1
  local default=${2-}
  local value
  if [[ -n "$default" ]]; then
    printf '%s [%s]: ' "$prompt" "$default" >&2
  else
    printf '%s: ' "$prompt" >&2
  fi
  IFS= read -r value
  printf '%s\n' "${value:-$default}"
}

menu_call() {
  local rc
  set +e
  "$@"
  rc=$?
  set -e
  if [[ "$rc" -ne 0 ]]; then
    echo "Returned to menu. Last command exit code: $rc" >&2
  fi
  return 0
}

MENU_TRAIL_NAME=""
MENU_SEQ=""

menu_choose_rest_sequence() {
  local trail_choice pos
  MENU_TRAIL_NAME=""
  MENU_SEQ=""
  if ((${#LAST_TRAIL_NAMES[@]})); then
    echo "Recent REST trail metadata:"
    for pos in "${!LAST_TRAIL_NAMES[@]}"; do
      printf '  %d. %s sequence=%s producer=%s consumer=%s\n' \
        "$((pos + 1))" "${LAST_TRAIL_NAMES[$pos]}" "${LAST_TRAIL_SEQ[$pos]:--}" "${LAST_TRAIL_PRODUCERS[$pos]:--}" "${LAST_TRAIL_CONSUMERS[$pos]:--}"
    done
    trail_choice="$(ask "Trail number/name" "1")"
  else
    echo "Tip: option 4 shows REST trail metadata first."
    trail_choice="$(ask "Trail name" "")"
  fi
  if [[ -n "$trail_choice" && "$trail_choice" =~ ^[0-9]+$ && ${#LAST_TRAIL_NAMES[@]} -gt 0 ]]; then
    pos=$((trail_choice - 1))
    if ((pos >= 0 && pos < ${#LAST_TRAIL_NAMES[@]})); then
      MENU_TRAIL_NAME="${LAST_TRAIL_NAMES[$pos]}"
      MENU_SEQ="${LAST_TRAIL_SEQ[$pos]}"
    fi
  else
    MENU_TRAIL_NAME="$trail_choice"
  fi
  [[ -n "$MENU_TRAIL_NAME" ]] || die "Trail name is required."
  [[ -n "$MENU_SEQ" ]] || MENU_SEQ="$(ask "Sequence or range" "")"
  [[ -n "$MENU_SEQ" ]] || die "Sequence is required."
  echo "Selected trail $MENU_TRAIL_NAME sequence $MENU_SEQ"
}

cmd_menu() {
  load_target
  local choice limit local_file default_choice prompt trail_choice pos trail_name seq trail
  while true; do
    load_target
    echo
    echo "GoldenGate Field Kit $VERSION"
    echo "Active target: $T_NAME  admin_connect=$(default_admin_client_url)"
    echo "Targets: $(target_names | paste -sd, -)"
    echo "1. List targets"
    echo "2. REST snapshot"
    echo "3. Admin Client interactive/login"
    echo "4. List trail metadata/files"
    echo "5. Download trail sequence + local Logdump interactive"
    echo "6. Download trail sequence only"
    echo "7. Local/downloaded file Logdump interactive"
    echo "8. Advanced direct Logdump on OGG host filesystem"
    echo "9. SQL external-table analysis of downloaded trail"
    echo "10. Analyze loaded temp table large transactions"
    echo "0. Exit"
    choice="$(ask "Select" "0")"
    case "$choice" in
      1) menu_call cmd_targets ;;
      2) menu_call cmd_snapshot ;;
      3)
        load_target
        local connect_url connect_user answer
        connect_url="$(default_admin_client_url)"
        connect_user="${T_ADMIN_USER:-oggadmin}"
        echo "Target Admin Client URL: ${connect_url:-not configured}"
        echo "Connect command: connect $connect_url as $connect_user !"
        answer="$(ask "Auto-connect with this target? Y/n" "Y")"
        if [[ "$answer" =~ ^[Yy] ]]; then
          menu_call cmd_admin_shell --connect --connect-url "$connect_url" --connect-user "$connect_user"
        else
          menu_call cmd_admin_shell
        fi
        ;;
      4)
        limit="$(ask "Limit" "30")"
        menu_call cmd_trails_list --limit "$limit" --no-resolve-files
        ;;
      5)
        menu_choose_rest_sequence
        menu_call cmd_download_logdump_shell --trail-name "$MENU_TRAIL_NAME" --seq "$MENU_SEQ"
        ;;
      6)
        menu_choose_rest_sequence
        menu_call cmd_trail_download --trail-name "$MENU_TRAIL_NAME" --seq "$MENU_SEQ"
        ;;
      7)
        local_file="$(choose_downloaded_trail_file 30)"
        [[ -n "$local_file" ]] || die "Local trail file is required."
        if [[ ! -f "$local_file" ]]; then
          echo "Local trail file not found: $local_file" >&2
          continue
        fi
        menu_call cmd_download_logdump_shell --trail "$local_file"
        ;;
      8)
        echo "Advanced direct mode opens a trail file visible to the configured CLI runner: $(describe_cli)"
        if ((${#LAST_TRAIL_NAMES[@]})); then
          echo "Recent REST trail metadata:"
          for pos in "${!LAST_TRAIL_NAMES[@]}"; do
            printf '  %d. %s sequence=%s producer=%s consumer=%s\n' \
              "$((pos + 1))" "${LAST_TRAIL_NAMES[$pos]}" "${LAST_TRAIL_SEQ[$pos]:--}" "${LAST_TRAIL_PRODUCERS[$pos]:--}" "${LAST_TRAIL_CONSUMERS[$pos]:--}"
          done
          default_choice="1"
          prompt="Trail number/name/full path ('-' = plain logdump)"
        else
          default_choice=""
          prompt="Trail name/full path (empty = plain logdump)"
        fi
        trail_choice="$(ask "$prompt" "$default_choice")"
        [[ "$trail_choice" == "-" ]] && trail_choice=""
        trail_name=""
        seq=""
        trail=""
        if [[ -n "$trail_choice" && "$trail_choice" =~ ^[0-9]+$ && ${#LAST_TRAIL_NAMES[@]} -gt 0 ]]; then
          pos=$((trail_choice - 1))
          if ((pos >= 0 && pos < ${#LAST_TRAIL_NAMES[@]})); then
            trail_name="${LAST_TRAIL_NAMES[$pos]}"
            seq="${LAST_TRAIL_SEQ[$pos]}"
            [[ -n "$seq" ]] || seq="$(ask "Sequence" "")"
            echo "Selected trail $trail_name sequence $seq"
          fi
        elif [[ "$trail_choice" == /* ]]; then
          trail="$trail_choice"
        elif [[ -n "$trail_choice" ]]; then
          trail_name="$trail_choice"
          seq="$(ask "Sequence" "")"
        fi
        if [[ -n "$trail" ]]; then
          menu_call cmd_logdump_shell --trail "$trail"
        elif [[ -n "$trail_name" && -n "$seq" ]]; then
          menu_call cmd_logdump_shell --trail-name "$trail_name" --seq "$seq"
        else
          menu_call cmd_logdump_shell
        fi
        ;;
      9)
        local -a local_files analyze_args
        mapfile -t local_files < <(choose_downloaded_trail_files 30)
        ((${#local_files[@]})) || die "Trail file is required."
        analyze_args=()
        for local_file in "${local_files[@]}"; do
          if [[ ! -f "$local_file" ]]; then
            echo "Local trail file not found: $local_file" >&2
            continue 2
          fi
          analyze_args+=(--trail "$local_file")
        done
        local schema limit
        schema="$(ask "Oracle analysis schema" "${T_ORACLE_SCHEMA:-SOE}")"
        limit="$(ask "Parse record limit per file (empty = all)" "")"
        if [[ -n "$limit" ]]; then
          menu_call cmd_trail_sql_analyze "${analyze_args[@]}" --schema "$schema" --limit "$limit"
        else
          menu_call cmd_trail_sql_analyze "${analyze_args[@]}" --schema "$schema"
        fi
        ;;
      10)
        local schema threshold
        schema="$(ask "Oracle analysis schema" "${T_ORACLE_SCHEMA:-SOE}")"
        threshold="$(ask "Large transaction DML record threshold" "${OGG_FK_LARGE_TX_THRESHOLD:-1000}")"
        menu_call cmd_loaded_tx_analyze --schema "$schema" --threshold "$threshold"
        ;;
      0) return 0 ;;
      *) echo "Unknown choice: $choice" ;;
    esac
  done
}

parse_global_options() {
  while (($#)); do
    case "$1" in
      --config) CONFIG_PATH=$2; shift 2 ;;
      --target) TARGET_NAME=$2; shift 2 ;;
      --mode) OPT_MODE=$2; shift 2 ;;
      --ssh) OPT_SSH=$2; shift 2 ;;
      --container) OPT_CONTAINER=$2; shift 2 ;;
      --docker) OPT_DOCKER=$2; shift 2 ;;
      --ogg-home) OPT_OGG_HOME=$2; shift 2 ;;
      --admin-url) OPT_ADMIN_URL=$2; shift 2 ;;
      --user|--admin-user) OPT_ADMIN_USER=$2; shift 2 ;;
      --cli-mode) OPT_CLI_MODE=$2; shift 2 ;;
      --cli-ssh) OPT_CLI_SSH=$2; shift 2 ;;
      --cli-container) OPT_CLI_CONTAINER=$2; shift 2 ;;
      --cli-docker) OPT_CLI_DOCKER=$2; shift 2 ;;
      --client-ogg-home) OPT_CLIENT_OGG_HOME=$2; shift 2 ;;
      --adminclient-path) OPT_ADMINCLIENT_PATH=$2; shift 2 ;;
      --logdump-path) OPT_LOGDUMP_PATH=$2; shift 2 ;;
      --admin-client-url) OPT_ADMIN_CLIENT_URL=$2; shift 2 ;;
      --download-dir) OPT_DOWNLOAD_DIR=$2; shift 2 ;;
      --download-client-ogg-home) OPT_DOWNLOAD_CLIENT_OGG_HOME=$2; shift 2 ;;
      --download-logdump-path) OPT_DOWNLOAD_LOGDUMP_PATH=$2; shift 2 ;;
      --oracle-schema) OPT_ORACLE_SCHEMA=$2; shift 2 ;;
      --oracle-admin-connect) OPT_ORACLE_ADMIN_CONNECT=$2; shift 2 ;;
      --oracle-pdb) OPT_ORACLE_PDB=$2; shift 2 ;;
      --oracle-sqlplus) OPT_ORACLE_SQLPLUS=$2; shift 2 ;;
      --oracle-ext-dir) OPT_ORACLE_EXT_DIR=$2; shift 2 ;;
      --oracle-ext-dir-name) OPT_ORACLE_EXT_DIR_NAME=$2; shift 2 ;;
      --trail-dir) OPT_TRAIL_DIRS+=("$2"); shift 2 ;;
      --cli-trail-dir) OPT_CLI_TRAIL_DIRS+=("$2"); shift 2 ;;
      --cli-trail-search-root) OPT_CLI_TRAIL_SEARCH_ROOTS+=("$2"); shift 2 ;;
      --insecure) OPT_INSECURE=1; shift ;;
      --no-auth) OPT_NO_AUTH=1; shift ;;
      --timeout) OPT_TIMEOUT=$2; shift 2 ;;
      --version) echo "$VERSION"; exit 0 ;;
      --help|-h) usage; exit 0 ;;
      --) shift; break ;;
      -*) die "Unknown option: $1" ;;
      *) break ;;
    esac
  done
  REMAINING_ARGS=("$@")
}

main() {
  parse_global_options "$@"
  local command="${REMAINING_ARGS[0]:-menu}"
  local args=("${REMAINING_ARGS[@]:1}")
  case "$command" in
    init-config) cmd_init_config "${args[@]}" ;;
    targets) cmd_targets "${args[@]}" ;;
    snapshot) cmd_snapshot "${args[@]}" ;;
    rest-get) cmd_rest_get "${args[@]}" ;;
    trails-list|trails) cmd_trails_list "${args[@]}" ;;
    trail-download|download-trail) cmd_trail_download "${args[@]}" ;;
    download-logdump-shell|trail-download-logdump|trail-logdump-shell) cmd_download_logdump_shell "${args[@]}" ;;
    download-logdump-run|trail-logdump-run) cmd_download_logdump_run "${args[@]}" ;;
    trail-sql-analyze|sql-analyze|external-table-analyze) cmd_trail_sql_analyze "${args[@]}" ;;
    loaded-tx-analyze|tx-analyze|large-tx-analyze) cmd_loaded_tx_analyze "${args[@]}" ;;
    admin-shell|adminclient) cmd_admin_shell "${args[@]}" ;;
    admin-run) cmd_admin_run "${args[@]}" ;;
    logdump-shell|logdump) cmd_logdump_shell "${args[@]}" ;;
    logdump-run) cmd_logdump_run "${args[@]}" ;;
    menu) cmd_menu "${args[@]}" ;;
    help) usage ;;
    *) die "Unknown command: $command" ;;
  esac
}

main "$@"
