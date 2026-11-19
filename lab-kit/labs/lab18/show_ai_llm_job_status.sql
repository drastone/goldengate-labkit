alter session set container=ORCLPDB1;

set serveroutput on size unlimited

begin
  execute immediate 'grant select on soe.address to ggadmin';
  execute immediate 'grant select on soe.cust_pr to ggadmin';
  execute immediate 'grant select on soe.cancelamt to ggadmin';
  execute immediate 'grant select on soe.call_center_log to ggadmin';
  execute immediate 'grant select on soe.cust_info to ggadmin';
  dbms_utility.compile_schema(schema => 'GGADMIN', compile_all => false);
exception
  when others then
    dbms_output.put_line('WARN: target AI object repair skipped or failed: ' || sqlerrm);
end;
/

set lines 220
set pages 80
col owner format a10
col job_name format a34
col enabled format a8
col state format a14
col repeat_interval format a34
col last_start_date format a32
col next_run_date format a32

select user owner,
       job_name,
       enabled,
       state,
       repeat_interval,
       to_char(last_start_date, 'YYYY-MM-DD HH24:MI:SS') last_start_date,
       to_char(next_run_date, 'YYYY-MM-DD HH24:MI:SS') next_run_date
from user_scheduler_jobs
where job_name = 'INS2_CHURN_LLM_COMMENT_JOB';

col queue_cnt format 999999
col result_cnt format 999999
col generated_cnt format 999999
col error_cnt format 999999

select (select count(*) from soe.ins2_churn_action_queue_v) queue_cnt,
       (select count(*) from soe.ins2_churn_llm_result) result_cnt,
       (select count(*) from soe.ins2_churn_llm_result where status = 'GENERATED') generated_cnt,
       (select count(*) from soe.ins2_churn_llm_result where status = 'ERROR') error_cnt
from dual;
