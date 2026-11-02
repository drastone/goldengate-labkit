#!/usr/bin/env bash
set -u

# Demo Lab 전용 보정 스크립트다. 실제 운영 APEX 환경에서는 계정 만료,
# 비밀번호 변경 주기, 잠금 정책을 회사 보안 정책에 맞게 유지해야 한다.

PDB_NAME="${PDB_NAME:-ORCLPDB1}"
WORKSPACE_NAME="${WORKSPACE_NAME:-OGG}"
APEX_DEMO_USERS="${APEX_DEMO_USERS:-ADMIN,CALLCENTER01,NEWBIZ01,CLAIMS01,SIU01,MESHADMIN,DWADMIN,ICEBERG01,FLOW01,HOLDING01,SCM01,SEMI01,AUTO01,INSURANCE01,CORE01}"
ORACLE_SID="${ORACLE_SID:-ORCLCDB}"

if [ -z "${ORACLE_HOME:-}" ]; then
  ORACLE_HOME="$(find /opt/oracle/product -maxdepth 5 -type f -path '*/bin/sqlplus' 2>/dev/null \
    | sed 's#/bin/sqlplus$##' | sort | tail -1)"
fi

export ORACLE_HOME
export ORACLE_SID
export PATH="${ORACLE_HOME}/bin:${PATH}"

if [ -z "${ORACLE_HOME}" ] || [ ! -x "${ORACLE_HOME}/bin/sqlplus" ]; then
  echo "WARN: sqlplus not found, skip APEX demo account refresh"
  exit 0
fi

echo "Refreshing APEX demo accounts for workspace ${WORKSPACE_NAME} in ${PDB_NAME}"

"${ORACLE_HOME}/bin/sqlplus" -s '/ as sysdba' <<SQL
whenever sqlerror exit sql.sqlcode rollback
set serveroutput on
set pages 200 lines 220
set define on
set verify off

define pdb_name = "${PDB_NAME}"
define workspace_name = "${WORKSPACE_NAME}"
define demo_users = "${APEX_DEMO_USERS}"

alter session set container = &&pdb_name;

declare
  l_workspace_id number;
  l_demo_expiry  constant date := date '2099-12-31';
  l_apex_schema  varchar2(128);
  l_user_id      number;
begin
  select schema
    into l_apex_schema
    from dba_registry
   where comp_id = 'APEX';

  l_workspace_id := apex_util.find_security_group_id(
    p_workspace => upper('&&workspace_name')
  );

  apex_util.set_security_group_id(l_workspace_id);

  for r in (
    select upper(trim(regexp_substr('&&demo_users', '[^,]+', 1, level))) user_name
      from dual
   connect by regexp_substr('&&demo_users', '[^,]+', 1, level) is not null
  ) loop
    l_user_id := apex_util.get_user_id(p_username => r.user_name);

    if l_user_id is null then
      dbms_output.put_line('skip missing user ' || r.user_name);
    else
      apex_util.edit_user(
        p_user_id                      => l_user_id,
        p_user_name                    => r.user_name,
        p_account_expiry               => l_demo_expiry,
        p_account_locked               => 'N',
        p_failed_access_attempts       => 0,
        p_change_password_on_first_use => 'N',
        p_first_password_use_occurred  => 'Y'
      );

      apex_util.unexpire_workspace_account(p_user_name => r.user_name);
      apex_util.unexpire_end_user_account(p_user_name => r.user_name);
      apex_util.unlock_account(p_user_name => r.user_name);

      execute immediate
        'update ' || dbms_assert.schema_name(l_apex_schema) || '.wwv_flow_fnd_user
            set account_expiry = :1,
                end_date = :2,
                account_locked = ''N'',
                failed_access_attempts = 0,
                change_password_on_first_use = ''N'',
                first_password_use_occurred = ''Y'',
                password_lifespan_days = null,
                password_lifespan_accesses = null,
                password_accesses_left = null,
                password_date = sysdate,
                last_update_date = sysdate,
                last_updated_by = ''LAB_KIT''
          where security_group_id = :3
            and user_id = :4'
        using l_demo_expiry, l_demo_expiry, l_workspace_id, l_user_id;

      dbms_output.put_line('refreshed ' || r.user_name);
    end if;
  end loop;

  commit;
end;
/

select user_name,
       account_locked,
       nvl(to_char(account_expiry, 'YYYY-MM-DD'), 'NEVER') account_expiry,
       failed_access_attempts
  from apex_workspace_apex_users
 where workspace_name = upper('&&workspace_name')
   and user_name in (
       select upper(trim(regexp_substr('&&demo_users', '[^,]+', 1, level)))
         from dual
      connect by regexp_substr('&&demo_users', '[^,]+', 1, level) is not null
   )
 order by user_name;

exit
SQL
