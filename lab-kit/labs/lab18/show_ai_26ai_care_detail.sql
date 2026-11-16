set verify off
set feedback on
set lines 240
set pages 80
set long 5000
set longchunksize 5000

alter session set container=ORCLPDB1;

col customer_name format a14
col work_type format a22
col contact_priority format a16
col risk_band format a12
col churn_reason format a24
col consult_text format a70
col fp_coach_comment format a100

define p_cust_id = '&1'

prompt
prompt == Target SOE churn care summary ==

select source_cust_id,
       customer_name,
       assigned_fp_id,
       work_type,
       contact_priority,
       risk_band,
       churn_score,
       churn_reason
  from soe.ins2_churn_action_queue_v
 where source_cust_id = &&p_cust_id;

prompt
prompt == Consult text ==

select substr(consult_text, 1, 120) consult_text
  from soe.ins2_churn_action_queue_v
 where source_cust_id = &&p_cust_id;

prompt
prompt == FP coaching comment ==

select substr(fp_coach_comment, 1, 500) fp_coach_comment
  from soe.ins2_churn_action_queue_v
 where source_cust_id = &&p_cust_id;

undefine p_cust_id
