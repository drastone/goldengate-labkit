#!/usr/bin/env bash

set -Eeuo pipefail

LAB12_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DB_CONTAINER="${TARGET_DB_CONTAINER:-demo_osrc_23ai}"
HOST_ORDS_PORT="${HOST_ORDS_PORT:-35080}"
LAB12_ROLE="${LAB12_ROLE:-source}"
source "${LAB12_DIR}/lab12_common.sh"

lab12_begin_stage "lab12-configure-source-apps"

SOURCE_APP_DIR="${SOURCE_APP_DIR:-${LAB12_DIR}/apps}"
SOURCE_APP_CONTAINER_DIR="/home/oracle/labs/lab12/apps"
SOURCE_APP_IDS=(100 102 110 120 130 140)
APEX_WORKSPACE_NAME="${APEX_WORKSPACE_NAME:-OGG}"
APEX_WORKSPACE_ADMIN="${APEX_WORKSPACE_ADMIN:-GGADMIN}"
APEX_SOURCE_USERS="${APEX_SOURCE_USERS:-CALLCENTER01,NEWBIZ01,CLAIMS01,SIU01}"
THEME_REPAIR_FILE="repair_subscribed_theme.sql"

lab12_require_command docker
lab12_require_running_container

stage_source_app() {
  local app_id="$1"
  local host_export="${SOURCE_APP_DIR}/f${app_id}.sql"
  local container_export="${SOURCE_APP_CONTAINER_DIR}/f${app_id}.sql"
  local host_sha container_sha

  if [ ! -f "${host_export}" ]; then
    lab12_log "ERROR: Source APEX application export not found: ${host_export}"
    return 1
  fi

  host_sha="$(sha256sum "${host_export}" | awk '{print $1}')"
  container_sha="$(docker exec "${TARGET_DB_CONTAINER}" sha256sum "${container_export}" 2>/dev/null | awk '{print $1}' || true)"
  if [ "${host_sha}" = "${container_sha}" ]; then
    lab12_log "SKIP: Source App ${app_id} export is already staged."
    return
  fi

  docker exec -u root "${TARGET_DB_CONTAINER}" mkdir -p "${SOURCE_APP_CONTAINER_DIR}"
  docker cp "${host_export}" "${TARGET_DB_CONTAINER}:${container_export}"
  docker exec -u root "${TARGET_DB_CONTAINER}" chown oracle:oinstall "${container_export}"
  docker exec -u root "${TARGET_DB_CONTAINER}" chmod 644 "${container_export}"
  lab12_log "OK: staged Source App ${app_id} export."
}

stage_theme_repair() {
  local host_file="${SOURCE_APP_DIR}/${THEME_REPAIR_FILE}"
  local container_file="${SOURCE_APP_CONTAINER_DIR}/${THEME_REPAIR_FILE}"
  local host_sha container_sha

  if [ ! -f "${host_file}" ]; then
    lab12_log "ERROR: Theme repair SQL not found: ${host_file}"
    return 1
  fi

  host_sha="$(sha256sum "${host_file}" | awk '{print $1}')"
  container_sha="$(docker exec "${TARGET_DB_CONTAINER}" sha256sum "${container_file}" 2>/dev/null | awk '{print $1}' || true)"
  if [ "${host_sha}" = "${container_sha}" ]; then
    lab12_log "SKIP: Theme repair SQL is already staged."
    return
  fi

  docker exec -u root "${TARGET_DB_CONTAINER}" mkdir -p "${SOURCE_APP_CONTAINER_DIR}"
  docker cp "${host_file}" "${TARGET_DB_CONTAINER}:${container_file}"
  docker exec -u root "${TARGET_DB_CONTAINER}" chown oracle:oinstall "${container_file}"
  docker exec -u root "${TARGET_DB_CONTAINER}" chmod 644 "${container_file}"
  lab12_log "OK: staged Theme 42 repair SQL."
}

source_app_count() {
  local app_id="$1"

  docker exec -u oracle "${TARGET_DB_CONTAINER}" bash -lc "sqlplus -s / as sysdba <<'SQL'
set pages 0 feedback off heading off verify off echo off trimspool on
whenever sqlerror exit failure
alter session set container=${TARGET_PDB};
select 'APEX_APP_COUNT=' || count(*)
from apex_applications
where workspace = upper('${APEX_WORKSPACE_NAME}')
  and application_id = ${app_id};
exit
SQL" | sed -n 's/^[[:space:]]*APEX_APP_COUNT=//p' | tail -1
}

import_source_app() {
  local app_id="$1"
  local host_export="${SOURCE_APP_DIR}/f${app_id}.sql"
  local container_export="${SOURCE_APP_CONTAINER_DIR}/f${app_id}.sql"
  local app_count app_offset

  app_count="$(source_app_count "${app_id}")"
  if [ "${app_count:-0}" -ne 0 ]; then
    lab12_log "SKIP: Source App ${app_id} is already installed."
    return
  fi

  app_offset="$(sed -n 's/.*,p_default_id_offset=>\([0-9][0-9]*\).*/\1/p' "${host_export}" | head -1)"
  if [[ ! "${app_offset}" =~ ^[0-9]+$ ]]; then
    lab12_log "ERROR: App ${app_id} export does not contain a valid p_default_id_offset."
    return 1
  fi

  lab12_log "==> Import Source App ${app_id}"
  docker exec -u oracle "${TARGET_DB_CONTAINER}" bash -lc \
    "sqlplus -s / as sysdba <<'SQL'
whenever sqlerror exit failure rollback
set define off
alter session set container=${TARGET_PDB};
begin
  apex_application_install.set_workspace('${APEX_WORKSPACE_NAME}');
  apex_application_install.set_schema('${APEX_WORKSPACE_ADMIN}');
  apex_application_install.set_application_id(${app_id});
  apex_application_install.set_offset(${app_offset});
end;
/
@${container_export}
exit
SQL"

  app_count="$(source_app_count "${app_id}")"
  if [ "${app_count:-0}" -ne 1 ]; then
    lab12_log "ERROR: Source App ${app_id} was not found after import."
    return 1
  fi
  lab12_log "OK: imported Source App ${app_id}."
}

stage_theme_repair

for app_id in "${SOURCE_APP_IDS[@]}"; do
  stage_source_app "${app_id}"
  import_source_app "${app_id}"
done

docker exec -u oracle "${TARGET_DB_CONTAINER}" bash -lc "sqlplus -s / as sysdba <<'SQL'
whenever sqlerror exit failure rollback
set serveroutput on feedback off verify off echo off
alter session set container=${TARGET_PDB};
declare
  l_user_id number;
begin
  apex_util.set_workspace(p_workspace => '${APEX_WORKSPACE_NAME}');
  for r in (
    select trim(regexp_substr('${APEX_SOURCE_USERS}', '[^,]+', 1, level)) user_name
    from dual
    connect by regexp_substr('${APEX_SOURCE_USERS}', '[^,]+', 1, level) is not null
  ) loop
    l_user_id := apex_util.get_user_id(p_username => r.user_name);
    if l_user_id is null then
      apex_util.create_user(
        p_user_name                    => r.user_name,
        p_email_address                => lower(r.user_name) || '@example.invalid',
        p_web_password                 => '${LAB_PASSWORD}',
        p_developer_privs              => null,
        p_default_schema               => '${APEX_WORKSPACE_ADMIN}',
        p_account_locked               => 'N',
        p_change_password_on_first_use => 'N',
        p_first_password_use_occurred  => 'Y');
      dbms_output.put_line('CREATED: ' || r.user_name);
    else
      apex_util.edit_user(
        p_user_id                      => l_user_id,
        p_user_name                    => r.user_name,
        p_account_expiry               => date '2099-12-31',
        p_account_locked               => 'N',
        p_failed_access_attempts       => 0,
        p_change_password_on_first_use => 'N',
        p_first_password_use_occurred  => 'Y');
      apex_util.unexpire_workspace_account(p_user_name => r.user_name);
      apex_util.unexpire_end_user_account(p_user_name => r.user_name);
      apex_util.unlock_account(p_user_name => r.user_name);
      dbms_output.put_line('PRESERVED: ' || r.user_name);
    end if;
  end loop;
  commit;
end;
/
exit
SQL"

lab12_log "OK: Source APEX applications ${SOURCE_APP_IDS[*]} and demo users are ready."
lab12_finish_stage
