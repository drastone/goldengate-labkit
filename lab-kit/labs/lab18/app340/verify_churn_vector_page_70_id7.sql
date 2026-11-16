set define off
set serveroutput on
set pages 200 lines 260
whenever sqlerror exit sql.sqlcode rollback
alter session set container=ORCLPDB1;

prompt === CHURN VECTOR OBJECTS ===
select object_type, object_name, status
  from dba_objects
 where owner = 'SOE'
   and object_name in (
     'INS2_CHURN_SEED_PHRASE',
     'INS2_CHURN_CALL_VECTOR',
     'INS2_CHURN_FP_CARE',
     'INS2_CHURN_VECTOR_PKG',
     'INS2_CHURN_SEED_MATCH_V',
     'INS2_CHURN_LOG_SCORE_V',
     'INS2_CHURN_CANDIDATE_V',
     'INS2_CHURN_ACTION_QUEUE_V',
     'INS2_CHURN_KPI_V'
   )
 order by object_type, object_name;

prompt === APEX PAGE / NAVIGATION ===
select id, name, alias, step_title
  from apex_260100.wwv_flow_steps
 where flow_id = 340
   and id = 70;

select list_item_display_sequence, list_item_link_text, static_id, list_item_link_target
  from apex_260100.wwv_flow_list_items
 where flow_id = 340
   and static_id = 'nav-churn-vector';

prompt === VECTOR STATUS ===
select vector_status, count(*) cnt
  from soe.ins2_churn_call_vector
 group by vector_status
 order by vector_status;

prompt === TOP CHURN CANDIDATES ===
select source_cust_id,
       assigned_fp_id,
       risk_band,
       churn_score,
       churn_reason,
       call_cnt_3m,
       late_pmt_cnt,
       substr(consult_text, 1, 80) consult_text
  from soe.ins2_churn_action_queue_v
 order by churn_score desc, due_date
 fetch first 20 rows only;

prompt === KPI ===
select label, value
  from soe.ins2_churn_kpi_v;
