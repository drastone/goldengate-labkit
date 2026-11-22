#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
LOG_DIR="${SCRIPT_DIR}/logs"
LOG_FILE="${LOG_DIR}/init_objects_$(date '+%Y%m%d_%H%M%S').log"

mkdir -p "${LOG_DIR}"

START_TIME=$(date '+%Y-%m-%d %H:%M:%S')
START_SEC=$(date '+%s')

echo "Initializing OSA sample objects..."
echo "Start time: ${START_TIME}"
echo "Log file: ${LOG_FILE}"

sqlplus -s soe/soe@orclpdb1 > "${LOG_FILE}" 2>&1 <<'SQL'
set serveroutput on size unlimited
set feedback off
set heading off
set verify off
set echo off
set termout on
whenever sqlerror exit failure rollback

declare
  procedure drop_table_if_exists(p_name varchar2) is
  begin
    execute immediate 'drop table soe.' || p_name || ' purge';
    dbms_output.put_line('dropped table soe.' || p_name);
  exception
    when others then
      if sqlcode = -942 then
        dbms_output.put_line('skip missing table soe.' || p_name);
      else
        raise;
      end if;
  end;

  procedure drop_trigger_if_exists(p_name varchar2) is
  begin
    execute immediate 'drop trigger soe.' || p_name;
    dbms_output.put_line('dropped trigger soe.' || p_name);
  exception
    when others then
      if sqlcode = -4080 then
        dbms_output.put_line('skip missing trigger soe.' || p_name);
      else
        raise;
      end if;
  end;

  procedure drop_sequence_if_exists(p_name varchar2) is
  begin
    execute immediate 'drop sequence soe.' || p_name;
    dbms_output.put_line('dropped sequence soe.' || p_name);
  exception
    when others then
      if sqlcode = -2289 then
        dbms_output.put_line('skip missing sequence soe.' || p_name);
      else
        raise;
      end if;
  end;
begin
  drop_trigger_if_exists('TRG_AUTO_VECTORIZE_CHURN');
  drop_trigger_if_exists('TRG_AUTO_VECTORIZE_CHURN_GEN');
  drop_trigger_if_exists('TRG_VECTORIZE_KNOWLEDGE');

  -- prepare_osa_source_objects.sh currently creates no sequence, but keep the
  -- helper above so future sample sequences can be added safely.

  drop_table_if_exists('TMP_TRIGGER');
  drop_table_if_exists('OSA_CANCEL_PREDICTION_GEN');
  drop_table_if_exists('OSA_CANCEL_PREDICTION');
  drop_table_if_exists('SUCCESS_CASE_KNOWLEDGE');
  drop_table_if_exists('CALL_CENTER_LOG');
  drop_table_if_exists('TOT_AMT');
  drop_table_if_exists('RESERVES_AMT');
  drop_table_if_exists('CANCELFP');
  drop_table_if_exists('CANCELAMT');
  drop_table_if_exists('CFUND_RAT_TMP');
  drop_table_if_exists('CFUND_RAT');
  drop_table_if_exists('CFUND_RATIO');
  drop_table_if_exists('CFUND_DEPOSIT');
  drop_table_if_exists('CFUND_DT');
  drop_table_if_exists('CUST_DEP_DT');
  drop_table_if_exists('CUST_GEN_AMT');
  drop_table_if_exists('CUST_PR');
  drop_table_if_exists('CUST_INFO');
  drop_table_if_exists('FUND_PRICE');
  drop_table_if_exists('FUNDM');
  drop_table_if_exists('OPSTATUS');
  drop_table_if_exists('OPM');
  drop_table_if_exists('HEARTBP');
  drop_table_if_exists('ADDRESS');
  drop_table_if_exists('PRODUCT');
  drop_table_if_exists('MSG');

  -- EMPLOYEE is intentionally kept. It is used by other lab flows and is not
  -- reset here even though prepare_osa_source_objects.sh can populate it.
end;
/

prompt remaining OSA sample objects:
select object_name || ' ' || object_type
from user_objects
where object_name in (
  'TMP_TRIGGER',
  'OSA_CANCEL_PREDICTION_GEN',
  'OSA_CANCEL_PREDICTION',
  'SUCCESS_CASE_KNOWLEDGE',
  'CALL_CENTER_LOG',
  'TOT_AMT',
  'RESERVES_AMT',
  'CANCELFP',
  'CANCELAMT',
  'CFUND_RAT_TMP',
  'CFUND_RAT',
  'CFUND_RATIO',
  'CFUND_DEPOSIT',
  'CFUND_DT',
  'CUST_DEP_DT',
  'CUST_GEN_AMT',
  'CUST_PR',
  'CUST_INFO',
  'FUND_PRICE',
  'FUNDM',
  'OPSTATUS',
  'OPM',
  'HEARTBP',
  'ADDRESS',
  'PRODUCT',
  'MSG',
  'TRG_AUTO_VECTORIZE_CHURN',
  'TRG_AUTO_VECTORIZE_CHURN_GEN',
  'TRG_VECTORIZE_KNOWLEDGE'
)
order by object_type, object_name;

exit
SQL

END_TIME=$(date '+%Y-%m-%d %H:%M:%S')
END_SEC=$(date '+%s')
ELAPSED=$((END_SEC - START_SEC))

echo "End time: ${END_TIME}"
echo "Elapsed time: ${ELAPSED} seconds"
echo "OSA sample objects initialized."
