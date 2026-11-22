#!/usr/bin/env bash

if [ -z "${BASH_VERSION:-}" ] || shopt -qo posix 2>/dev/null; then
  if command -v bash >/dev/null 2>&1; then
    exec bash "$0" "$@"
  fi
  echo "ERROR: lab13_init.sh requires bash." >&2
  exit 1
fi

set -Eeuo pipefail

LAB13_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_HOME="${LAB_HOME:-$(cd "${LAB13_DIR}/../.." && pwd)}"
LAB_LOGGING="${LAB_HOME}/troubleshooting/scripts/lab_init_logging.sh"
LAB12_INIT="${LAB12_INIT:-${LAB13_DIR}/../lab12/lab12_init.sh}"
TARGET_DB_CONTAINER="${TARGET_DB_CONTAINER:-demo_otrg_23ai}"
TARGET_PDB="${TARGET_PDB:-ORCLPDB1}"
TARGET_ORDS_PORT="${TARGET_ORDS_PORT:-36080}"
APEX_WORKSPACE="${APEX_WORKSPACE:-OGG}"
APEX_SCHEMA="${APEX_SCHEMA:-GGADMIN}"
APP101_EXPORT="${APP101_EXPORT:-${LAB_HOME}/oracle/pkg/f101_ogg_console.sql}"

if [ ! -f "${LAB_LOGGING}" ]; then
  echo "ERROR: shared Lab logging helper not found: ${LAB_LOGGING}" >&2
  exit 1
fi
source "${LAB_LOGGING}"
lab_init_log_begin lab13 lab13-init

if [ ! -f "${LAB12_INIT}" ]; then
  echo "ERROR: APEX/ORDS setup entry point not found: ${LAB12_INIT}" >&2
  exit 1
fi
if [ ! -f "${APP101_EXPORT}" ]; then
  echo "ERROR: App 101 export not found: ${APP101_EXPORT}" >&2
  exit 1
fi

app101_state() {
  docker exec -u oracle "${TARGET_DB_CONTAINER}" bash -lc "sqlplus -s / as sysdba <<'SQL'
set pages 0 feedback off heading off verify off echo off trimspool on
whenever sqlerror exit sql.sqlcode
alter session set container=${TARGET_PDB};
select 'APP101_STATE=' ||
       (select count(*) from apex_applications
        where workspace = upper('${APEX_WORKSPACE}') and application_id = 101) || '|' ||
       (select count(*) from apex_applications
        where workspace = upper('${APEX_WORKSPACE}') and application_id = 101
          and upper(alias) = 'GOLDENGATE-CONSOLE') || '|' ||
       (select count(*) from apex_application_pages
        where application_id = 101 and page_id = 200)
from dual;
exit
SQL" | sed -n 's/^[[:space:]]*APP101_STATE=//p' | tail -1
}

install_app101() {
  local state=""
  local app_count="0"
  local alias_ready="0"
  local page_ready="0"
  local app_offset=""
  local container_export="/tmp/lab13_f101_ogg_console.sql"

  state="$(app101_state)"
  IFS='|' read -r app_count alias_ready page_ready <<<"${state:-0|0|0}"
  if [ "${app_count:-0}" -eq 1 ] && [ "${alias_ready:-0}" -eq 1 ] && [ "${page_ready:-0}" -eq 1 ]; then
    echo "SKIP: App 101 GOLDENGATE-CONSOLE and Page 200 are already installed."
    return 0
  fi

  app_offset="$(sed -n 's/.*,p_default_id_offset=>\([0-9][0-9]*\).*/\1/p' "${APP101_EXPORT}" | head -1)"
  if [[ ! "${app_offset}" =~ ^[0-9]+$ ]]; then
    echo "ERROR: App 101 export does not contain a valid p_default_id_offset." >&2
    return 1
  fi

  echo "==> Import GoldenGate Integrated Operations Console App 101"
  docker cp "${APP101_EXPORT}" "${TARGET_DB_CONTAINER}:${container_export}"
  docker exec -u root "${TARGET_DB_CONTAINER}" \
    chown oracle:oinstall "${container_export}"
  docker exec -u root "${TARGET_DB_CONTAINER}" \
    chmod 0644 "${container_export}"
  docker exec -i -u oracle "${TARGET_DB_CONTAINER}" bash -lc 'sqlplus -s / as sysdba' <<SQL
whenever sqlerror exit sql.sqlcode rollback
set define off
alter session set container=${TARGET_PDB};
begin
  apex_application_install.set_workspace('${APEX_WORKSPACE}');
  apex_application_install.set_schema('${APEX_SCHEMA}');
  apex_application_install.set_application_id(101);
  apex_application_install.set_offset(${app_offset});
  apex_application_install.set_application_alias('GOLDENGATE-CONSOLE');
  apex_application_install.set_auto_install_sup_obj(true);
end;
/
@${container_export}
exit
SQL

  state="$(app101_state)"
  if [ "${state}" != "1|1|1" ]; then
    echo "ERROR: App 101 validation failed after import: ${state:-not found}" >&2
    return 1
  fi
  echo "OK: App 101, Supporting Objects, and Data Fabric Designer Page 200 are installed."
}

verify_app101_endpoint() {
  local app_url="http://127.0.0.1:${TARGET_ORDS_PORT}/ords/r/ogg/goldengate-console"
  local response_file="/tmp/lab13-app101-response.$$"
  local http_code=""
  local attempt=1

  while [ "${attempt}" -le 12 ]; do
    http_code="$(curl -sS -o "${response_file}" -w '%{http_code}' --max-time 15 "${app_url}" || true)"
    if ! grep -Eiq "Application not found|Sorry, this page isn't available" "${response_file}" 2>/dev/null; then
      case "${http_code}" in
        2??|3??)
          rm -f "${response_file}"
          echo "OK: App 101 endpoint is available (HTTP ${http_code}): ${app_url}"
          return 0
          ;;
      esac
    fi
    sleep 2
    attempt=$((attempt + 1))
  done

  rm -f "${response_file}"
  echo "ERROR: App 101 endpoint did not become available: ${app_url}" >&2
  return 1
}

echo "INFO: Chapter 13 compatibility entry point; delegating to ${LAB12_INIT}"
bash "${LAB12_INIT}" "$@"

echo "==> Prepare the Chapter 13 GoldenGate Integrated Operations Console"
install_app101
verify_app101_endpoint
echo "OK: Chapter 13 App 101 is ready."
lab_init_log_finish
