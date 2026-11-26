#!/usr/bin/env bash

set -euo pipefail

MISSING_TABLES="$({
  sqlplus -L -s soe/soe@orclpdb1 <<'SQL'
whenever sqlerror exit failure rollback
set heading off feedback off pages 0 lines 32767 verify off echo off trimspool on

with required_tables (table_name) as (
  select 'CALL_CENTER_LOG' from dual union all
  select 'CFUND_DEPOSIT' from dual union all
  select 'CFUND_DT' from dual union all
  select 'CFUND_RAT' from dual union all
  select 'CFUND_RATIO' from dual union all
  select 'CUST_DEP_DT' from dual union all
  select 'CUST_GEN_AMT' from dual union all
  select 'CUST_PR' from dual union all
  select 'FUNDM' from dual union all
  select 'FUND_PRICE' from dual union all
  select 'OPM' from dual union all
  select 'PRODUCT' from dual union all
  select 'RESERVES_AMT' from dual
)
select listagg(r.table_name, ', ') within group (order by r.table_name)
from required_tables r
where not exists (
  select 1
  from user_tables t
  where t.table_name = r.table_name
);

exit success
SQL
} | tr -d '\r' | sed '/^[[:space:]]*$/d')"

if [ -n "${MISSING_TABLES}" ]; then
  echo "ERROR: required Source SOE tables are missing: ${MISSING_TABLES}" >&2
  echo "ERROR: run the following command before the data generator:" >&2
  echo "ERROR:   sh /home/oracle/script/osa/23ai/create_source_business_objects.sh" >&2
  exit 1
fi

echo "OK: required Source SOE business objects are ready."
