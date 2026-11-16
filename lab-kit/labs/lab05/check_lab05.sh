#!/usr/bin/env bash

if [ -z "${BASH_VERSION:-}" ] || shopt -qo posix 2>/dev/null; then
  if command -v bash >/dev/null 2>&1; then
    exec bash "$0" "$@"
  fi
  echo "ERROR: check_lab05.sh requires bash." >&2
  exit 1
fi

set -Eeuo pipefail

SOURCE_CONTAINER="${SOURCE_CONTAINER:-demo_osrc_23ai}"
TARGET_CONTAINER="${TARGET_CONTAINER:-demo_otrg_23ai}"
ORACLE_SID="${ORACLE_SID:-ORCLCDB}"

run_sql() {
  local container="$1"
  local label="$2"

  if [ "$(docker inspect -f '{{.State.Running}}' "${container}" 2>/dev/null || true)" != "true" ]; then
    echo "ERROR: ${label} container is not running: ${container}" >&2
    return 1
  fi

  echo "==> Verify ${label}: ${container}"
  docker exec -i -u oracle "${container}" bash -lc \
    "export ORACLE_SID='${ORACLE_SID}'; sqlplus -s / as sysdba"
}

run_sql "${SOURCE_CONTAINER}" "Source DB" <<'SQL'
set serveroutput on feedback off verify off heading off pages 0
whenever sqlerror exit sql.sqlcode

declare
  l_enabled varchar2(8);
  l_log_mode varchar2(16);
  l_supplemental varchar2(8);
begin
  select value into l_enabled from v$parameter
   where name = 'enable_goldengate_replication';
  select log_mode, supplemental_log_data_min
    into l_log_mode, l_supplemental
    from v$database;
  if lower(l_enabled) <> 'true' then
    raise_application_error(-20001, 'enable_goldengate_replication is not TRUE');
  end if;
  if l_log_mode <> 'ARCHIVELOG' then
    raise_application_error(-20002, 'Source database is not in ARCHIVELOG mode');
  end if;
  if l_supplemental <> 'YES' then
    raise_application_error(-20003, 'Minimum supplemental logging is not enabled');
  end if;
end;
/

alter session set container=ORCLPDB1;

declare
  l_count number;
begin
  select count(*) into l_count from dba_users
   where username in ('SOE', 'OGG') and account_status = 'OPEN';
  if l_count <> 2 then
    raise_application_error(-20004, 'Source SOE/OGG accounts are not both OPEN');
  end if;
  select count(*) into l_count from dba_tablespaces
   where tablespace_name in ('SOE', 'OGG');
  if l_count <> 2 then
    raise_application_error(-20005, 'Source SOE/OGG tablespaces are missing');
  end if;
  select count(*) into l_count from dba_role_privs
   where grantee = 'OGG' and granted_role = 'OGG_CAPTURE';
  if l_count <> 1 then
    raise_application_error(-20006, 'Source OGG_CAPTURE role is missing');
  end if;
end;
/

prompt OK: Source Lab 05 prerequisites are ready.
exit
SQL

run_sql "${TARGET_CONTAINER}" "Target DB" <<'SQL'
set serveroutput on feedback off verify off heading off pages 0
whenever sqlerror exit sql.sqlcode

declare
  l_enabled varchar2(8);
begin
  select value into l_enabled from v$parameter
   where name = 'enable_goldengate_replication';
  if lower(l_enabled) <> 'true' then
    raise_application_error(-20011, 'enable_goldengate_replication is not TRUE');
  end if;
end;
/

alter session set container=ORCLPDB1;

declare
  l_count number;
begin
  select count(*) into l_count from dba_users
   where username in ('SOE', 'OGG') and account_status = 'OPEN';
  if l_count <> 2 then
    raise_application_error(-20012, 'Target SOE/OGG accounts are not both OPEN');
  end if;
  select count(*) into l_count from dba_tablespaces
   where tablespace_name in ('SOE', 'OGG');
  if l_count <> 2 then
    raise_application_error(-20013, 'Target SOE/OGG tablespaces are missing');
  end if;
  select count(*) into l_count from dba_role_privs
   where grantee = 'OGG' and granted_role = 'OGG_APPLY';
  if l_count <> 1 then
    raise_application_error(-20014, 'Target OGG_APPLY role is missing');
  end if;
  select count(distinct privilege) into l_count from dba_sys_privs
   where grantee = 'OGG'
     and privilege in (
       'CREATE ANY TABLE', 'ALTER ANY TABLE', 'DROP ANY TABLE',
       'COMMENT ANY TABLE', 'CREATE ANY INDEX', 'ALTER ANY INDEX',
       'DROP ANY INDEX', 'CREATE ANY SEQUENCE', 'DROP ANY SEQUENCE',
       'SELECT ANY SEQUENCE', 'SELECT ANY TABLE', 'INSERT ANY TABLE',
       'UPDATE ANY TABLE', 'DELETE ANY TABLE'
     );
  if l_count <> 14 then
    raise_application_error(-20015, 'Target OGG apply privileges are incomplete');
  end if;
end;
/

prompt OK: Target Lab 05 prerequisites are ready.
exit
SQL

echo "OK: Lab 05 Source/Target database prerequisites are verified."
