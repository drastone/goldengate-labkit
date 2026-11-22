#!/usr/bin/env bash

if [ -z "${BASH_VERSION:-}" ] || shopt -qo posix 2>/dev/null; then
  if command -v bash >/dev/null 2>&1; then
    exec bash "$0" "$@"
  fi
  echo "ERROR: lab18_init.sh requires bash." >&2
  exit 1
fi

set -Eeuo pipefail

LAB18_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="${APP_DIR:-${LAB18_DIR}/apps}"
APP340_DIR="${APP340_DIR:-${LAB18_DIR}/app340}"
TARGET_DB_CONTAINER="${TARGET_DB_CONTAINER:-demo_otrg_23ai}"
TARGET_PDB="${TARGET_PDB:-ORCLPDB1}"
APEX_WORKSPACE_NAME="${APEX_WORKSPACE_NAME:-OGG}"
APEX_SCHEMA="${APEX_SCHEMA:-GGADMIN}"
HOST_ORDS_PORT="${HOST_ORDS_PORT:-36080}"
CONTAINER_APP_DIR="/home/oracle/labs/lab18/apps"
CONTAINER_APP340_DIR="/home/oracle/labs/lab18/app340"
LOG_DIR="${LOG_DIR:-$(cd "${LAB18_DIR}/../.." && pwd)/logs/lab18}"
LOG_FILE="${LOG_FILE:-${LOG_DIR}/$(date '+%Y%m%d-%H%M%S')-lab18-init.log}"
THEME_SOURCE_APP_ID="${THEME_SOURCE_APP_ID:-102}"
THEME_SOURCE_EXPORT="${APP_DIR}/f${THEME_SOURCE_APP_ID}.sql"
APP_IDS=(300 310 320 330 340 350 360 370 380 390 400)
TARGET_RAW_TABLES=(ADDRESS CUST_PR CANCELAMT CALL_CENTER_LOG CUST_INFO)
TARGET_SQL_FILES=(
  build_insurance_info_app_340_id7.sql
  build_ins2_churn_vector_page_70_id7.sql
  repair_page70_ir_columns_id7.sql
  enhance_churn_fp_coach_page_70_id7.sql
)

STARTED_AT="$(date +%s)"
mkdir -p "${LOG_DIR}"
ln -sfn "$(basename "${LOG_FILE}")" "${LOG_DIR}/latest.log"
exec > >(tee -a "${LOG_FILE}") 2>&1

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

elapsed() {
  local seconds=$(( $(date +%s) - STARTED_AT ))
  printf '%02d:%02d:%02d' $((seconds / 3600)) $(((seconds % 3600) / 60)) $((seconds % 60))
}

fail() {
  log "ERROR: $*"
  log "ERROR: review log: ${LOG_FILE}"
  exit 1
}

on_error() {
  local rc="$1"
  trap - ERR
  log "ERROR: lab18_init.sh failed with exit code ${rc}."
  log "ERROR: elapsed time: $(elapsed)"
  log "ERROR: review log: ${LOG_FILE}"
  exit "${rc}"
}
trap 'on_error $?' ERR

on_signal() {
  local signal_name="$1"
  local rc="$2"

  trap - ERR HUP INT TERM
  log "ERROR: lab18_init.sh was interrupted by ${signal_name}."
  log "ERROR: elapsed time: $(elapsed)"
  log "ERROR: review log: ${LOG_FILE}"
  exit "${rc}"
}
trap 'on_signal SIGHUP 129' HUP
trap 'on_signal SIGINT 130' INT
trap 'on_signal SIGTERM 143' TERM

sql_sys() {
  docker exec -i -u oracle "${TARGET_DB_CONTAINER}" bash -lc "sqlplus -s / as sysdba" <<SQL
whenever sqlerror exit failure rollback
set pages 0 feedback off heading off verify off echo off trimspool on
alter session set container=${TARGET_PDB};
$1
exit
SQL
}

application_count() {
  local app_id="$1"

  sql_sys "select 'APP_COUNT=' || count(*) from apex_applications where workspace = upper('${APEX_WORKSPACE_NAME}') and application_id = ${app_id};" |
    sed -n 's/^[[:space:]]*APP_COUNT=//p' | tail -1
}

require_target_raw_objects() {
  local expected_count="${#TARGET_RAW_TABLES[@]}"
  local table_list="'ADDRESS','CUST_PR','CANCELAMT','CALL_CENTER_LOG','CUST_INFO'"
  local table_count event_count soe_count

  soe_count="$(sql_sys "select 'SOE_COUNT=' || count(*) from dba_users where username = 'SOE' and account_status like 'OPEN%';" |
    sed -n 's/^[[:space:]]*SOE_COUNT=//p' | tail -1)"
  [ "${soe_count:-0}" -eq 1 ] ||
    fail "Target business schema SOE is missing or locked in ${TARGET_DB_CONTAINER}/${TARGET_PDB}. Recreate the Target lab database before Lab 18."

  table_count="$(sql_sys "select 'RAW_TABLE_COUNT=' || count(*) from dba_tables where owner = 'SOE' and table_name in (${table_list});" |
    sed -n 's/^[[:space:]]*RAW_TABLE_COUNT=//p' | tail -1)"
  if [ "${table_count:-0}" -ne "${expected_count}" ]; then
    log "ERROR: Target SOE replication prerequisites are incomplete: found ${table_count:-0}/${expected_count} tables."
    log "ERROR: Lab 18 expects Source SOE DDL/DML to reach Target SOE through GoldenGate D01 first."
    log "RECOVERY: cd /home/oracle/labs"
    log "RECOVERY: RESET_ORACLE_TARGET=Y sh reset_lab_all.sh --create-objects"
    fail "After the reset completes, rerun: cd /home/oracle/labs/lab18 && sh lab18_init.sh"
  fi

  event_count="$(sql_sys "select 'EVENT_COUNT=' || count(*) from soe.call_center_log;" |
    sed -n 's/^[[:space:]]*EVENT_COUNT=//p' | tail -1)"
  if [ "${event_count:-0}" -lt 1 ]; then
    log "ERROR: Target SOE.CALL_CENTER_LOG exists but contains no replicated business events."
    log "RECOVERY: cd /home/oracle/labs"
    log "RECOVERY: RESET_ORACLE_TARGET=Y sh reset_lab_all.sh --create-objects"
    fail "Wait for GoldenGate D01 to finish, then rerun Lab 18 initialization."
  fi

  log "OK: Target SOE has all ${expected_count} replicated raw tables and ${event_count} call-center events."
}

require_prerequisites() {
  local apex_state workspace_count theme_source_count app_id export_file

  command -v docker >/dev/null 2>&1 || fail "docker command not found."
  command -v curl >/dev/null 2>&1 || fail "curl command not found."
  command -v sha256sum >/dev/null 2>&1 || fail "sha256sum command not found."

  docker ps --format '{{.Names}}' | grep -qx "${TARGET_DB_CONTAINER}" ||
    fail "Target DB container is not running: ${TARGET_DB_CONTAINER}. Run startDocker.sh first."

  require_target_raw_objects

  apex_state="$(sql_sys "select 'APEX_STATE=' || version || '|' || status from dba_registry where comp_id = 'APEX';" |
    sed -n 's/^[[:space:]]*APEX_STATE=//p' | tail -1)"
  case "${apex_state}" in
    *'|VALID') log "OK: APEX ${apex_state}" ;;
    '') fail "APEX is not installed in ${TARGET_PDB}. Run lab12_init.sh first." ;;
    *) fail "APEX registry state is not VALID: ${apex_state}" ;;
  esac

  workspace_count="$(sql_sys "select 'WORKSPACE_COUNT=' || count(*) from apex_workspaces where upper(workspace) = upper('${APEX_WORKSPACE_NAME}');" |
    sed -n 's/^[[:space:]]*WORKSPACE_COUNT=//p' | tail -1)"
  [ "${workspace_count:-0}" -eq 1 ] ||
    fail "APEX workspace ${APEX_WORKSPACE_NAME} is not ready. Run lab12_init.sh first."
  log "OK: APEX workspace ${APEX_WORKSPACE_NAME}"

  theme_source_count="$(application_count "${THEME_SOURCE_APP_ID}")"
  if [ "${theme_source_count:-0}" -eq 1 ]; then
    log "OK: Theme source App ${THEME_SOURCE_APP_ID}"
  else
    log "INFO: Theme source App ${THEME_SOURCE_APP_ID} is not installed; Lab 18 will import it first."
  fi

  curl -fsS --max-time 10 -o /dev/null "http://127.0.0.1:${HOST_ORDS_PORT}/ords/" ||
    fail "ORDS is not responding on host port ${HOST_ORDS_PORT}."
  log "OK: ORDS is responding on host port ${HOST_ORDS_PORT}."

  [ -s "${APP_DIR}/repair_subscribed_theme.sql" ] ||
    fail "Theme repair SQL not found: ${APP_DIR}/repair_subscribed_theme.sql"
  [ -s "${THEME_SOURCE_EXPORT}" ] ||
    fail "Theme source App export not found: ${THEME_SOURCE_EXPORT}"

  for app_id in "${APP_IDS[@]}"; do
    export_file="${APP_DIR}/f${app_id}.sql"
    [ -s "${export_file}" ] || fail "APEX export not found: ${export_file}"
  done

  for export_file in "${TARGET_SQL_FILES[@]}"; do
    [ -s "${APP340_DIR}/${export_file}" ] || fail "Target SOE setup SQL not found: ${APP340_DIR}/${export_file}"
  done
}

stage_file() {
  local host_file="$1"
  local container_file="$2"
  local label="$3"
  local host_sha container_sha

  host_sha="$(sha256sum "${host_file}" | awk '{print $1}')"
  container_sha="$(docker exec "${TARGET_DB_CONTAINER}" sha256sum "${container_file}" 2>/dev/null |
    awk '{print $1}' || true)"

  if [ "${host_sha}" = "${container_sha}" ]; then
    log "SKIP: ${label} is already staged."
    return
  fi

  docker exec -u root "${TARGET_DB_CONTAINER}" mkdir -p "${container_file%/*}"
  docker cp "${host_file}" "${TARGET_DB_CONTAINER}:${container_file}"
  docker exec -u root "${TARGET_DB_CONTAINER}" chown oracle:oinstall "${container_file}"
  docker exec -u root "${TARGET_DB_CONTAINER}" chmod 644 "${container_file}"
  log "OK: staged ${label}."
}

run_target_sql() {
  local sql_file="$1"
  local label="$2"
  local host_file="${APP340_DIR}/${sql_file}"
  local container_file="${CONTAINER_APP340_DIR}/${sql_file}"

  stage_file "${host_file}" "${container_file}" "${label}"
  log "==> ${label}"
  docker exec -i -u oracle "${TARGET_DB_CONTAINER}" bash -lc "sqlplus -s / as sysdba @${container_file}"
  log "OK: ${label}"
}

import_app() {
  local app_id="$1"
  local host_file="${APP_DIR}/f${app_id}.sql"
  local container_file="${CONTAINER_APP_DIR}/f${app_id}.sql"
  local app_offset app_count app340_layout_state

  app_count="$(application_count "${app_id}")"
  if [ "${app_count:-0}" -eq 1 ]; then
    if [ "${app_id}" -ne 340 ]; then
      log "SKIP: App ${app_id} is already installed."
      return
    fi

    app340_layout_state="$(sql_sys "
select 'APP340_LAYOUT_STATE=' ||
       case
         when (select count(*)
                 from apex_260100.wwv_flow_page_plugs
                where flow_id = 340
                  and page_id = 70
                  and static_id = 'breadcrumb'
                  and plug_source_type = 'NATIVE_BREADCRUMB'
                  and menu_id is not null) = 1
          and (select count(*)
                 from apex_260100.wwv_flow_page_plugs
                where flow_id = 340
                  and page_id = 70
                  and static_id = 'churn-risk-band-chart'
                  and plug_name = '위험등급 분포 / FP AI 대응 코멘트'
                  and instr(plug_source, 'soe.ins2_churn_risk_band_html') > 0
                  and instr(plug_source, 'soe.ins2_churn_fp_coach_html') > 0) = 1
          and (select count(*)
                 from apex_260100.wwv_flow_page_plugs
                where flow_id = 340
                  and page_id = 70
                  and static_id = 'churn-log-vector-match'
                  and instr(plug_source, 'soe.ins2_churn_log_score_v') > 0) = 1
         then 'CURRENT'
         else 'OUTDATED'
       end
  from dual;" | sed -n 's/^[[:space:]]*APP340_LAYOUT_STATE=//p' | tail -1)"

    if [ "${app340_layout_state}" = "CURRENT" ]; then
      log "SKIP: App 340 is already installed with the complete Page 70 layout."
      return
    fi

    log "INFO: App 340 is installed with an outdated Page 70 layout; reimporting the complete export."
  fi

  app_offset="$(sed -n 's/.*,p_default_id_offset=>\([0-9][0-9]*\).*/\1/p' "${host_file}" | head -1)"
  [[ "${app_offset}" =~ ^[0-9]+$ ]] || fail "App ${app_id} export has no valid p_default_id_offset."

  log "==> Import App ${app_id}"
  docker exec -i -u oracle "${TARGET_DB_CONTAINER}" bash -lc "sqlplus -s / as sysdba" <<SQL
whenever sqlerror exit failure rollback
set define off serveroutput on
alter session set container=${TARGET_PDB};
begin
  apex_application_install.set_workspace('${APEX_WORKSPACE_NAME}');
  apex_application_install.set_schema('${APEX_SCHEMA}');
  apex_application_install.set_application_id(${app_id});
  apex_application_install.set_offset(${app_offset});
  apex_application_install.set_auto_install_sup_obj(true);
end;
/
@${container_file}
exit
SQL

  app_count="$(application_count "${app_id}")"
  [ "${app_count:-0}" -eq 1 ] || fail "App ${app_id} was not found after import."
  log "OK: imported App ${app_id}."
}

repair_app_theme() {
  local app_id="$1"

  log "==> Repair App ${app_id} Theme 42 navigation and page templates"
  docker exec -i -u oracle "${TARGET_DB_CONTAINER}" bash -lc "sqlplus -s / as sysdba" <<SQL
whenever sqlerror exit failure rollback
set define off serveroutput on
alter session set container=${TARGET_PDB};
begin
  apex_260100.wwv_flow.g_flow_id := ${app_id};
end;
/
@${CONTAINER_APP_DIR}/repair_subscribed_theme.sql
commit;
exit
SQL
  log "OK: repaired App ${app_id} Theme 42 navigation and page templates."
}

verify_apps() {
  local expected_csv installed_count app101_count theme_issue_count
  expected_csv="$(IFS=,; printf '%s' "${APP_IDS[*]}")"

  installed_count="$(sql_sys "select 'INSTALLED_COUNT=' || count(*) from apex_applications where workspace = upper('${APEX_WORKSPACE_NAME}') and application_id in (${expected_csv});" |
    sed -n 's/^[[:space:]]*INSTALLED_COUNT=//p' | tail -1)"
  [ "${installed_count:-0}" -eq "${#APP_IDS[@]}" ] ||
    fail "Expected ${#APP_IDS[@]} Lab 18 apps, found ${installed_count:-0}."

  theme_issue_count="$(sql_sys "
select 'THEME_ISSUE_COUNT=' || count(*)
  from apex_260100.wwv_flows f
  join apex_260100.wwv_flow_themes t
    on t.flow_id = f.id
   and t.theme_id = 42
 where f.id in (${expected_csv})
   and ((upper(f.navigation_list_position) = 'SIDE'
         and nvl(f.navigation_list_template_id, -1) <> nvl(t.default_side_nav_list_template, -2))
     or (upper(f.navigation_list_position) = 'TOP'
         and nvl(f.navigation_list_template_id, -1) <> nvl(t.default_top_nav_list_template, -2)));" |
    sed -n 's/^[[:space:]]*THEME_ISSUE_COUNT=//p' | tail -1)"
  [ "${theme_issue_count:-0}" -eq 0 ] ||
    fail "Found ${theme_issue_count:-0} Lab 18 apps with an inconsistent navigation template."

  sql_sys "
set pages 100
set heading on
set feedback on
column application_name format a48
column alias format a28
select application_id, application_name, alias
  from apex_applications
 where workspace = upper('${APEX_WORKSPACE_NAME}')
   and application_id in (${expected_csv})
 order by application_id;
"

  app101_count="$(application_count 101)"
  if [ "${app101_count:-0}" -eq 1 ]; then
    log "OK: manually managed GoldenGate Console App 101 is present."
  else
    log "INFO: App 101 is intentionally not imported by lab18_init.sh; follow the manual Console import section when required."
  fi
  log "OK: verified ${installed_count} Lab 18 business applications."
}

verify_target_objects() {
  local object_count page_count grant_count source_owner_count page_template_issue_count page_region_template_issue_count
  local ir_column_issue_count care_row_count score_row_count vector_ready_count vector_fallback_count

  object_count="$(sql_sys "
select 'TARGET_OBJECT_COUNT=' || count(*)
  from dba_objects
 where owner = 'SOE'
   and status = 'VALID'
   and (object_name, object_type) in (
     ('INS2_CHURN_FP_CARE', 'TABLE'),
     ('INS2_CHURN_ACTION_QUEUE_V', 'VIEW'),
     ('INS2_CHURN_VECTOR_PKG', 'PACKAGE')
   );" | sed -n 's/^[[:space:]]*TARGET_OBJECT_COUNT=//p' | tail -1)"
  [ "${object_count:-0}" -eq 3 ] || fail "Target SOE analytics objects are missing or invalid: ${object_count:-0}/3."

  page_count="$(sql_sys "select 'PAGE_COUNT=' || count(*) from apex_application_pages where application_id = 340 and page_id = 70;" |
    sed -n 's/^[[:space:]]*PAGE_COUNT=//p' | tail -1)"
  [ "${page_count:-0}" -eq 1 ] || fail "App 340 Page 70 was not installed."

  page_template_issue_count="$(sql_sys "
select 'PAGE_TEMPLATE_ISSUE_COUNT=' || count(*)
  from apex_260100.wwv_flow_steps s
  join apex_260100.wwv_flow_themes t
    on t.flow_id = s.flow_id
   and t.theme_id = 42
 where s.flow_id = 340
   and ((s.id = 70 and nvl(s.step_template, -1) <> nvl(t.default_page_template, -2))
     or (s.id = 9999 and nvl(s.step_template, -1) <> nvl(t.login_template, -2)));" |
    sed -n 's/^[[:space:]]*PAGE_TEMPLATE_ISSUE_COUNT=//p' | tail -1)"
  [ "${page_template_issue_count:-0}" -eq 0 ] ||
    fail "App 340 Page 70 or Login page has an inconsistent page template."

  page_region_template_issue_count="$(sql_sys "
select 'PAGE_REGION_TEMPLATE_ISSUE_COUNT=' || count(*)
  from apex_260100.wwv_flow_page_plugs p
  left join apex_260100.wwv_flow_page_plug_templates t
    on t.id = p.plug_template
 where p.flow_id = 340
   and p.page_id = 70
   and p.plug_template is not null
   and t.id is null;" |
    sed -n 's/^[[:space:]]*PAGE_REGION_TEMPLATE_ISSUE_COUNT=//p' | tail -1)"
  [ "${page_region_template_issue_count:-0}" -eq 0 ] ||
    fail "App 340 Page 70 has ${page_region_template_issue_count:-0} invalid region templates."

  ir_column_issue_count="$(sql_sys "
select 'IR_COLUMN_ISSUE_COUNT=' || count(*)
  from (
    select e.region_name,
           e.expected_count,
           count(c.id) actual_count
      from (
        select 'FP 케어 우선순위' region_name, 21 expected_count from dual
        union all
        select '최근 상담 로그 벡터 매칭', 11 from dual
      ) e
      left join apex_260100.wwv_flow_page_plugs p
        on p.flow_id = 340
       and p.page_id = 70
       and p.plug_name = e.region_name
      left join apex_260100.wwv_flow_worksheets w
        on w.flow_id = 340
       and w.page_id = 70
       and w.region_id = p.id
      left join apex_260100.wwv_flow_worksheet_columns c
        on c.flow_id = 340
       and c.page_id = 70
       and c.worksheet_id = w.id
     group by e.region_name, e.expected_count
    having count(c.id) <> e.expected_count
  );" | sed -n 's/^[[:space:]]*IR_COLUMN_ISSUE_COUNT=//p' | tail -1)"
  [ "${ir_column_issue_count:-0}" -eq 0 ] ||
    fail "App 340 Page 70 has missing Interactive Report columns in ${ir_column_issue_count:-0} region(s)."

  ir_report_issue_count="$(sql_sys "
select 'IR_REPORT_ISSUE_COUNT=' || count(*)
  from (
    select e.static_id, r.id, r.report_columns, e.expected_columns
      from (
        select 'churn-care-queue' static_id,
               '업무유형:접촉우선순위:고객ID:고객명:담당FP:위험등급:해약가능점수:주요사유:케어기한:조치상태' expected_columns from dual
        union all
        select 'churn-log-vector-match',
               '로그ID:고객ID:상담시각:위험등급:해약가능점수:벡터매칭사유:벡터유사점수:벡터상태' from dual
      ) e
      left join apex_260100.wwv_flow_page_plugs p
        on p.flow_id = 340 and p.page_id = 70 and p.static_id = e.static_id
      left join apex_260100.wwv_flow_worksheets w on w.region_id = p.id
      left join apex_260100.wwv_flow_worksheet_rpts r on r.worksheet_id = w.id
  )
 where id is null
    or instr(report_columns, chr(34)) > 0
    or report_columns <> expected_columns;" | sed -n 's/^[[:space:]]*IR_REPORT_ISSUE_COUNT=//p' | tail -1)"
  [ "${ir_report_issue_count:-0}" -eq 0 ] ||
    fail "App 340 Page 70 has ${ir_report_issue_count:-0} Interactive Report saved layouts with invalid column metadata."

  page_layout_issue_count="$(sql_sys "
select 'PAGE_LAYOUT_ISSUE_COUNT=' ||
       ((select abs(1 - count(*)) from apex_260100.wwv_flow_page_plugs
          where flow_id = 340 and page_id = 70 and static_id = 'breadcrumb') +
        (select count(*) from apex_260100.wwv_flow_page_plugs
          where flow_id = 340 and page_id = 70 and static_id = 'breadcrumb'
            and (plug_source_type <> 'NATIVE_BREADCRUMB' or menu_id is null)) +
        (select abs(1 - count(*)) from apex_260100.wwv_flow_page_plugs
          where flow_id = 340 and page_id = 70 and static_id = 'churn-risk-band-chart') +
        (select count(*) from apex_260100.wwv_flow_page_plugs
          where flow_id = 340 and page_id = 70 and static_id = 'churn-risk-band-chart'
            and (plug_name <> '위험등급 분포 / FP AI 대응 코멘트'
              or instr(plug_source, 'soe.ins2_churn_risk_band_html') = 0
              or instr(plug_source, 'soe.ins2_churn_fp_coach_html') = 0)))
  from dual;" | sed -n 's/^[[:space:]]*PAGE_LAYOUT_ISSUE_COUNT=//p' | tail -1)"
  [ "${page_layout_issue_count:-0}" -eq 0 ] ||
    fail "App 340 Page 70 layout does not match the AI coaching screen."

  care_row_count="$(sql_sys "select 'CARE_ROW_COUNT=' || count(*) from soe.ins2_churn_action_queue_v;" |
    sed -n 's/^[[:space:]]*CARE_ROW_COUNT=//p' | tail -1)"
  [ "${care_row_count:-0}" -gt 0 ] || fail "SOE.INS2_CHURN_ACTION_QUEUE_V contains no care candidates."

  score_row_count="$(sql_sys "select 'SCORE_ROW_COUNT=' || count(*) from soe.ins2_churn_log_score_v;" |
    sed -n 's/^[[:space:]]*SCORE_ROW_COUNT=//p' | tail -1)"
  [ "${score_row_count:-0}" -gt 0 ] || fail "SOE.INS2_CHURN_LOG_SCORE_V contains no call-center scores."

  vector_ready_count="$(sql_sys "select 'VECTOR_READY_COUNT=' || count(*) from soe.ins2_churn_call_vector where vector_status = 'READY';" |
    sed -n 's/^[[:space:]]*VECTOR_READY_COUNT=//p' | tail -1)"
  vector_fallback_count="$(sql_sys "select 'VECTOR_FALLBACK_COUNT=' || count(*) from soe.ins2_churn_call_vector where vector_status = 'FALLBACK';" |
    sed -n 's/^[[:space:]]*VECTOR_FALLBACK_COUNT=//p' | tail -1)"
  [ "${vector_ready_count:-0}" -gt 0 ] || fail "SOE.INS2_CHURN_CALL_VECTOR contains no READY vectors."
  [ "${vector_fallback_count:-0}" -eq 0 ] ||
    fail "SOE.INS2_CHURN_CALL_VECTOR contains ${vector_fallback_count:-0} FALLBACK vectors."
  log "INFO: App 340 report rows: care=${care_row_count}, call scores=${score_row_count}; vector READY=${vector_ready_count:-0}, FALLBACK=${vector_fallback_count:-0}."

  grant_count="$(sql_sys "
select 'GRANT_COUNT=' || count(*)
  from dba_tab_privs
 where owner = 'SOE'
   and grantee = 'GGADMIN'
   and table_name in ('INS2_CHURN_FP_CARE','INS2_CHURN_ACTION_QUEUE_V','INS2_CHURN_VECTOR_PKG');" |
    sed -n 's/^[[:space:]]*GRANT_COUNT=//p' | tail -1)"
  [ "${grant_count:-0}" -eq 3 ] || fail "GGADMIN has incomplete APEX privileges on Target SOE analytics objects: ${grant_count:-0}/3."

  source_owner_count="$(sql_sys "select 'WRONG_OWNER_COUNT=' || count(*) from dba_objects where owner = 'GGADMIN' and object_name like 'INS2_CHURN%';" |
    sed -n 's/^[[:space:]]*WRONG_OWNER_COUNT=//p' | tail -1)"
  if [ "${source_owner_count:-0}" -gt 0 ]; then
    log "WARN: found ${source_owner_count} legacy GGADMIN.INS2_CHURN objects; new Lab 18 objects use SOE and do not depend on them."
  fi

  log "OK: Target SOE owns the Lab 18 analytics objects; GGADMIN has only APEX access grants."
}

main() {
  local app_id

  log "==> START: lab18-init"
  log "INFO: Target App Builder -> http://localhost:${HOST_ORDS_PORT}/ords/"
  log "INFO: App 101 remains a separate manual import; this script manages Apps ${APP_IDS[*]}."
  log "INFO: App ${THEME_SOURCE_APP_ID} is installed only when needed as the subscribed-theme source."

  require_prerequisites
  stage_file "${THEME_SOURCE_EXPORT}" "${CONTAINER_APP_DIR}/f${THEME_SOURCE_APP_ID}.sql" "Theme source App ${THEME_SOURCE_APP_ID} export"
  import_app "${THEME_SOURCE_APP_ID}"
  stage_file "${APP_DIR}/repair_subscribed_theme.sql" "${CONTAINER_APP_DIR}/repair_subscribed_theme.sql" "Theme 42 repair SQL"

  for app_id in "${APP_IDS[@]}"; do
    stage_file "${APP_DIR}/f${app_id}.sql" "${CONTAINER_APP_DIR}/f${app_id}.sql" "App ${app_id} export"
    import_app "${app_id}"
    repair_app_theme "${app_id}"
  done


  sql_sys "alter user soe identified by soe account unlock;"
  log "OK: Target SOE lab account is unlocked for the reader SQL examples."

  run_target_sql "build_insurance_info_app_340_id7.sql" "Target SOE App 340 business objects"
  run_target_sql "build_ins2_churn_vector_page_70_id7.sql" "Target SOE churn vector objects and App 340 Page 70"
  repair_app_theme 340
  run_target_sql "repair_page70_ir_columns_id7.sql" "App 340 Page 70 Interactive Report columns"
  run_target_sql "enhance_churn_fp_coach_page_70_id7.sql" "Target SOE FP care coaching objects"

  verify_apps
  verify_target_objects
  trap - ERR HUP INT TERM
  log "OK: Lab 18 APEX business applications are ready."
  log "OK: elapsed time: $(elapsed)"
  log "OK: log file: ${LOG_FILE}"
}

main "$@"
