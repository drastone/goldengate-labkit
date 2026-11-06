#!/usr/bin/env bash

set -Eeuo pipefail

LAB12_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${LAB12_DIR}/lab12_common.sh"

lab12_begin_stage "lab12-configure-workspace"

APEX_EXPECTED_VERSION="${APEX_EXPECTED_VERSION:-26.1.0}"
APEX_WORKSPACE_NAME="${APEX_WORKSPACE_NAME:-OGG}"
APEX_WORKSPACE_ADMIN="${APEX_WORKSPACE_ADMIN:-GGADMIN}"
APEX_WORKSPACE_ADMIN_EMAIL="${APEX_WORKSPACE_ADMIN_EMAIL:-ggadmin@example.invalid}"
APEX_DEVELOPER_ROLES="ADMIN:CREATE:DATA_LOADER:EDIT:HELP:MONITOR:SQL"

lab12_require_command docker
lab12_require_running_container

apex_state="$(lab12_apex_registry_state)"
if [ "${apex_state}" != "${APEX_EXPECTED_VERSION}|VALID" ]; then
  lab12_log "ERROR: workspace setup requires APEX ${APEX_EXPECTED_VERSION}|VALID, found: ${apex_state:-not installed}"
  exit 1
fi

lab12_log "==> Configure APEX workspace ${APEX_WORKSPACE_NAME} and administrator ${APEX_WORKSPACE_ADMIN}"
lab12_log "INFO: existing database and APEX accounts are preserved and reconciled in place."

docker exec -u oracle "${TARGET_DB_CONTAINER}" bash -lc "sqlplus -s / as sysdba <<'SQL'
whenever sqlerror exit failure rollback
set serveroutput on feedback off verify off echo off
alter session set container=${TARGET_PDB};

declare
  l_count                         number;
  l_user_id                       number;
  l_workspace                     varchar2(255);
  l_user_name                     varchar2(255);
  l_first_name                    varchar2(255);
  l_last_name                     varchar2(255);
  l_web_password                  varchar2(4000);
  l_email_address                 varchar2(255);
  l_start_date                    varchar2(255);
  l_end_date                      varchar2(255);
  l_employee_id                   varchar2(255);
  l_allow_access_to_schemas       varchar2(4000);
  l_person_type                   varchar2(255);
  l_default_schema                varchar2(255);
  l_groups                        varchar2(4000);
  l_developer_role                varchar2(4000);
  l_description                   varchar2(4000);
  l_account_expiry                date;
  l_account_locked                varchar2(1);
  l_failed_access_attempts        number;
  l_change_password_on_first_use  varchar2(1);
  l_first_password_use_occurred   varchar2(1);
begin
  select count(*) into l_count
  from dba_users
  where username = '${APEX_WORKSPACE_ADMIN}';

  if l_count = 0 then
    execute immediate 'create user ${APEX_WORKSPACE_ADMIN} identified by "${LAB_PASSWORD}" default tablespace USERS temporary tablespace TEMP quota unlimited on USERS account unlock';
    dbms_output.put_line('CREATED: database schema ${APEX_WORKSPACE_ADMIN}');
  else
    dbms_output.put_line('PRESERVED: existing database schema ${APEX_WORKSPACE_ADMIN}');
  end if;

  execute immediate 'grant create session, create cluster, create dimension, create domain, create indextype, create job, create materialized view, create mle, create operator, create procedure, create property graph, create sequence, create synonym, create table, create trigger, create type, create view, execute dynamic mle to ${APEX_WORKSPACE_ADMIN}';

  select count(*) into l_count
  from apex_workspaces
  where upper(workspace) = '${APEX_WORKSPACE_NAME}';

  if l_count = 0 then
    apex_instance_admin.add_workspace(
      p_workspace      => '${APEX_WORKSPACE_NAME}',
      p_primary_schema => '${APEX_WORKSPACE_ADMIN}');
    dbms_output.put_line('CREATED: APEX workspace ${APEX_WORKSPACE_NAME}');
  else
    dbms_output.put_line('PRESERVED: existing APEX workspace ${APEX_WORKSPACE_NAME}');
  end if;

  apex_util.set_workspace(p_workspace => '${APEX_WORKSPACE_NAME}');
  l_user_id := apex_util.get_user_id(p_username => '${APEX_WORKSPACE_ADMIN}');

  if l_user_id is null then
    apex_util.create_user(
      p_user_name                     => '${APEX_WORKSPACE_ADMIN}',
      p_email_address                 => '${APEX_WORKSPACE_ADMIN_EMAIL}',
      p_web_password                  => '${LAB_PASSWORD}',
      p_developer_privs               => '${APEX_DEVELOPER_ROLES}',
      p_default_schema                => '${APEX_WORKSPACE_ADMIN}',
      p_account_locked                => 'N',
      p_change_password_on_first_use  => 'N',
      p_first_password_use_occurred   => 'Y',
      p_allow_app_building_yn         => 'Y',
      p_allow_sql_workshop_yn         => 'Y',
      p_allow_websheet_dev_yn         => 'Y',
      p_allow_team_development_yn     => 'Y',
      p_allow_data_reporter_yn        => 'Y');
    dbms_output.put_line('CREATED: APEX workspace administrator ${APEX_WORKSPACE_ADMIN}');
  else
    apex_util.fetch_user(
      p_user_id                       => l_user_id,
      p_workspace                     => l_workspace,
      p_user_name                     => l_user_name,
      p_first_name                    => l_first_name,
      p_last_name                     => l_last_name,
      p_web_password                  => l_web_password,
      p_email_address                 => l_email_address,
      p_start_date                    => l_start_date,
      p_end_date                      => l_end_date,
      p_employee_id                   => l_employee_id,
      p_allow_access_to_schemas       => l_allow_access_to_schemas,
      p_person_type                   => l_person_type,
      p_default_schema                => l_default_schema,
      p_groups                        => l_groups,
      p_developer_role                => l_developer_role,
      p_description                   => l_description,
      p_account_expiry                => l_account_expiry,
      p_account_locked                => l_account_locked,
      p_failed_access_attempts        => l_failed_access_attempts,
      p_change_password_on_first_use  => l_change_password_on_first_use,
      p_first_password_use_occurred   => l_first_password_use_occurred);

    apex_util.edit_user(
      p_user_id                       => l_user_id,
      p_user_name                     => l_user_name,
      p_first_name                    => l_first_name,
      p_last_name                     => l_last_name,
      p_web_password                  => l_web_password,
      p_new_password                  => l_web_password,
      p_email_address                 => l_email_address,
      p_start_date                    => l_start_date,
      p_end_date                      => l_end_date,
      p_employee_id                   => l_employee_id,
      p_allow_access_to_schemas       => l_allow_access_to_schemas,
      p_person_type                   => l_person_type,
      p_default_schema                => l_default_schema,
      p_group_ids                     => l_groups,
      p_developer_roles               => '${APEX_DEVELOPER_ROLES}',
      p_description                   => l_description,
      p_account_expiry                => l_account_expiry,
      p_account_locked                => 'N',
      p_failed_access_attempts        => 0,
      p_change_password_on_first_use  => 'N',
      p_first_password_use_occurred   => 'Y');
    dbms_output.put_line('RECONCILED: APEX administrator and developer roles for ${APEX_WORKSPACE_ADMIN}');
  end if;

  commit;
end;
/
exit
SQL"

workspace_user_state="$(lab12_apex_workspace_user_state "${APEX_WORKSPACE_NAME}" "${APEX_WORKSPACE_ADMIN}")"
if [ -z "${workspace_user_state}" ]; then
  lab12_log "ERROR: APEX user ${APEX_WORKSPACE_ADMIN} was not created in workspace ${APEX_WORKSPACE_NAME}."
  exit 1
fi

IFS='|' read -r actual_workspace actual_user is_admin is_developer is_locked <<<"${workspace_user_state}"
if [ "${is_admin}" != "Yes" ] || [ "${is_developer}" != "Yes" ] || [ "${is_locked}" != "No" ]; then
  lab12_log "ERROR: workspace role validation failed for ${actual_workspace}.${actual_user}."
  lab12_log "ERROR: is_admin=${is_admin}, is_application_developer=${is_developer}, account_locked=${is_locked}"
  exit 1
fi

lab12_log "OK: ${actual_workspace}.${actual_user} is an unlocked workspace administrator and developer."
lab12_finish_stage
