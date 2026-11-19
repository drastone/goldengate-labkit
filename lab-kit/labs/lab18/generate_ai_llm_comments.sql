define row_limit = 2

alter session set container=ORCLPDB1;

begin
  soe.ins2_churn_llm_pkg.generate_comments(&row_limit);
end;
/

set lines 240
set pages 80
set long 10000
set longchunksize 10000
col source_cust_id format 999999
col status format a12
col model_name format a24
col error_message format a60
col llm_comment format a120

select source_cust_id,
       status,
       model_name,
       substr(error_message, 1, 60) error_message,
       dbms_lob.substr(llm_comment, 300, 1) llm_comment
from soe.ins2_churn_llm_result
order by updated_at desc
fetch first 5 rows only;
