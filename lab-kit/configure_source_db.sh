#!/bin/sh
set -eu

SRC_CONTAINER="${SRC_CONTAINER:-demo_osrc_23ai}"
ORACLE_SID="${ORACLE_SID:-ORCLCDB}"
PDB_NAME="${PDB_NAME:-ORCLPDB1}"
OGG_USER="${OGG_USER:-C##OGG}"
OGG_PASSWORD="${OGG_PASSWORD:-ogg}"
SOE_USER="${SOE_USER:-SOE}"
SOE_PASSWORD="${SOE_PASSWORD:-soe}"
STREAMS_POOL_SIZE="${STREAMS_POOL_SIZE:-300m}"

sqlplus_sysdba() {
  docker exec -i -u oracle "${SRC_CONTAINER}" bash -lc \
    "export ORACLE_SID='${ORACLE_SID}'; export ORAENV_ASK=NO; . oraenv >/dev/null 2>&1 || true; sqlplus -s / as sysdba"
}

sql_value() {
  sqlplus_sysdba | awk 'NF { print $1; exit }'
}

if ! docker inspect "${SRC_CONTAINER}" >/dev/null 2>&1; then
  echo "ERROR: container not found: ${SRC_CONTAINER}"
  exit 1
fi

echo "==> Source DB container: ${SRC_CONTAINER}"
echo "==> CDB/PDB: ${ORACLE_SID}/${PDB_NAME}"

log_mode="$(
  sql_value <<SQL
set heading off feedback off pages 0 verify off echo off
select log_mode from v\$database;
SQL
)"

if [ "${log_mode}" != "ARCHIVELOG" ]; then
  echo "==> Enable ARCHIVELOG mode"
  sqlplus_sysdba <<SQL
set echo on
whenever sqlerror exit sql.sqlcode
shutdown immediate;
startup mount;
alter database archivelog;
alter database open;
alter pluggable database all open;
alter pluggable database all save state;
SQL
else
  echo "OK: ARCHIVELOG mode is already enabled."
fi

echo "==> Configure GoldenGate database prerequisites"
sqlplus_sysdba <<SQL
set echo on
set serveroutput on
whenever sqlerror exit sql.sqlcode

alter session set container=CDB\$ROOT;
alter system set enable_goldengate_replication=true scope=both;
alter system set streams_pool_size=${STREAMS_POOL_SIZE} scope=both;
alter database force logging;

declare
  l_min varchar2(8);
begin
  select supplemental_log_data_min into l_min from v\$database;
  if l_min <> 'YES' then
    execute immediate 'alter database add supplemental log data';
  end if;
end;
/

alter pluggable database ${PDB_NAME} open;
alter pluggable database ${PDB_NAME} save state;

declare
  l_count number;
begin
  select count(*) into l_count from dba_tablespaces where tablespace_name = 'OGG';
  if l_count = 0 then
    execute immediate 'create tablespace OGG datafile size 200m autoextend on next 50m maxsize 2g extent management local uniform size 1m segment space management auto';
  end if;
end;
/

alter session set container=${PDB_NAME};

declare
  l_count number;
begin
  select count(*) into l_count from dba_tablespaces where tablespace_name = 'SOE';
  if l_count = 0 then
    execute immediate 'create tablespace SOE datafile size 500m autoextend on next 100m maxsize 4g extent management local uniform size 1m segment space management auto';
  end if;

  select count(*) into l_count from dba_tablespaces where tablespace_name = 'OGG';
  if l_count = 0 then
    execute immediate 'create tablespace OGG datafile size 200m autoextend on next 50m maxsize 2g extent management local uniform size 1m segment space management auto';
  end if;
end;
/

declare
  l_count number;
begin
  select count(*) into l_count from dba_users where username = upper('${SOE_USER}');
  if l_count = 0 then
    execute immediate 'create user ${SOE_USER} identified by "${SOE_PASSWORD}" default tablespace SOE temporary tablespace TEMP account unlock';
  else
    execute immediate 'alter user ${SOE_USER} identified by "${SOE_PASSWORD}" account unlock';
  end if;
end;
/

grant connect, resource, create view, alter session,
      analyze any dictionary, analyze any, create job,
      manage scheduler, manage any queue to ${SOE_USER};
grant execute on sys.dbms_lock to ${SOE_USER};
alter user ${SOE_USER} quota unlimited on SOE;

alter session set container=CDB\$ROOT;

declare
  l_count number;
begin
  select count(*) into l_count from cdb_users where con_id = 1 and username = upper('${OGG_USER}');
  if l_count = 0 then
    execute immediate 'create user ${OGG_USER} identified by "${OGG_PASSWORD}" container=all default tablespace OGG temporary tablespace TEMP account unlock';
  else
    execute immediate 'alter user ${OGG_USER} identified by "${OGG_PASSWORD}" account unlock container=all';
  end if;
end;
/

begin
  dbms_goldengate_auth.grant_admin_privilege('${OGG_USER}', container=>'ALL');
end;
/

grant connect, resource, dba to ${OGG_USER} container=all;
alter user ${OGG_USER} quota unlimited on OGG container=all;
SQL

echo "==> Verify Source DB GoldenGate prerequisites"
sqlplus_sysdba <<SQL
set pages 200 lines 200
col name format a10
col open_mode format a12
col log_mode format a12
col force_logging format a13
col supplemental_log_data_min format a10
col value format a10

select name, open_mode, log_mode, force_logging, supplemental_log_data_min
from v\$database;

show parameter enable_goldengate_replication
show parameter streams_pool_size

select con_id, name, open_mode from v\$pdbs order by con_id;

alter session set container=${PDB_NAME};
select username, account_status, default_tablespace
from dba_users
where username in (upper('${SOE_USER}'), upper('${OGG_USER}'))
order by username;
SQL

echo "OK: Source DB is ready for GoldenGate capture prerequisites."
