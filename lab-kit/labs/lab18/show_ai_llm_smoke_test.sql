alter session set container=ORCLPDB1;

set lines 220
set pages 80
set long 10000
set longchunksize 10000
col response format a160

select dbms_lob.substr(soe.ins2_churn_llm_pkg.smoke_test, 500, 1) response
from dual;
