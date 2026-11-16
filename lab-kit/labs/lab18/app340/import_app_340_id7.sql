set define off
set serveroutput on size unlimited
set feedback on timing on verify off
whenever sqlerror exit sql.sqlcode rollback

alter session set container=ORCLPDB1;

begin
  apex_application_install.set_workspace_id(3000124735735903);
  apex_application_install.set_application_id(340);
  apex_application_install.set_offset(12437760538005619);
  apex_application_install.set_application_name('DS그룹 보험 정보계 2.0');
  apex_application_install.set_application_alias('DS-INSURANCE-360');
  apex_application_install.set_schema('GGADMIN');
  apex_application_install.set_auto_install_sup_obj(true);
end;
/

@f340.sql

exit
