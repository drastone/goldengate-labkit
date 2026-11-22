set define off
set serveroutput on size unlimited
whenever sqlerror exit sql.sqlcode rollback

alter session set container=ORCLPDB1;

--------------------------------------------------------------------------------
-- Chapter 20 - Data Fabric Designer
--
-- Purpose
--   Add the first Data Fabric Designer page to App 101 GoldenGate Integrated
--   Operations Console. The page is intentionally metadata-driven. It does not
--   require Kafka, Iceberg, Trino, or dashboard containers to be running.
--------------------------------------------------------------------------------

-- BEGIN APP101 FABRIC SUPPORTING OBJECTS
create table if not exists ggadmin.fabric_node (
  node_code       varchar2(80) primary key,
  node_name       varchar2(200) not null,
  node_type       varchar2(40) not null,
  domain_name     varchar2(100),
  system_name     varchar2(100),
  layer_no        number not null,
  display_order   number not null,
  status          varchar2(30) default 'ACTIVE' not null,
  resource_ref    varchar2(500),
  description     varchar2(1000),
  created_at      timestamp default systimestamp not null,
  updated_at      timestamp default systimestamp not null,
  constraint fabric_node_type_ck check (node_type in (
    'SOURCE_TABLE','OGG_EXTRACT','TRAIL','OGG_REPLICAT','DATA_STREAM',
    'STREAM_TARGET','LAKEHOUSE_TABLE','TRANSFORM_JOB','DATA_PRODUCT',
    'DASHBOARD','APEX_APP','GOVERNANCE'
  )),
  constraint fabric_node_status_ck check (status in ('ACTIVE','DESIGN','OFFLINE','OPTIONAL','DEPRECATED'))
);

create table if not exists ggadmin.fabric_edge (
  edge_code       varchar2(100) primary key,
  from_node_code  varchar2(80) not null,
  to_node_code    varchar2(80) not null,
  edge_type       varchar2(40) not null,
  mapping_ref     varchar2(500),
  status          varchar2(30) default 'ACTIVE' not null,
  description     varchar2(1000),
  created_at      timestamp default systimestamp not null,
  updated_at      timestamp default systimestamp not null,
  constraint fabric_edge_fk1 foreign key (from_node_code) references ggadmin.fabric_node(node_code),
  constraint fabric_edge_fk2 foreign key (to_node_code) references ggadmin.fabric_node(node_code),
  constraint fabric_edge_type_ck check (edge_type in (
    'CAPTURE','WRITE_TRAIL','APPLY','PUBLISH_STREAM','CONSUME_STREAM',
    'APPEND_BRONZE','BUILD_SILVER','BUILD_GOLD','SERVE_DASHBOARD',
    'GOVERN'
  )),
  constraint fabric_edge_status_ck check (status in ('ACTIVE','DESIGN','OFFLINE','OPTIONAL','DEPRECATED'))
);

create table if not exists ggadmin.fabric_node_property (
  node_code       varchar2(80) not null,
  property_name   varchar2(100) not null,
  property_value  varchar2(1000),
  created_at      timestamp default systimestamp not null,
  updated_at      timestamp default systimestamp not null,
  constraint fabric_node_property_pk primary key (node_code, property_name),
  constraint fabric_node_property_fk1 foreign key (node_code) references ggadmin.fabric_node(node_code)
);

create table if not exists ggadmin.fabric_table_column (
  owner_name      varchar2(128) not null,
  table_name      varchar2(128) not null,
  column_name     varchar2(128) not null,
  column_id       number,
  data_type       varchar2(128),
  nullable        varchar2(1),
  data_default    varchar2(4000),
  column_comment  varchar2(4000),
  updated_at      timestamp default systimestamp not null,
  constraint fabric_table_column_pk primary key (owner_name, table_name, column_name)
);

create table if not exists ggadmin.fabric_supplemental_log (
  owner_name        varchar2(128) not null,
  table_name        varchar2(128) not null,
  source_system     varchar2(100) default 'demo_osrc_23ai' not null,
  schema_prepared   varchar2(1) default 'N' not null,
  table_prepared    varchar2(1) default 'N' not null,
  pk_logging        varchar2(20),
  ui_logging        varchar2(20),
  fk_logging        varchar2(20),
  all_logging       varchar2(20),
  checked_at        timestamp default systimestamp not null,
  check_note        varchar2(1000),
  constraint fabric_supplemental_log_pk primary key (owner_name, table_name, source_system),
  constraint fabric_supp_schema_ck check (schema_prepared in ('Y','N')),
  constraint fabric_supp_table_ck check (table_prepared in ('Y','N'))
);

create table if not exists ggadmin.fabric_change_request (
  request_id       number generated always as identity primary key,
  request_status   varchar2(30) default 'PLANNED' not null,
  process_name     varchar2(128) not null,
  process_type     varchar2(40) not null,
  source_table     varchar2(261) not null,
  target_table     varchar2(261),
  change_sql       clob not null,
  supplemental_ok  varchar2(1) default 'N' not null,
  restart_plan     varchar2(1000),
  requested_by     varchar2(255),
  requested_at     timestamp default systimestamp not null,
  constraint fabric_change_status_ck check (request_status in ('PLANNED','APPROVED','APPLIED','FAILED','CANCELLED')),
  constraint fabric_change_supp_ck check (supplemental_ok in ('Y','N'))
);

comment on table ggadmin.fabric_node is
  'Data Fabric Designer에서 source table, GoldenGate process, stream, data product, dashboard 같은 asset node를 관리한다.';
comment on table ggadmin.fabric_edge is
  'Data Fabric Designer에서 node 간 CDC/stream/transform/serve 관계를 관리한다.';
comment on table ggadmin.fabric_node_property is
  'Data Fabric node별 보조 속성을 관리한다.';
comment on table ggadmin.fabric_table_column is
  'Data Fabric Designer가 DB dictionary comment에서 수집한 업무 table/column metadata cache.';
comment on table ggadmin.fabric_supplemental_log is
  'Data Fabric Set Table Wizard가 Extract TABLE 추가 전 확인하는 source supplemental logging 상태 cache.';
comment on table ggadmin.fabric_change_request is
  'Data Fabric Set Table Wizard에서 생성한 GoldenGate parameter 변경 요청과 restart plan.';

-- BEGIN PRIVILEGED FABRIC ACL
begin
  for p in (select 'GGADMIN' principal from dual union all select 'APEX_260100' from dual) loop
    begin
      dbms_network_acl_admin.append_host_ace(
        host => 'demo_ogg_23ai',
        lower_port => 18091,
        upper_port => 18091,
        ace => xs$ace_type(
          privilege_list => xs$name_list('http','connect'),
          principal_name => p.principal,
          principal_type => xs_acl.ptype_db));
    exception
      when others then
        if sqlcode = -24243 then
          null;
        else
          raise;
        end if;
    end;
  end loop;
  commit;
end;
/
-- END PRIVILEGED FABRIC ACL

declare
  procedure upsert_node(
    p_code varchar2,
    p_name varchar2,
    p_type varchar2,
    p_domain varchar2,
    p_system varchar2,
    p_layer number,
    p_order number,
    p_status varchar2,
    p_ref varchar2,
    p_desc varchar2
  ) is
  begin
    merge into ggadmin.fabric_node d
    using (
      select p_code node_code,
             p_name node_name,
             p_type node_type,
             p_domain domain_name,
             p_system system_name,
             p_layer layer_no,
             p_order display_order,
             p_status status,
             p_ref resource_ref,
             p_desc description
        from dual
    ) s
       on (d.node_code = s.node_code)
     when matched then update set
          d.node_name = s.node_name,
          d.node_type = s.node_type,
          d.domain_name = s.domain_name,
          d.system_name = s.system_name,
          d.layer_no = s.layer_no,
          d.display_order = s.display_order,
          d.status = s.status,
          d.resource_ref = s.resource_ref,
          d.description = s.description,
          d.updated_at = systimestamp
     when not matched then insert (
          node_code, node_name, node_type, domain_name, system_name,
          layer_no, display_order, status, resource_ref, description
        ) values (
          s.node_code, s.node_name, s.node_type, s.domain_name, s.system_name,
          s.layer_no, s.display_order, s.status, s.resource_ref, s.description
        );
  end;

  procedure upsert_edge(
    p_code varchar2,
    p_from varchar2,
    p_to varchar2,
    p_type varchar2,
    p_ref varchar2,
    p_status varchar2,
    p_desc varchar2
  ) is
  begin
    merge into ggadmin.fabric_edge d
    using (
      select p_code edge_code,
             p_from from_node_code,
             p_to to_node_code,
             p_type edge_type,
             p_ref mapping_ref,
             p_status status,
             p_desc description
        from dual
    ) s
       on (d.edge_code = s.edge_code)
     when matched then update set
          d.from_node_code = s.from_node_code,
          d.to_node_code = s.to_node_code,
          d.edge_type = s.edge_type,
          d.mapping_ref = s.mapping_ref,
          d.status = s.status,
          d.description = s.description,
          d.updated_at = systimestamp
     when not matched then insert (
          edge_code, from_node_code, to_node_code, edge_type,
          mapping_ref, status, description
        ) values (
          s.edge_code, s.from_node_code, s.to_node_code, s.edge_type,
          s.mapping_ref, s.status, s.description
        );
  end;

  function table_comment(p_owner varchar2, p_table_name varchar2, p_fallback varchar2) return varchar2 is
    l_comment varchar2(4000);
  begin
    select comments
      into l_comment
      from all_tab_comments
     where owner = upper(p_owner)
       and table_name = upper(p_table_name)
       and table_type = 'TABLE';

    return nvl(l_comment, p_fallback);
  exception
    when no_data_found then
      return p_fallback;
  end;
begin
  delete from ggadmin.fabric_edge
   where edge_code in (
         'E_TRAIL_CA_TO_D01',
         'E_SRC_CUST_TO_FC01',
         'E_SRC_NORMAL_TO_FC01',
         'E_SRC_CFUND_TO_FC02',
         'E_SRC_OPSTATUS_TO_FC02',
         'E_SRC_TOT_AMT_TO_FC02',
         'E_FC01_TO_TRAIL_K1',
         'E_FC02_TO_TRAIL_K2',
         'E_SRC_CUST_TO_C01',
         'E_TRAIL_CA_TO_F02',
         'E_TRAIL_CA_TO_KAF01',
         'E_SRC_CFUND_TO_C01',
         'E_SRC_OPSTATUS_TO_C01',
         'E_SRC_TOT_AMT_TO_C01',
         'E_SRC_CUST_TO_C02',
         'E_C01_TO_TRAIL_CA',
         'E_C02_TO_TRAIL_CB',
         'E_C01_TO_TRAIL_K1',
         'E_C02_TO_TRAIL_K2',
         'E_TRAIL_CA_TO_F01',
         'E_TRAIL_CB_TO_F02',
         'E_TRAIL_CB_TO_KAF01'
       )
      or from_node_code in ('OGG_REPLICAT_D01','OGG_EXTRACT_C01','OGG_EXTRACT_C02','OGG_EXTRACT_FC01','OGG_EXTRACT_FC02','OGG_REPLICAT_F01','OGG_REPLICAT_F02','OGG_TRAIL_CA','OGG_TRAIL_CB')
      or to_node_code in ('OGG_REPLICAT_D01','OGG_EXTRACT_C01','OGG_EXTRACT_C02','OGG_EXTRACT_FC01','OGG_EXTRACT_FC02','OGG_REPLICAT_F01','OGG_REPLICAT_F02','OGG_TRAIL_CA','OGG_TRAIL_CB');
  delete from ggadmin.fabric_node_property
   where node_code in ('SRC_SOE_CUST_INFO','OGG_REPLICAT_D01','OGG_EXTRACT_C01','OGG_EXTRACT_C02','OGG_EXTRACT_FC01','OGG_EXTRACT_FC02','OGG_REPLICAT_F01','OGG_REPLICAT_F02','OGG_TRAIL_CA','OGG_TRAIL_CB');
  delete from ggadmin.fabric_node
   where node_code in ('SRC_SOE_CUST_INFO','OGG_REPLICAT_D01','OGG_EXTRACT_C01','OGG_EXTRACT_C02','OGG_EXTRACT_FC01','OGG_EXTRACT_FC02','OGG_REPLICAT_F01','OGG_REPLICAT_F02','OGG_TRAIL_CA','OGG_TRAIL_CB');

  upsert_node('SRC_SOE_NORMAL_TABLES', 'Normal SOE tables', 'SOURCE_TABLE', '일반 업무', 'demo_osrc_23ai', 1, 5, 'ACTIVE', 'SOE.* except heavy lane', 'FC01이 capture하는 일반 업무 table 묶음. CFUND_DT, OPSTATUS, TOT_AMT는 heavy lane으로 분리한다.');
  upsert_node('SRC_SOE_CFUND_DT', 'SOE.CFUND_DT', 'SOURCE_TABLE', '보험료/펀드', 'demo_osrc_23ai', 1, 10, 'ACTIVE', 'SOE.CFUND_DT', table_comment('SOE', 'CFUND_DT', 'Source 업무계에서 발생하는 펀드/납입 변경 이벤트'));
  upsert_node('SRC_SOE_OPSTATUS', 'SOE.OPSTATUS', 'SOURCE_TABLE', '운영상태', 'demo_osrc_23ai', 1, 11, 'ACTIVE', 'SOE.OPSTATUS', table_comment('SOE', 'OPSTATUS', '업무 처리 상태와 운영 activity event'));
  upsert_node('SRC_SOE_TOT_AMT', 'SOE.TOT_AMT', 'SOURCE_TABLE', '보험료/펀드', 'demo_osrc_23ai', 1, 12, 'ACTIVE', 'SOE.TOT_AMT', table_comment('SOE', 'TOT_AMT', '집계성 금액 변동 event'));
  upsert_node('OGG_EXTRACT_C01', 'Extract C01', 'OGG_EXTRACT', 'Baseline Capture', 'demo_ogg_23ai', 2, 5, 'ACTIVE', 'C01', '5장부터 이어지는 기본 Oracle CDC capture. SOE 전체 변경을 ca trail에 기록한다.');
  upsert_node('OGG_EXTRACT_FC01', 'Extract FC01', 'OGG_EXTRACT', 'Normal Capture', 'demo_ogg_23ai', 2, 10, 'ACTIVE', 'FC01', 'CFUND_DT, OPSTATUS, TOT_AMT를 제외한 나머지 SOE table을 capture');
  upsert_node('OGG_EXTRACT_FC02', 'Extract FC02', 'OGG_EXTRACT', 'Heavy Capture', 'demo_ogg_23ai', 2, 20, 'ACTIVE', 'FC02', 'CFUND_DT, OPSTATUS, TOT_AMT heavy/batch-like 업무 변경을 capture');
  upsert_node('OGG_TRAIL_CA', 'Trail ca', 'TRAIL', 'Baseline Trail', 'demo_ogg_23ai', 3, 5, 'ACTIVE', 'ca', 'C01이 기록하고 D01이 읽는 기본 Oracle target apply trail');
  upsert_node('OGG_TRAIL_K1', 'Trail k1', 'TRAIL', 'Normal Trail', 'demo_ogg_23ai', 3, 10, 'ACTIVE', 'k1', 'FC01이 기록하는 normal table lane trail');
  upsert_node('OGG_TRAIL_K2', 'Trail k2', 'TRAIL', 'Heavy Trail', 'demo_ogg_23ai', 3, 20, 'ACTIVE', 'k2', 'FC02가 기록하는 heavy table lane trail');
  upsert_node('OGG_REPLICAT_D01', 'Replicat D01', 'OGG_REPLICAT', 'Oracle Target', 'demo_ogg_23ai', 4, 5, 'ACTIVE', 'D01', '5장부터 이어지는 기본 Oracle target apply Replicat. ca trail을 읽어 SOE 전체를 적용한다.');
  upsert_node('OGG_REPLICAT_FD01', 'Replicat FD01', 'OGG_REPLICAT', 'Oracle Target', 'demo_ogg_23ai', 4, 10, 'ACTIVE', 'FD01', 'k1 trail의 일반 업무 table을 target으로 apply');
  upsert_node('OGG_REPLICAT_FD02', 'Replicat FD02', 'OGG_REPLICAT', 'Oracle Target', 'demo_ogg_23ai', 4, 20, 'ACTIVE', 'FD02', 'k2 trail에서 SOE.CFUND_DT만 분리 apply');
  upsert_node('OGG_REPLICAT_FD03', 'Replicat FD03', 'OGG_REPLICAT', 'Oracle Target', 'demo_ogg_23ai', 4, 30, 'ACTIVE', 'FD03', 'k2 trail에서 SOE.OPSTATUS, SOE.TOT_AMT를 분리 apply');
  upsert_node('OGG_REPLICAT_KAF01', 'Replicat KAF01', 'OGG_REPLICAT', 'Kafka Target', 'demo_oggbd_23ai', 4, 20, 'DESIGN', 'KAF01', 'Kafka target candidate. Parameter and runtime status must be verified before use.');
  upsert_node('OGG_DATA_STREAM_DS_LAKE', 'Data Stream DS_LAKE', 'DATA_STREAM', 'Data Streams', 'demo_ogg_23ai', 4, 40, 'ACTIVE', 'DS_LAKE', 'GoldenGate heavy lane trail을 WebSocket Data Stream으로 개방');
  upsert_node('ICEBERG_BRONZE_CFUND', 'Bronze ds_cfund_dt_events', 'LAKEHOUSE_TABLE', 'Lakehouse Bronze', 'demo_iceberg_catalog', 5, 10, 'OFFLINE', 'insurance.ds_cfund_dt_events', 'Lakehouse table asset registered in lab metadata. Runtime existence is not verified by this page yet.');
  upsert_node('ICEBERG_SILVER_ACTIVITY', 'Silver customer_fund_activity', 'TRANSFORM_JOB', 'Lakehouse Silver', 'demo_iceberg_catalog', 5, 20, 'OFFLINE', 'insurance.silver_customer_fund_activity', 'Transform asset registered in lab metadata. Runtime execution history is not verified by this page yet.');
  upsert_node('ICEBERG_GOLD_ACTION', 'Gold channel_action_candidate', 'DATA_PRODUCT', 'Lakehouse Gold', 'demo_iceberg_catalog', 6, 10, 'OFFLINE', 'insurance.gold_channel_action_candidate', 'Data product asset registered in lab metadata. Business purpose and owner are not provided by catalog metadata yet.');
  upsert_node('DASHBOARD_GOLD_CHANNEL', 'Gold Channel Action Dashboard', 'DASHBOARD', 'Dashboard', 'demo_gold_dashboard', 6, 20, 'OFFLINE', 'gold_channel_action_dashboard.html', 'Dashboard asset registered in lab metadata. File existence and serving endpoint are not verified by this page yet.');
  upsert_node('APEX_DATA_FABRIC', 'Data Fabric Designer', 'APEX_APP', 'Control Plane', 'demo_otrg_23ai', 6, 30, 'ACTIVE', 'App 101 Page 200', 'GoldenGate 통합 Console 안에서 fabric metadata를 시각화');

  upsert_edge('E_SRC_NORMAL_TO_FC01', 'SRC_SOE_NORMAL_TABLES', 'OGG_EXTRACT_FC01', 'CAPTURE', 'TABLE entries except CFUND_DT, OPSTATUS, TOT_AMT', 'ACTIVE', 'FC01이 일반 업무 table 묶음을 capture');
  upsert_edge('E_SRC_CFUND_TO_FC02', 'SRC_SOE_CFUND_DT', 'OGG_EXTRACT_FC02', 'CAPTURE', 'TABLE SOE.CFUND_DT', 'ACTIVE', '펀드 활동 table 변경을 FC02가 capture');
  upsert_edge('E_SRC_OPSTATUS_TO_FC02', 'SRC_SOE_OPSTATUS', 'OGG_EXTRACT_FC02', 'CAPTURE', 'TABLE SOE.OPSTATUS', 'ACTIVE', '운영상태 table 변경을 FC02가 capture');
  upsert_edge('E_SRC_TOT_AMT_TO_FC02', 'SRC_SOE_TOT_AMT', 'OGG_EXTRACT_FC02', 'CAPTURE', 'TABLE SOE.TOT_AMT', 'ACTIVE', '집계성 금액 table 변경을 FC02가 capture');
  upsert_edge('E_C01_TO_TRAIL_CA', 'OGG_EXTRACT_C01', 'OGG_TRAIL_CA', 'WRITE_TRAIL', 'EXTTRAIL ca', 'ACTIVE', 'C01이 기본 SOE 변경을 ca trail에 기록');
  upsert_edge('E_TRAIL_CA_TO_D01', 'OGG_TRAIL_CA', 'OGG_REPLICAT_D01', 'APPLY', 'MAP SOE.*, TARGET SOE.*', 'ACTIVE', 'D01이 ca trail을 읽어 기본 Oracle target으로 apply');
  upsert_edge('E_FC01_TO_TRAIL_K1', 'OGG_EXTRACT_FC01', 'OGG_TRAIL_K1', 'WRITE_TRAIL', 'EXTTRAIL k1', 'ACTIVE', 'FC01이 일반 table 변경을 k1 trail에 기록');
  upsert_edge('E_FC02_TO_TRAIL_K2', 'OGG_EXTRACT_FC02', 'OGG_TRAIL_K2', 'WRITE_TRAIL', 'EXTTRAIL k2', 'ACTIVE', 'FC02가 heavy table 변경을 k2 trail에 기록');
  upsert_edge('E_TRAIL_K1_TO_FD01', 'OGG_TRAIL_K1', 'OGG_REPLICAT_FD01', 'APPLY', 'explicit MAP entries except CFUND_DT, OPSTATUS, TOT_AMT', 'ACTIVE', 'FD01이 k1의 일반 업무 table을 apply');
  upsert_edge('E_TRAIL_K2_TO_FD02', 'OGG_TRAIL_K2', 'OGG_REPLICAT_FD02', 'APPLY', 'MAP SOE.CFUND_DT', 'ACTIVE', 'FD02가 k2에서 CFUND_DT만 apply');
  upsert_edge('E_TRAIL_K2_TO_FD03', 'OGG_TRAIL_K2', 'OGG_REPLICAT_FD03', 'APPLY', 'MAP SOE.OPSTATUS, SOE.TOT_AMT', 'ACTIVE', 'FD03이 k2에서 OPSTATUS/TOT_AMT를 apply');
  upsert_edge('E_TRAIL_K1_TO_KAF01', 'OGG_TRAIL_K1', 'OGG_REPLICAT_KAF01', 'APPLY', 'Kafka handler mapping', 'DESIGN', 'Kafka target candidate path.');
  upsert_edge('E_TRAIL_K2_TO_DS_LAKE', 'OGG_TRAIL_K2', 'OGG_DATA_STREAM_DS_LAKE', 'PUBLISH_STREAM', 'trail k2 -> DS_LAKE', 'ACTIVE', 'Data Streams가 heavy lane trail을 stream으로 제공');
  upsert_edge('E_DS_LAKE_TO_BRONZE', 'OGG_DATA_STREAM_DS_LAKE', 'ICEBERG_BRONZE_CFUND', 'APPEND_BRONZE', 'demo_iceberg_writer', 'OFFLINE', 'Lightweight writer가 CDC event를 Bronze table에 append');
  upsert_edge('E_BRONZE_TO_SILVER', 'ICEBERG_BRONZE_CFUND', 'ICEBERG_SILVER_ACTIVITY', 'BUILD_SILVER', 'build_silver_fund_activity.sh', 'OFFLINE', 'Planned transform from Bronze asset to Silver asset.');
  upsert_edge('E_SILVER_TO_GOLD', 'ICEBERG_SILVER_ACTIVITY', 'ICEBERG_GOLD_ACTION', 'BUILD_GOLD', 'build_gold_channel_action.sh', 'OFFLINE', 'Planned transform from Silver asset to Gold asset.');
  upsert_edge('E_GOLD_TO_DASHBOARD', 'ICEBERG_GOLD_ACTION', 'DASHBOARD_GOLD_CHANNEL', 'SERVE_DASHBOARD', 'build_gold_dashboard.sh', 'OFFLINE', 'Planned dashboard serving path.');
  upsert_edge('E_FABRIC_GOVERNS_FLOW', 'APEX_DATA_FABRIC', 'ICEBERG_GOLD_ACTION', 'GOVERN', 'metadata registry', 'ACTIVE', 'Console이 data product 관계와 운영 metadata를 관리');

  delete from ggadmin.fabric_table_column
   where owner_name = 'SOE';

  insert into ggadmin.fabric_table_column (
    owner_name,
    table_name,
    column_name,
    column_id,
    data_type,
    nullable,
    data_default,
    column_comment
  )
  select c.owner,
         c.table_name,
         c.column_name,
         c.column_id,
         c.data_type ||
           case
             when c.data_type in ('VARCHAR2','CHAR','NVARCHAR2','NCHAR') then '(' || c.char_length || ')'
             when c.data_type = 'NUMBER' and c.data_precision is not null then '(' || c.data_precision || nvl2(c.data_scale, ',' || c.data_scale, '') || ')'
           end,
         c.nullable,
         cast(null as varchar2(4000)),
         cc.comments
    from all_tab_columns c
    left join all_col_comments cc
      on cc.owner = c.owner
     and cc.table_name = c.table_name
     and cc.column_name = c.column_name
   where c.owner = 'SOE'
     and c.table_name in (
       'CUST_INFO','CUST_PR','CFUND_DT','OPSTATUS','TOT_AMT','CFUND_DEPOSIT',
       'CFUND_RAT','CFUND_RATIO','CFUND_RAT_TMP','CUST_DEP_DT','CUST_GEN_AMT',
       'CANCELAMT','CANCELFP','CALL_CENTER_LOG','PRODUCT','FUNDM','FUND_PRICE',
       'EMPLOYEE','ADDRESS','RESERVES_AMT','OSA_CANCEL_PREDICTION',
       'OSA_CANCEL_PREDICTION_GEN'
     );

  delete from ggadmin.fabric_supplemental_log
   where owner_name = 'SOE'
     and source_system = 'demo_osrc_23ai';

  insert into ggadmin.fabric_supplemental_log (
    owner_name,
    table_name,
    source_system,
    schema_prepared,
    table_prepared,
    pk_logging,
    ui_logging,
    fk_logging,
    all_logging,
    check_note
  )
  select owner_name,
         table_name,
         'demo_osrc_23ai',
         'Y',
         'Y',
         'IMPLICIT',
         'IMPLICIT',
         'IMPLICIT',
         'NO',
         'id7 source DB 기준: SOE schema는 DBA_CAPTURE_PREPARED_SCHEMAS에 등록되어 있고, table은 DBA_CAPTURE_PREPARED_TABLES에서 확인된다.'
    from (
      select distinct owner_name, table_name
        from ggadmin.fabric_table_column
       where owner_name = 'SOE'
    );

  commit;
end;
/

create or replace package ggadmin.fabric_designer_pkg authid definer as
  function render return clob;
  function render_canvas return clob;
  function render_canvas_design return clob;
  function render_set_table_wizard(p_node_code varchar2) return clob;
end fabric_designer_pkg;
/

create or replace package body ggadmin.fabric_designer_pkg as
  function h(p_value varchar2) return varchar2 is
  begin
    return apex_escape.html(nvl(p_value, ''));
  end;

  function status_badge(p_status varchar2) return varchar2 is
    l_status varchar2(30) := upper(nvl(p_status, 'UNKNOWN'));
    l_class varchar2(30);
  begin
    l_class := case l_status
      when 'ACTIVE' then 'ok'
      when 'DESIGN' then 'design'
      when 'OFFLINE' then 'off'
      when 'OPTIONAL' then 'optional'
      else 'muted'
    end;
    return '<span class="df-badge ' || l_class || '">' || h(l_status) || '</span>';
  end;

  function node_properties(p_node_code varchar2) return varchar2 is
    l_text varchar2(1000);
  begin
    select listagg(property_name || '=' || property_value, ' · ')
             within group (
               order by case property_name
                 when 'trail' then 1
                 when 'table_count' then 2
                 when 'map_count' then 3
                 when 'parameter_file' then 4
                 else 5
               end
             )
      into l_text
      from ggadmin.fabric_node_property
     where node_code = p_node_code
       and property_name in ('trail','table_count','map_count');

    return l_text;
  exception
    when no_data_found then
      return null;
  end;

  function render return clob is
    l_html clob;
    l_nodes number;
    l_edges number;
    l_products number;
    l_columns number;
    l_active number;
    l_design number;
    l_offline number;
    l_props varchar2(1000);
    l_source_tables varchar2(1000);
    l_lineage varchar2(1000);
    l_serving_target varchar2(200);
    l_provenance varchar2(100);
    l_readiness varchar2(4000);
    l_stream_status varchar2(30);
  begin
    select count(*) into l_nodes from ggadmin.fabric_node;
    select count(*) into l_edges from ggadmin.fabric_edge;
    select count(*) into l_products from ggadmin.fabric_node where node_type in ('DATA_PRODUCT','DASHBOARD');
    select count(*) into l_columns from ggadmin.fabric_table_column where column_comment is not null;
    select count(*) into l_active from ggadmin.fabric_node where status = 'ACTIVE';
    select count(*) into l_design from ggadmin.fabric_node where status = 'DESIGN';
    select count(*) into l_offline from ggadmin.fabric_node where status = 'OFFLINE';

    l_html := to_clob(q'~<style>
.df-wrap{--ink:#172033;--muted:#64748b;--line:#d8e1eb;--soft:#f7fafc;--blue:#1f6feb;--green:#0f9f6e;--amber:#b7791f;--red:#c2410c;color:var(--ink)}
.df-wrap *{box-sizing:border-box}
.df-head{border:1px solid var(--line);border-left:5px solid var(--blue);border-radius:8px;background:#fff;padding:18px 20px;margin-bottom:12px}
.df-head h1{font-size:24px;margin:0 0 6px}
.df-head p{margin:0;color:var(--muted);line-height:1.45}
.df-section-title{font-size:18px;font-weight:800;margin:0 0 10px}
.df-section-note{color:var(--muted);line-height:1.45;margin:0 0 12px}
.df-tabs{display:flex;gap:6px;margin:10px 0 12px;flex-wrap:wrap}
.df-tab{border:1px solid var(--line);border-radius:999px;padding:7px 11px;background:#fff;color:#334155;font-size:12px;cursor:pointer}
.df-tab.active{background:#172033;color:#fff;border-color:#172033}
.df-panel{display:none}
.df-panel.active{display:block}
.df-kpis{display:grid;grid-template-columns:repeat(4,minmax(0,1fr));gap:10px;margin-bottom:12px}
.df-kpi{border:1px solid var(--line);border-radius:8px;background:#fff;padding:14px}
.df-kpi-label{font-size:12px;color:var(--muted)}
.df-kpi-value{font-size:26px;font-weight:800;margin-top:4px}
.df-canvas{display:grid;grid-template-columns:repeat(6,minmax(150px,1fr));gap:10px;align-items:start}
.df-lane{border:1px solid var(--line);border-radius:8px;background:var(--soft);padding:10px;min-height:380px}
.df-lane h2{font-size:14px;margin:0 0 10px;color:#334155}
.df-grid{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:10px}
.df-grid.two{grid-template-columns:repeat(2,minmax(0,1fr))}
.df-node,.df-card{border:1px solid #cbd5e1;border-radius:8px;background:#fff;padding:10px;margin-bottom:10px;box-shadow:0 1px 4px rgba(15,23,42,.05)}
.df-node-title,.df-card-title{font-size:14px;font-weight:800;margin-bottom:4px}
.df-node-type,.df-card-meta{font-size:11px;color:var(--muted);text-transform:uppercase}
.df-node-ref{font-size:12px;color:#334155;margin-top:6px;word-break:break-word}
.df-node-desc,.df-card-desc{font-size:12px;color:var(--muted);line-height:1.35;margin-top:6px}
.df-badge{display:inline-block;border-radius:999px;font-size:10px;font-weight:800;line-height:1;padding:5px 8px;margin-top:8px}
.df-badge.ok{background:#dcfce7;color:#166534}
.df-badge.design{background:#fef3c7;color:#92400e}
.df-badge.off{background:#fee2e2;color:#991b1b}
.df-badge.optional{background:#e0f2fe;color:#075985}
.df-badge.muted{background:#e5e7eb;color:#374151}
.df-flow{margin-top:12px;border:1px solid var(--line);border-radius:8px;background:#fff;padding:14px}
.df-flow h2{font-size:16px;margin:0 0 10px}
.df-flow-row{display:grid;grid-template-columns:190px 24px 190px minmax(0,1fr);gap:8px;align-items:start;border-top:1px solid #edf2f7;padding:8px 0}
.df-flow-row:first-of-type{border-top:none}
.df-flow-node{font-weight:700}
.df-flow-type{font-size:11px;color:#475569}
.df-flow-desc{color:var(--muted);line-height:1.35}
.df-table{width:100%;border-collapse:collapse;background:#fff;border:1px solid var(--line);border-radius:8px;overflow:hidden}
.df-table th,.df-table td{border-bottom:1px solid #edf2f7;padding:8px;text-align:left;vertical-align:top}
.df-table th{background:#f8fafc;font-size:12px;color:#334155}
.df-table td{font-size:12px}
.df-pill{display:inline-block;border:1px solid var(--line);border-radius:999px;padding:3px 7px;background:#fff;font-size:11px;color:#475569;margin:2px 3px 2px 0}
.df-catalog-tools{display:flex;gap:8px;align-items:center;margin:0 0 10px;flex-wrap:wrap}
.df-catalog-search{min-width:280px;border:1px solid var(--line);border-radius:8px;padding:9px 11px;font-size:13px}
.df-catalog-note{font-size:12px;color:var(--muted)}
 .df-wrap{}@media(max-width:1200px){.df-canvas{grid-template-columns:repeat(3,minmax(0,1fr))}
.df-grid{grid-template-columns:repeat(2,minmax(0,1fr))}}@media(max-width:760px){.df-canvas,.df-grid,.df-grid.two,.df-kpis{grid-template-columns:1fr}
.df-flow-row{grid-template-columns:1fr}
.df-flow-row>div:nth-child(2){display:none}}
</style><section class="df-wrap">~');

    l_html := l_html ||
      '<div class="df-head"><h1>Data Fabric Designer</h1><p>GoldenGate process parameter와 runtime metadata를 기반으로 source table, trail, stream, target 후보, data product 관계를 하나의 fabric으로 표현합니다. Runtime에서 확인된 항목과 catalog seed 항목을 구분해 표시합니다.</p></div>' ||
      '<div class="df-tabs" role="tablist">' ||
      '<button type="button" class="df-tab active" data-df-tab="designer">Designer</button>' ||
      '<button type="button" class="df-tab" data-df-tab="catalog">Catalog</button>' ||
      '<button type="button" class="df-tab" data-df-tab="assets">Assets</button>' ||
      '<button type="button" class="df-tab" data-df-tab="pipelines">Pipelines</button>' ||
      '<button type="button" class="df-tab" data-df-tab="products">Data Products</button>' ||
      '<button type="button" class="df-tab" data-df-tab="lineage">Lineage</button>' ||
      '<button type="button" class="df-tab" data-df-tab="runtime">Runtime Status</button>' ||
      '<button type="button" class="df-tab" data-df-tab="governance">Governance</button></div>';

    l_html := l_html || '<div class="df-panel active" data-df-panel="designer">' ||
      '<div class="df-kpis"><div class="df-kpi"><div class="df-kpi-label">Fabric Nodes</div><div class="df-kpi-value">' || l_nodes || '</div></div>' ||
      '<div class="df-kpi"><div class="df-kpi-label">Fabric Edges</div><div class="df-kpi-value">' || l_edges || '</div></div>' ||
      '<div class="df-kpi"><div class="df-kpi-label">Data Products</div><div class="df-kpi-value">' || l_products || '</div></div>' ||
      '<div class="df-kpi"><div class="df-kpi-label">Column Metadata</div><div class="df-kpi-value">' || l_columns || '</div></div></div>' ||
      '<div class="df-canvas">';

    for lane in (
      select 1 layer_no, 'Source 업무계' lane_name from dual union all
      select 2, 'Capture' from dual union all
      select 3, 'Trail' from dual union all
      select 4, 'Stream / Apply' from dual union all
      select 5, 'Lakehouse 정제' from dual union all
      select 6, 'Data Product / Console' from dual
      order by layer_no
    ) loop
      l_html := l_html || '<div class="df-lane"><h2>' || h(lane.lane_name) || '</h2>';
      for n in (select * from ggadmin.fabric_node where layer_no = lane.layer_no order by display_order, node_name) loop
        l_props := node_properties(n.node_code);
        l_html := l_html || '<div class="df-node"><div class="df-node-title">' || h(n.node_name) || '</div>' ||
          '<div class="df-node-type">' || h(n.node_type) || ' · ' || h(n.system_name) || '</div>' ||
          '<div class="df-node-ref">' || h(n.resource_ref) || '</div>' ||
          '<div class="df-node-desc">' || h(n.description) || '</div>' ||
          case when l_props is not null then '<div class="df-node-desc">' || h(l_props) || '</div>' end ||
          status_badge(n.status) || '</div>';
      end loop;
      l_html := l_html || '</div>';
    end loop;
    l_html := l_html || '</div></div>';

    l_html := l_html || '<div class="df-panel" data-df-panel="catalog"><h2 class="df-section-title">Catalog</h2><p class="df-section-note">GoldenGate runtime/parameter에서 발견된 asset과 lab metadata seed를 한 곳에서 검색합니다. 이 Catalog는 enterprise catalog가 아니라 CDC fabric 운영을 위한 lightweight operational catalog입니다.</p>' ||
      '<div class="df-catalog-tools"><input class="df-catalog-search" type="search" placeholder="Search node, type, system, table, status..." aria-label="Search catalog"><span class="df-catalog-note">Verified runtime metadata와 seed/downstream artifact를 구분해서 확인합니다.</span></div>' ||
      '<table class="df-table df-catalog-table"><thead><tr><th>Asset</th><th>Type</th><th>System</th><th>Reference</th><th>Provenance</th><th>Readiness</th></tr></thead><tbody>';
    for n in (select * from ggadmin.fabric_node order by layer_no, display_order, node_type, node_name) loop
      l_props := node_properties(n.node_code);
      l_provenance := case
        when n.status = 'ACTIVE' and n.node_type in ('OGG_EXTRACT','OGG_REPLICAT','TRAIL','DATA_STREAM','SOURCE_TABLE') then 'Runtime / parameter discovered'
        when n.status = 'ACTIVE' then 'Verified runtime metadata'
        when n.status = 'DESIGN' then 'Design metadata'
        when n.status = 'OFFLINE' then 'Catalog seed / not verified'
        else 'Catalog metadata'
      end;
      l_readiness := case
        when n.status = 'ACTIVE' then 'Usable'
        when n.status = 'DESIGN' then 'Needs implementation'
        when n.status = 'OFFLINE' then 'Not verified in runtime'
        else n.status
      end;
      l_html := l_html || '<tr class="df-catalog-row"><td><b>' || h(n.node_name) || '</b><br><span class="df-card-desc">' || h(n.description) || '</span></td>' ||
        '<td>' || h(n.node_type) || '</td><td>' || h(n.system_name) || '</td><td>' || h(n.resource_ref) || '<br><span class="df-card-desc">' || h(l_props) || '</span></td>' ||
        '<td>' || h(l_provenance) || '</td><td>' || status_badge(n.status) || '<br><span class="df-card-desc">' || h(l_readiness) || '</span></td></tr>';
    end loop;
    l_html := l_html || '</tbody></table><div class="df-flow"><h2>TABLE / COLUMN Dictionary Catalog</h2><p class="df-section-note">Extract TABLE, Replicat MAP, source table node에서 발견한 table 이름을 dictionary comment cache와 연결합니다. COMMENT ON TABLE/COLUMN이 있으면 여기에서 업무 의미와 column 설명으로 보입니다.</p><table class="df-table df-catalog-table"><thead><tr><th>Table</th><th>Discovered From</th><th>Table Comment</th><th>Column Metadata</th></tr></thead><tbody>';
    for t in (
      with prop_table_raw as (
        select n.node_name process_name,
               p.property_name,
               upper(trim(regexp_substr(p.property_value, '[^,]+', 1, lv.lvl))) table_ref
          from ggadmin.fabric_node_property p
          join ggadmin.fabric_node n
            on n.node_code = p.node_code
          cross join (select level lvl from dual connect by level <= 300) lv
         where p.property_name in ('tables','maps')
           and regexp_substr(p.property_value, '[^,]+', 1, lv.lvl) is not null
      ),
      prop_tables as (
        select table_ref,
               listagg(process_name || ' ' || upper(property_name), ', ') within group (order by process_name, property_name) discovered_by
          from (
            select distinct table_ref, process_name, property_name
              from prop_table_raw
             where table_ref like '%.%'
               and table_ref not like '%*%'
          )
         group by table_ref
      ),
      node_tables as (
        select upper(resource_ref) table_ref,
               listagg(node_name, ', ') within group (order by node_name) discovered_by
          from ggadmin.fabric_node
         where node_type = 'SOURCE_TABLE'
           and resource_ref like '%.%'
         group by upper(resource_ref)
      ),
      table_refs as (
        select table_ref,
               listagg(discovered_by, ', ') within group (order by discovered_by) discovered_by
          from (
            select table_ref, discovered_by from prop_tables
            union all
            select table_ref, discovered_by from node_tables
          )
         group by table_ref
      )
      select r.table_ref,
             r.discovered_by,
             nvl(max(n.description), 'No table comment cached') table_comment,
             count(c.column_name) column_count,
             count(c.column_comment) commented_count,
             (
               select listagg(column_name || ' ' || data_type ||
                              case when column_comment is not null then ' - ' || column_comment end,
                              chr(10)) within group (order by column_id)
                 from (
                   select column_name, data_type, column_comment, column_id
                     from ggadmin.fabric_table_column
                    where owner_name = substr(r.table_ref, 1, instr(r.table_ref, '.') - 1)
                      and table_name = substr(r.table_ref, instr(r.table_ref, '.') + 1)
                    order by column_id
                    fetch first 8 rows only
                 )
             ) column_sample
        from table_refs r
        left join ggadmin.fabric_node n
          on n.node_type = 'SOURCE_TABLE'
         and upper(n.resource_ref) = r.table_ref
        left join ggadmin.fabric_table_column c
          on c.owner_name = substr(r.table_ref, 1, instr(r.table_ref, '.') - 1)
         and c.table_name = substr(r.table_ref, instr(r.table_ref, '.') + 1)
       group by r.table_ref, r.discovered_by
       order by r.table_ref
    ) loop
      l_html := l_html || '<tr class="df-catalog-row"><td><b>' || h(t.table_ref) || '</b></td>' ||
        '<td>' || h(t.discovered_by) || '</td>' ||
        '<td>' || h(t.table_comment) || '</td>' ||
        '<td><b>' || to_char(t.column_count) || ' columns · ' || to_char(t.commented_count) || ' comments</b><br><span class="df-card-desc">' || replace(h(t.column_sample), chr(10), '<br>') || '</span></td></tr>';
    end loop;
    l_html := l_html || '</tbody></table></div></div>';

    l_html := l_html || '<div class="df-panel" data-df-panel="assets"><h2 class="df-section-title">Assets</h2><p class="df-section-note">Fabric을 구성하는 source table, GoldenGate process, trail, stream, lakehouse table, dashboard asset을 유형별로 확인합니다.</p><div class="df-grid">';
    for n in (select * from ggadmin.fabric_node order by node_type, layer_no, display_order, node_name) loop
      l_props := node_properties(n.node_code);
      l_html := l_html || '<div class="df-card"><div class="df-card-title">' || h(n.node_name) || '</div>' ||
        '<div class="df-card-meta">' || h(n.node_type) || ' · ' || h(n.system_name) || '</div>' ||
        '<div class="df-node-ref">' || h(n.resource_ref) || '</div>' ||
        '<div class="df-card-desc">' || h(n.description) || '</div>' ||
        case when l_props is not null then '<div class="df-card-desc">' || h(l_props) || '</div>' end ||
        status_badge(n.status) || '</div>';
    end loop;
    l_html := l_html || '</div></div>';

    l_html := l_html || '<div class="df-panel" data-df-panel="pipelines"><h2 class="df-section-title">Pipelines</h2><p class="df-section-note">FC01은 일반 table lane, FC02는 heavy table lane으로 분리합니다. Replicat, Kafka 후보, Data Stream, Iceberg 경로를 같은 metadata plane에서 함께 추적합니다.</p>';
    for e in (
      select e.edge_type, e.mapping_ref, e.description, e.status, f.node_name from_name, t.node_name to_name
        from ggadmin.fabric_edge e
        join ggadmin.fabric_node f on f.node_code = e.from_node_code
        join ggadmin.fabric_node t on t.node_code = e.to_node_code
       where e.edge_type in ('CAPTURE','WRITE_TRAIL','APPLY','PUBLISH_STREAM','APPEND_BRONZE','BUILD_SILVER','BUILD_GOLD','SERVE_DASHBOARD')
       order by f.layer_no, f.display_order, t.layer_no, t.display_order, e.edge_code
    ) loop
      l_html := l_html || '<div class="df-flow-row"><div><div class="df-flow-node">' || h(e.from_name) || '</div><div class="df-flow-type">' || h(e.edge_type) || '</div></div>' ||
        '<div>→</div><div><div class="df-flow-node">' || h(e.to_name) || '</div><div class="df-flow-type">' || h(e.mapping_ref) || '</div></div>' ||
        '<div class="df-flow-desc">' || h(e.description) || ' ' || status_badge(e.status) || '</div></div>';
    end loop;
    l_html := l_html || '</div>';

    l_html := l_html || '<div class="df-panel" data-df-panel="products"><h2 class="df-section-title">Data Products</h2><p class="df-section-note">GoldenGate 흐름이 최종적으로 어떤 업무 산출물로 이어지는지 lineage, source tables, serving target, readiness 관점으로 보여줍니다. 실제 runtime에서 발견한 항목과 lab metadata seed를 구분합니다.</p><div class="df-grid two">';
    begin
      select property_value
        into l_source_tables
        from ggadmin.fabric_node_property
       where node_code = 'OGG_EXTRACT_FC02'
         and property_name = 'tables';
    exception
      when no_data_found then
        l_source_tables := 'SOE.CFUND_DT, SOE.OPSTATUS, SOE.TOT_AMT';
    end;
    begin
      select status into l_stream_status from ggadmin.fabric_node where node_code = 'OGG_DATA_STREAM_DS_LAKE';
    exception
      when no_data_found then
        l_stream_status := 'UNKNOWN';
    end;

    for n in (
      select *
        from ggadmin.fabric_node
       where node_type in ('LAKEHOUSE_TABLE','TRANSFORM_JOB','DATA_PRODUCT','DASHBOARD')
       order by layer_no, display_order
    ) loop
      l_lineage := case n.node_code
        when 'ICEBERG_BRONZE_CFUND' then 'FC02 -> k2 -> DS_LAKE -> Bronze'
        when 'ICEBERG_SILVER_ACTIVITY' then 'FC02 -> k2 -> DS_LAKE -> Bronze -> Silver'
        when 'ICEBERG_GOLD_ACTION' then 'FC02 -> k2 -> DS_LAKE -> Bronze -> Silver -> Gold'
        when 'DASHBOARD_GOLD_CHANNEL' then 'FC02 -> k2 -> DS_LAKE -> Bronze -> Silver -> Gold -> Dashboard'
        else 'Lineage metadata is not verified yet'
      end;
      l_serving_target := case n.node_type
        when 'LAKEHOUSE_TABLE' then 'Lakehouse table'
        when 'TRANSFORM_JOB' then 'Transform / curated table'
        when 'DATA_PRODUCT' then 'Business data product'
        when 'DASHBOARD' then 'Dashboard / report'
        else n.node_type
      end;
      l_provenance := case
        when n.status = 'ACTIVE' then 'VERIFIED'
        when n.status = 'DESIGN' then 'DESIGN'
        else 'SEED / NOT VERIFIED'
      end;
      l_readiness :=
        'Source mapped: ' || case when l_source_tables is not null then 'PASS' else 'CHECK' end || chr(10) ||
        'Stream node: ' || nvl(l_stream_status, 'UNKNOWN') || chr(10) ||
        'Target asset: ' || n.status || chr(10) ||
        'Owner: not assigned';

      l_html := l_html || '<div class="df-card"><div class="df-card-title">' || h(n.node_name) || '</div>' ||
        '<div class="df-card-meta">' || h(n.domain_name) || ' · ' || h(n.node_type) || ' · ' || h(l_provenance) || '</div>' ||
        '<div class="df-node-ref">' || h(n.resource_ref) || '</div>' ||
        '<div class="df-card-desc"><b>Purpose</b><br>Not provided by catalog metadata</div>' ||
        '<div class="df-card-desc"><b>Upstream Lineage</b><br>' || h(l_lineage) || '</div>' ||
        '<div class="df-card-desc"><b>Source Tables</b><br>' || h(l_source_tables) || '</div>' ||
        '<div class="df-card-desc"><b>Serving Target</b><br>' || h(l_serving_target) || '</div>' ||
        '<div class="df-card-desc"><b>Readiness</b><br>' || replace(h(l_readiness), chr(10), '<br>') || '</div>' ||
        status_badge(n.status) || '</div>';
    end loop;
    l_html := l_html || '</div></div>';

    l_html := l_html || '<div class="df-panel" data-df-panel="lineage"><h2 class="df-section-title">Lineage</h2><p class="df-section-note">Source table에서 Extract, trail, stream/apply, lakehouse, dashboard까지 이어지는 관계를 edge 단위로 보여줍니다.</p><table class="df-table"><thead><tr><th>From</th><th>Edge</th><th>To</th><th>Mapping</th><th>Status</th></tr></thead><tbody>';
    for e in (
      select e.edge_type, e.mapping_ref, e.description, e.status, f.node_name from_name, t.node_name to_name
        from ggadmin.fabric_edge e join ggadmin.fabric_node f on f.node_code = e.from_node_code join ggadmin.fabric_node t on t.node_code = e.to_node_code
       order by f.layer_no, f.display_order, t.layer_no, t.display_order, e.edge_code
    ) loop
      l_html := l_html || '<tr><td><b>' || h(e.from_name) || '</b><br><span class="df-card-desc">' || h(e.description) || '</span></td><td>' || h(e.edge_type) || '</td><td><b>' || h(e.to_name) || '</b></td><td>' || h(e.mapping_ref) || '</td><td>' || status_badge(e.status) || '</td></tr>';
    end loop;
    l_html := l_html || '</tbody></table></div>';

    l_html := l_html || to_clob('<div class="df-panel" data-df-panel="runtime"><h2 class="df-section-title">Runtime Status</h2><p class="df-section-note">GoldenGate parameter refresh와 discovery metadata 상태를 보여줍니다. 운영판에서는 여기에서 REST API 상태, lag, heartbeat를 주기적으로 수집합니다.</p>');
    l_html := l_html || '<div class="df-kpis"><div class="df-kpi"><div class="df-kpi-label">Active</div><div class="df-kpi-value">' || to_char(l_active) || '</div></div>';
    l_html := l_html || '<div class="df-kpi"><div class="df-kpi-label">Design</div><div class="df-kpi-value">' || to_char(l_design) || '</div></div>';
    l_html := l_html || '<div class="df-kpi"><div class="df-kpi-label">Offline</div><div class="df-kpi-value">' || to_char(l_offline) || '</div></div>';
    l_html := l_html || '<div class="df-kpi"><div class="df-kpi-label">Edges</div><div class="df-kpi-value">' || to_char(l_edges) || '</div></div></div>';
    l_html := l_html || '<table class="df-table"><thead><tr><th>Node</th><th>Type</th><th>System</th><th>Discovered Metadata</th><th>Status</th></tr></thead><tbody>';
    for n in (select * from ggadmin.fabric_node order by status, layer_no, display_order) loop
      l_props := node_properties(n.node_code);
      l_html := l_html || '<tr><td><b>' || h(n.node_name) || '</b><br>' || h(n.resource_ref) || '</td><td>' || h(n.node_type) || '</td><td>' || h(n.system_name) || '</td><td>' || h(l_props) || '</td><td>' || status_badge(n.status) || '</td></tr>';
    end loop;
    l_html := l_html || '</tbody></table></div>';

    l_html := l_html || '<div class="df-panel" data-df-panel="governance"><h2 class="df-section-title">Governance</h2><p class="df-section-note">COMMENT ON TABLE/COLUMN으로 들어온 업무 사전 metadata를 Designer가 읽어 화면 설명과 column metadata로 사용합니다. 수작업 seed가 아니라 운영 dictionary를 control plane의 근거로 삼는 구조입니다.</p><div class="df-grid">';
    for d in (
      select n.resource_ref table_name, n.description table_comment, count(c.column_name) column_count, count(c.column_comment) commented_count
        from ggadmin.fabric_node n
        left join ggadmin.fabric_table_column c on n.node_type = 'SOURCE_TABLE' and c.owner_name || '.' || c.table_name = n.resource_ref
       where n.node_type = 'SOURCE_TABLE'
       group by n.resource_ref, n.description, n.display_order
       order by n.display_order
    ) loop
      l_html := l_html || '<div class="df-card"><div class="df-card-title">' || h(d.table_name) || '</div>' ||
        '<div class="df-card-meta">' || to_char(d.column_count) || ' columns · ' || to_char(d.commented_count) || ' comments</div>' ||
        '<div class="df-card-desc">' || substr(h(d.table_comment), 1, 600) || '</div></div>';
    end loop;
    l_html := l_html || '</div><div class="df-flow"><h2>Sample Column Metadata</h2>';
    for c in (
      select table_name, column_name, data_type, column_comment
        from ggadmin.fabric_table_column
       where table_name in ('CFUND_DT','CUST_INFO','OPSTATUS','TOT_AMT')
         and column_comment is not null
         and column_id <= 8
       order by table_name, column_id
    ) loop
      l_html := l_html || '<span class="df-pill"><b>' || h(c.table_name) || '.' || h(c.column_name) || '</b> · ' || h(c.data_type) || ' · ' || h(c.column_comment) || '</span>';
    end loop;
    l_html := l_html || '</div></div>';

    l_html := l_html || q'~<script>
(function(){
  var root=document.currentScript.closest('.df-wrap');
  if(!root){return;}
  function activate(key){
    root.querySelectorAll('[data-df-tab]').forEach(function(t){t.classList.toggle('active',t.getAttribute('data-df-tab')===key);});
    root.querySelectorAll('[data-df-panel]').forEach(function(p){p.classList.toggle('active',p.getAttribute('data-df-panel')===key);});
  }
  root.querySelectorAll('[data-df-tab]').forEach(function(tab){
    tab.addEventListener('click',function(){
      var key=tab.getAttribute('data-df-tab');
      activate(key);
      if(window.history && window.history.replaceState){window.history.replaceState(null,'','#df-'+key);}
    });
  });
  var initial=(window.location.hash||'#df-designer').replace('#df-','');
  if(root.querySelector('[data-df-panel="'+initial+'"]')){activate(initial);}
  var catalogSearch=root.querySelector('.df-catalog-search');
  if(catalogSearch){
    catalogSearch.addEventListener('input',function(){
      var q=(catalogSearch.value||'').toLowerCase();
      root.querySelectorAll('.df-catalog-row').forEach(function(row){
        row.style.display=row.textContent.toLowerCase().indexOf(q)>=0?'':'none';
      });
    });
  }
})();
</script></section>~';

    return l_html;
  end render;

  function render_canvas return clob is
    l_html clob;
    l_nodes number;
    l_edges number;
    l_props varchar2(1000);
  begin
    select count(*) into l_nodes from ggadmin.fabric_node;
    select count(*) into l_edges from ggadmin.fabric_edge;

    l_html := to_clob(q'~<style>
.dfc-wrap{--ink:#172033;--muted:#64748b;--line:#d8e1eb;--soft:#f8fafc;--blue:#1f6feb;--green:#22c55e;--orange:#f59e0b;color:var(--ink)}
.dfc-wrap *{box-sizing:border-box}
.dfc-shell{border:1px solid var(--line);border-radius:8px;background:#fff;overflow:hidden}
.dfc-top{display:flex;align-items:center;justify-content:space-between;border-bottom:1px solid #e5e7eb;padding:12px 16px;background:#fff}
.dfc-title{font-size:19px;font-weight:800}
.dfc-sub{display:flex;gap:8px;margin-top:4px;align-items:center;color:var(--muted);font-size:12px}
.dfc-chip{border-radius:999px;background:#e0f2fe;color:#075985;padding:3px 8px;font-weight:800;font-size:11px}
.dfc-chip.saved{background:#dcfce7;color:#166534}
.dfc-toolbar{height:44px;display:flex;align-items:center;gap:8px;border-bottom:1px solid #e5e7eb;background:#fafafa;padding:6px 14px;flex-wrap:wrap}
.dfc-tool{border:1px solid #d1d5db;border-radius:6px;background:#fff;padding:7px 10px;font-size:12px;font-weight:700;color:#111827}
.dfc-tool.ghost{color:#94a3b8}
.dfc-layout{display:grid;grid-template-columns:250px minmax(780px,1fr);min-height:650px}
.dfc-palette{border-right:1px solid #e5e7eb;background:#fbfbfc;display:flex;flex-direction:column}
.dfc-palette-head{padding:12px 14px;font-weight:800;border-bottom:1px solid #e5e7eb}
.dfc-search{margin:10px;border:1px solid #d8e1eb;border-radius:6px;background:#fff;padding:8px 10px;color:#64748b;font-size:12px}
.dfc-palette-tabs{display:flex;gap:5px;padding:0 10px 10px}
.dfc-palette-tab{flex:1;border:1px solid #e5e7eb;border-radius:6px;background:#fff;padding:6px;text-align:center;font-size:12px}
.dfc-palette-tab.active{background:#111827;color:#fff}
.dfc-asset-list{padding:0 10px 14px;overflow:auto}
.dfc-asset{display:grid;grid-template-columns:30px 1fr;gap:9px;align-items:center;border:1px solid #e5e7eb;border-left:3px solid #a855f7;border-radius:6px;background:#fff;padding:8px;margin-bottom:8px;cursor:grab}
.dfc-asset-icon{width:28px;height:28px;border-radius:6px;background:#f3e8ff;color:#7c3aed;display:flex;align-items:center;justify-content:center;font-weight:900}
.dfc-asset-name{font-size:12px;font-weight:800;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.dfc-asset-desc{font-size:11px;color:#64748b;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.dfc-canvas-wrap{position:relative;background:#f8fafc;overflow:auto}
.dfc-canvas{position:relative;width:1420px;height:650px;background:#fff;background-image:linear-gradient(#f1f5f9 1px,transparent 1px),linear-gradient(90deg,#f1f5f9 1px,transparent 1px);background-size:28px 28px}
.dfc-lines{position:absolute;left:0;top:0;width:1420px;height:650px;pointer-events:none}
.dfc-node{position:absolute;width:154px;min-height:58px;border:2px solid #cbd5e1;border-radius:7px;background:#fff;padding:8px 10px;box-shadow:0 2px 5px rgba(15,23,42,.06);cursor:pointer}
.dfc-node.source,.dfc-node.trail,.dfc-node.product{border-color:#22c55e}
.dfc-node.process,.dfc-node.stream{border-color:#f59e0b}
.dfc-node.offline{border-style:dashed;opacity:.72}
.dfc-node.selected{outline:4px solid rgba(31,111,235,.18);box-shadow:0 0 0 2px #1f6feb,0 8px 20px rgba(15,23,42,.12)}
.dfc-asset.selected{outline:2px solid #1f6feb;background:#eff6ff}
.dfc-node-title{font-size:12px;font-weight:900;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.dfc-node-meta{font-size:10px;color:#64748b;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;margin-top:2px}
.dfc-port{position:absolute;right:-6px;top:50%;width:10px;height:10px;margin-top:-5px;border-radius:50%;background:#fff;border:2px solid currentColor}
.dfc-port.in{left:-6px;right:auto}
.dfc-status{display:inline-block;margin-top:5px;border-radius:999px;padding:2px 6px;font-size:9px;font-weight:900}
.dfc-status.active{background:#dcfce7;color:#166534}
.dfc-status.design{background:#fef3c7;color:#92400e}
.dfc-status.offline{background:#fee2e2;color:#991b1b}
.dfc-side-panel{position:absolute;right:18px;top:18px;width:270px;border:1px solid #d8e1eb;border-radius:8px;background:rgba(255,255,255,.96);box-shadow:0 8px 24px rgba(15,23,42,.1);padding:12px}
.dfc-side-panel h3{font-size:14px;margin:0 0 8px}
.dfc-side-panel p{font-size:12px;color:#64748b;line-height:1.4;margin:0 0 10px}
.dfc-field{border-top:1px solid #edf2f7;padding-top:8px;margin-top:8px}
.dfc-field-label{font-size:10px;font-weight:900;color:#64748b;text-transform:uppercase}
.dfc-field-value{font-size:12px;font-weight:800;color:#172033;margin-top:2px;word-break:break-word}
.dfc-hint{font-size:11px;color:#64748b;line-height:1.35;margin-top:8px}
.dfc-action{display:grid;grid-template-columns:1fr 1fr;gap:6px;margin-top:10px}
.dfc-action button{border:1px solid #d1d5db;border-radius:6px;background:#fff;padding:7px 8px;font-size:11px;font-weight:800}
.dfc-toast{margin-top:8px;border-radius:6px;background:#ecfdf5;color:#166534;padding:7px 8px;font-size:11px;font-weight:800;display:none}
.dfc-mobile-note{display:none;color:#64748b;padding:8px 10px;font-size:12px}@media(max-width:1100px){.dfc-layout{grid-template-columns:1fr}
.dfc-palette{display:none}
.dfc-canvas{width:1100px}
.dfc-lines{width:1100px}
.dfc-mobile-note{display:block}}
</style><section class="dfc-wrap">~');

    l_html := l_html || '<div class="dfc-shell"><div class="dfc-top"><div><div class="dfc-title">insurance-fabric-split-pipeline</div><div class="dfc-sub"><span class="dfc-chip">OGG</span><span class="dfc-chip saved">Saved</span><span>' || to_char(l_nodes) || ' nodes · ' || to_char(l_edges) || ' edges</span></div></div><button type="button" class="dfc-tool">AI Pipeline Designer</button></div><div class="dfc-toolbar"><button type="button" class="dfc-tool">Undo</button><button type="button" class="dfc-tool ghost">Redo</button><button type="button" class="dfc-tool">DSL / JSON</button><button type="button" class="dfc-tool">Select</button><button type="button" class="dfc-tool">Pan</button><button type="button" class="dfc-tool">Auto Layout</button><button type="button" class="dfc-tool">Refresh Metadata</button><button type="button" class="dfc-tool">Validate Fabric</button></div><div class="dfc-layout"><aside class="dfc-palette"><div class="dfc-palette-head">Node Palette</div><div class="dfc-search">Search assets...</div><div class="dfc-palette-tabs"><div class="dfc-palette-tab active">Assets</div><div class="dfc-palette-tab">Transform</div></div><div class="dfc-asset-list">';

    for n in (
      select *
        from ggadmin.fabric_node
       where node_type in ('SOURCE_TABLE','OGG_EXTRACT','TRAIL','OGG_REPLICAT','DATA_STREAM','LAKEHOUSE_TABLE','DATA_PRODUCT','DASHBOARD')
       order by layer_no, display_order, node_name
    ) loop
      l_html := l_html || '<div class="dfc-asset" draggable="true" data-node-code="' || h(n.node_code) || '" data-node-name="' || h(n.node_name) || '" data-node-type="' || h(n.node_type) || '" data-node-ref="' || h(n.resource_ref) || '" data-node-desc="' || h(n.description) || '"><div class="dfc-asset-icon">+</div><div><div class="dfc-asset-name">' || h(n.node_name) || '</div><div class="dfc-asset-desc">' || h(n.node_type) || ' on ' || h(n.system_name) || '</div></div></div>';
    end loop;

    l_html := l_html || '</div></aside><main class="dfc-canvas-wrap"><div class="dfc-mobile-note">Canvas가 넓어 가로 스크롤로 확인합니다.</div><div class="dfc-canvas"><svg class="dfc-lines" viewBox="0 0 1420 650" preserveAspectRatio="none"><defs><marker id="dfc-arrow" markerWidth="8" markerHeight="8" refX="7" refY="4" orient="auto"><path d="M0,0 L8,4 L0,8 Z" fill="#64748b"></path></marker></defs><path d="M210 145 C290 145 290 145 370 145" stroke="#64748b" stroke-width="2" fill="none" marker-end="url(#dfc-arrow)"></path><path d="M210 245 C290 245 290 245 370 245" stroke="#64748b" stroke-width="2" fill="none" marker-end="url(#dfc-arrow)"></path><path d="M525 145 C605 145 605 145 685 145" stroke="#64748b" stroke-width="2" fill="none" marker-end="url(#dfc-arrow)"></path><path d="M525 245 C605 245 605 245 685 245" stroke="#64748b" stroke-width="2" fill="none" marker-end="url(#dfc-arrow)"></path><path d="M840 145 C915 145 915 120 995 120" stroke="#64748b" stroke-width="2" fill="none" marker-end="url(#dfc-arrow)"></path><path d="M840 245 C915 245 915 215 995 215" stroke="#64748b" stroke-width="2" fill="none" marker-end="url(#dfc-arrow)"></path><path d="M840 245 C915 245 915 300 995 300" stroke="#64748b" stroke-width="2" fill="none" marker-end="url(#dfc-arrow)"></path><path d="M1150 300 C1215 300 1215 380 1280 380" stroke="#64748b" stroke-width="2" fill="none" marker-end="url(#dfc-arrow)"></path><path d="M1150 380 C1215 380 1215 450 1280 450" stroke="#64748b" stroke-width="2" fill="none" marker-end="url(#dfc-arrow)"></path></svg>';

    for n in (
      select n.*,
             case n.node_code
               when 'SRC_SOE_NORMAL_TABLES' then 55 when 'SRC_SOE_CFUND_DT' then 55 when 'SRC_SOE_OPSTATUS' then 55 when 'SRC_SOE_TOT_AMT' then 55
               when 'OGG_EXTRACT_FC01' then 370 when 'OGG_EXTRACT_FC02' then 370
               when 'OGG_TRAIL_K1' then 685 when 'OGG_TRAIL_K2' then 685
               when 'OGG_REPLICAT_FD01' then 995 when 'OGG_REPLICAT_FD02' then 995 when 'OGG_REPLICAT_FD03' then 995 when 'OGG_DATA_STREAM_DS_LAKE' then 995
               when 'ICEBERG_BRONZE_CFUND' then 1280 when 'ICEBERG_SILVER_ACTIVITY' then 1280 when 'ICEBERG_GOLD_ACTION' then 1280 when 'DASHBOARD_GOLD_CHANNEL' then 1280
               else 55
             end x_pos,
             case n.node_code
               when 'SRC_SOE_NORMAL_TABLES' then 115 when 'SRC_SOE_CFUND_DT' then 215 when 'SRC_SOE_OPSTATUS' then 315 when 'SRC_SOE_TOT_AMT' then 415
               when 'OGG_EXTRACT_FC01' then 115 when 'OGG_EXTRACT_FC02' then 215
               when 'OGG_TRAIL_K1' then 115 when 'OGG_TRAIL_K2' then 215
               when 'OGG_REPLICAT_FD01' then 90 when 'OGG_REPLICAT_FD02' then 185 when 'OGG_REPLICAT_FD03' then 270 when 'OGG_DATA_STREAM_DS_LAKE' then 355
               when 'ICEBERG_BRONZE_CFUND' then 350 when 'ICEBERG_SILVER_ACTIVITY' then 430 when 'ICEBERG_GOLD_ACTION' then 510 when 'DASHBOARD_GOLD_CHANNEL' then 590
               else 520
             end y_pos
        from ggadmin.fabric_node n
       where n.node_code in ('SRC_SOE_NORMAL_TABLES','SRC_SOE_CFUND_DT','SRC_SOE_OPSTATUS','SRC_SOE_TOT_AMT','OGG_EXTRACT_FC01','OGG_EXTRACT_FC02','OGG_TRAIL_K1','OGG_TRAIL_K2','OGG_REPLICAT_FD01','OGG_REPLICAT_FD02','OGG_REPLICAT_FD03','OGG_DATA_STREAM_DS_LAKE','ICEBERG_BRONZE_CFUND','ICEBERG_SILVER_ACTIVITY','ICEBERG_GOLD_ACTION','DASHBOARD_GOLD_CHANNEL')
       order by x_pos, y_pos
    ) loop
      l_props := node_properties(n.node_code);
      l_html := l_html || '<div class="dfc-node ' ||
        case when n.node_type in ('SOURCE_TABLE','TRAIL','LAKEHOUSE_TABLE','DATA_PRODUCT','DASHBOARD') then 'source' when n.node_type in ('OGG_EXTRACT','OGG_REPLICAT') then 'process' when n.node_type = 'DATA_STREAM' then 'stream' else 'product' end ||
        case when n.status = 'OFFLINE' then ' offline' end ||
        '" data-node-code="' || h(n.node_code) || '" data-node-name="' || h(n.node_name) || '" data-node-type="' || h(n.node_type) || '" data-node-ref="' || h(n.resource_ref) || '" data-node-desc="' || h(n.description) ||
        '" style="left:' || to_char(n.x_pos) || 'px;top:' || to_char(n.y_pos) || 'px"><span class="dfc-port in"></span><span class="dfc-port"></span><div class="dfc-node-title">' || h(n.node_name) || '</div><div class="dfc-node-meta">' || h(n.resource_ref) || '</div>' ||
        case when l_props is not null then '<div class="dfc-node-meta">' || h(l_props) || '</div>' end ||
        '<span class="dfc-status ' || lower(n.status) || '">' || h(n.status) || '</span></div>';
    end loop;

    l_html := l_html || q'~<aside class="dfc-side-panel"><h3>Connection Workbench</h3><p>Palette 또는 canvas node를 선택한 뒤 From/To를 지정하면 연결 후보와 metadata refresh 흐름을 확인합니다.</p><div class="dfc-field"><div class="dfc-field-label">Selected</div><div class="dfc-field-value" id="dfc-selected">none</div></div><div class="dfc-field"><div class="dfc-field-label">From</div><div class="dfc-field-value" id="dfc-from">not selected</div></div><div class="dfc-field"><div class="dfc-field-label">To</div><div class="dfc-field-value" id="dfc-to">not selected</div></div><div class="dfc-hint" id="dfc-preview">캔버스 node를 클릭하면 From, 다음 node를 클릭하면 To로 지정됩니다.</div><div class="dfc-action"><button type="button" id="dfc-create-link">Create Link</button><button type="button" id="dfc-inspect">Inspect PRM</button><button type="button" id="dfc-dict">Read Dictionary</button><button type="button" id="dfc-refresh">Refresh</button></div><div class="dfc-toast" id="dfc-toast"></div></aside></div></main></div></div>
<script>
(function(){
  var root=document.currentScript.closest('.dfc-wrap');if(!root){return;}
  var from=null,to=null;
  function label(el){return el ? (el.getAttribute('data-node-name') || el.getAttribute('data-node-code')) : 'not selected';}
  function toast(msg){var t=root.querySelector('#dfc-toast');if(!t){return;}t.textContent=msg;t.style.display='block';setTimeout(function(){t.style.display='none';},2600);}
  function selectNode(el){
    root.querySelectorAll('.dfc-node,.dfc-asset').forEach(function(n){n.classList.remove('selected');});
    el.classList.add('selected');
    root.querySelector('#dfc-selected').textContent=label(el);
    if(!from){from=el;}else if(from!==el){to=el;}else{to=null;}
    root.querySelector('#dfc-from').textContent=label(from);
    root.querySelector('#dfc-to').textContent=label(to);
    root.querySelector('#dfc-preview').textContent=from && to ? label(from)+' -> '+label(to)+' 연결 후보입니다.' : '다음 node를 선택하면 연결 후보가 만들어집니다.';
  }
  root.querySelectorAll('.dfc-node,.dfc-asset').forEach(function(el){el.addEventListener('click',function(){selectNode(el);});});
  root.querySelectorAll('.dfc-asset').forEach(function(el){
    el.addEventListener('dragstart',function(ev){ev.dataTransfer.setData('text/plain',JSON.stringify({name:label(el),type:el.getAttribute('data-node-type'),ref:el.getAttribute('data-node-ref')}));});
  });
  var canvas=root.querySelector('.dfc-canvas');
  canvas.addEventListener('dragover',function(ev){ev.preventDefault();});
  canvas.addEventListener('drop',function(ev){
    ev.preventDefault();
    var data={name:'Draft Node',type:'DRAFT',ref:'client-side'};
    try{data=JSON.parse(ev.dataTransfer.getData('text/plain'));}catch(e){}
    var rect=canvas.getBoundingClientRect();
    var node=document.createElement('div');
    node.className='dfc-node process selected';
    node.style.left=(ev.clientX-rect.left+canvas.scrollLeft)+'px';
    node.style.top=(ev.clientY-rect.top+canvas.scrollTop)+'px';
    node.setAttribute('data-node-name',data.name);
    node.setAttribute('data-node-type',data.type);
    node.setAttribute('data-node-ref',data.ref);
    node.innerHTML='<span class="dfc-port in"></span><span class="dfc-port"></span><div class="dfc-node-title">'+data.name+'</div><div class="dfc-node-meta">'+data.type+'</div><span class="dfc-status design">DRAFT</span>';
    canvas.appendChild(node);
    node.addEventListener('click',function(){selectNode(node);});
    selectNode(node);
    toast('Canvas에 draft node를 배치했습니다. 저장은 다음 단계에서 연결합니다.');
  });
  root.querySelector('#dfc-create-link').addEventListener('click',function(){toast(from && to ? label(from)+' -> '+label(to)+' 연결 후보 생성' : 'From/To node를 먼저 선택하세요.');});
  root.querySelector('#dfc-inspect').addEventListener('click',function(){toast('선택 node의 GoldenGate parameter mapping을 조회하는 자리입니다.');});
  root.querySelector('#dfc-dict').addEventListener('click',function(){toast('DB dictionary COMMENT metadata를 읽어 node 설명을 보강합니다.');});
  root.querySelector('#dfc-refresh').addEventListener('click',function(){toast('metadata refresh workflow를 실행하는 자리입니다.');});
})();
</script></section>~';

    return l_html;
  end render_canvas;

  function render_canvas_design return clob is
    l_html clob;
    l_props varchar2(1000);
    l_history clob;
    l_create_candidates clob;
    l_alias_options clob;
    l_trail_options clob;

    function prop_value(p_node_code varchar2, p_property_name varchar2) return varchar2 is
      l_value varchar2(1000);
    begin
      select property_value
        into l_value
        from ggadmin.fabric_node_property
       where node_code = p_node_code
         and property_name = p_property_name;

      return l_value;
    exception
      when no_data_found then
        return null;
    end;

    function detail_text(p_node_code varchar2) return varchar2 is
      l_count varchar2(100);
      l_trail varchar2(100);
    begin
      if p_node_code in ('OGG_EXTRACT_FC01','OGG_EXTRACT_FC02') then
        l_count := prop_value(p_node_code, 'table_count');
        l_trail := prop_value(p_node_code, 'trail');
        if l_count is not null then
          return case p_node_code
            when 'OGG_EXTRACT_FC01' then 'Extract FC01 | TABLE count: ' || l_count || ' | Trail: ' || nvl(l_trail, 'k1') || ' | Lane: normal business tables | Parameter style: explicit TABLE entries'
            else 'Extract FC02 | TABLE count: ' || l_count || ' | Trail: ' || nvl(l_trail, 'k2') || ' | Lane: heavy/batch-like activity | Downstream: FD02, FD03, DS_LAKE'
          end;
        end if;
      elsif p_node_code in ('OGG_REPLICAT_FD01','OGG_REPLICAT_FD02','OGG_REPLICAT_FD03') then
        l_count := prop_value(p_node_code, 'map_count');
        if l_count is not null then
          return case p_node_code
            when 'OGG_REPLICAT_FD01' then 'Replicat FD01 | MAP count: ' || l_count || ' | Applies normal business tables from k1 | Heavy tables are intentionally excluded'
            when 'OGG_REPLICAT_FD02' then 'Replicat FD02 | MAP count: ' || l_count || ' | Applies the high-volume fund activity lane from k2'
            else 'Replicat FD03 | MAP count: ' || l_count || ' | Applies operational status and amount summary lane from k2'
          end;
        end if;
      end if;

      return case p_node_code
        when 'OGG_EXTRACT_FC01' then 'Extract FC01 | TABLE count: 28 | Lane: normal business tables | Heavy tables are intentionally excluded | Parameter style: explicit TABLE entries'
        when 'OGG_EXTRACT_FC02' then 'Extract FC02 | TABLE count: 3 | Lane: heavy/batch-like activity | Downstream: FD02, FD03, DS_LAKE'
        when 'OGG_TRAIL_K1' then 'Trail k1 | Written by: FC01 | Read by: FD01 | Purpose: normal table lane'
        when 'OGG_TRAIL_K2' then 'Trail k2 | Written by: FC02 | Read by: FD02, FD03, Data Stream DS_LAKE | Purpose: heavy table lane'
        when 'OGG_REPLICAT_FD01' then 'Replicat FD01 | MAP count: 28 | Applies normal business tables from k1 | Heavy tables are intentionally excluded'
        when 'OGG_REPLICAT_FD02' then 'Replicat FD02 | MAP count: 1 | Applies the high-volume fund activity lane from k2'
        when 'OGG_REPLICAT_FD03' then 'Replicat FD03 | MAP count: 2 | Applies operational status and amount summary lane from k2'
        when 'OGG_DATA_STREAM_DS_LAKE' then 'Data Stream DS_LAKE | Source trail: k2 | Consumer path: Iceberg writer | Use case: lakehouse Bronze ingestion'
        when 'ICEBERG_BRONZE_CFUND' then 'Bronze table | insurance.ds_cfund_dt_events | Receives CDC events from DS_LAKE when the lakehouse writer is running'
        else 'Select a process, trail, stream, or target node to inspect its metadata.'
      end;
    end;

    function table_text(p_node_code varchar2) return varchar2 is
      l_tables varchar2(1000);
      l_maps varchar2(1000);
    begin
      l_tables := prop_value(p_node_code, 'tables');
      if l_tables is not null then
        return 'TABLE ' || replace(l_tables, ', ', chr(10) || 'TABLE ');
      end if;

      l_maps := prop_value(p_node_code, 'maps');
      if l_maps is not null then
        return 'MAP ' || replace(l_maps, ', ', chr(10) || 'MAP ');
      end if;

      return case p_node_code
        when 'OGG_EXTRACT_FC01' then
          'TABLE SOE.ADDRESS' || chr(10) ||
          'TABLE SOE.ADDRESS_BAK_BEFORE_ENRICH' || chr(10) ||
          'TABLE SOE.ADDRESS_BAK_SEOUL_20261008_125131' || chr(10) ||
          'TABLE SOE.CALL_CENTER_LOG' || chr(10) ||
          'TABLE SOE.CANCELAMT' || chr(10) ||
          'TABLE SOE.CANCELFP' || chr(10) ||
          'TABLE SOE.CFUND_DEPOSIT' || chr(10) ||
          'TABLE SOE.CFUND_RAT' || chr(10) ||
          'TABLE SOE.CFUND_RATIO' || chr(10) ||
          'TABLE SOE.CFUND_RAT_TMP' || chr(10) ||
          'TABLE SOE.CUST_DEP_DT' || chr(10) ||
          'TABLE SOE.CUST_GEN_AMT' || chr(10) ||
          'TABLE SOE.CUST_INFO' || chr(10) ||
          'TABLE SOE.CUST_PR' || chr(10) ||
          'TABLE SOE.EMPLOYEE' || chr(10) ||
          'TABLE SOE.FUNDM' || chr(10) ||
          'TABLE SOE.FUND_PRICE' || chr(10) ||
          'TABLE SOE.HEARTBP' || chr(10) ||
          'TABLE SOE.MSG' || chr(10) ||
          'TABLE SOE.OGG_SYNC_UNIT_TEST' || chr(10) ||
          'TABLE SOE.OPM' || chr(10) ||
          'TABLE SOE.OSA_CANCEL_PREDICTION' || chr(10) ||
          'TABLE SOE.OSA_CANCEL_PREDICTION_GEN' || chr(10) ||
          'TABLE SOE.PRODUCT' || chr(10) ||
          'TABLE SOE.RESERVES_AMT' || chr(10) ||
          'TABLE SOE.SUCCESS_CASE_KNOWLEDGE' || chr(10) ||
          'TABLE SOE.TMP_TRIGGER'
        when 'OGG_EXTRACT_FC02' then
          'TABLE SOE.CFUND_DT' || chr(10) ||
          'TABLE SOE.OPSTATUS' || chr(10) ||
          'TABLE SOE.TOT_AMT'
        when 'OGG_REPLICAT_FD01' then
          '28 explicit MAP entries for normal business tables.' || chr(10) ||
          'SOE.CFUND_DT, SOE.OPSTATUS, SOE.TOT_AMT are split to FD02/FD03.'
        when 'OGG_REPLICAT_FD02' then
          'MAP SOE.CFUND_DT, TARGET SOE.CFUND_DT'
        when 'OGG_REPLICAT_FD03' then
          'MAP SOE.OPSTATUS, TARGET SOE.OPSTATUS' || chr(10) ||
          'MAP SOE.TOT_AMT, TARGET SOE.TOT_AMT'
        when 'OGG_TRAIL_K1' then
          'Writer: Extract FC01' || chr(10) ||
          'Reader: Replicat FD01'
        when 'OGG_TRAIL_K2' then
          'Writer: Extract FC02' || chr(10) ||
          'Readers: Replicat FD02, Replicat FD03, Data Stream DS_LAKE'
        when 'OGG_DATA_STREAM_DS_LAKE' then
          'Source trail: k2' || chr(10) ||
          'Encoding: json' || chr(10) ||
          'QoS: exactlyOnce' || chr(10) ||
          'Consumer: demo_iceberg_writer'
        when 'ICEBERG_BRONZE_CFUND' then
          'Table: insurance.ds_cfund_dt_events' || chr(10) ||
          'Layer: Bronze' || chr(10) ||
          'Source: Data Stream DS_LAKE'
        else 'No table detail is available for this node.'
      end;
    end;
  begin
    l_history := to_clob('');
    l_create_candidates := to_clob('');
    l_alias_options := to_clob('');
    l_trail_options := to_clob('');
    for r in (
      select request_id,
             request_status,
             process_name,
             process_type,
             source_table,
             nvl(target_table, '-') target_table,
             dbms_lob.substr(change_sql, 240, 1) change_sql,
             to_char(requested_at, 'YYYY-MM-DD HH24:MI:SS') requested_at,
             nvl(requested_by, '-') requested_by
        from ggadmin.fabric_change_request
       order by request_id desc
       fetch first 20 rows only
    ) loop
      l_history := l_history ||
        '<div class="dfd-history-row"><div><strong>#' || h(r.request_id) || ' ' || h(r.request_status) || '</strong><span>' ||
        h(r.process_name || ' · ' || r.source_table || ' · ' || r.requested_at) ||
        '</span></div><small>' || h(r.change_sql) || '</small></div>';
    end loop;
    if dbms_lob.getlength(l_history) = 0 then
      l_history := to_clob('<div class="dfd-empty">아직 적용된 fabric 변경 이력이 없습니다.</div>');
    end if;

    for t in (
      select c.owner_name || '.' || c.table_name table_ref,
             min(nvl(c.column_comment, c.table_name)) keep (dense_rank first order by c.column_id nulls last) sample_comment,
             count(*) column_count
        from ggadmin.fabric_table_column c
       where c.owner_name = 'SOE'
       group by c.owner_name, c.table_name
       order by c.owner_name, c.table_name
    ) loop
      l_create_candidates := l_create_candidates ||
        '<button type="button" class="dfd-create-table" data-table="' || h(t.table_ref) || '">' ||
        '<input type="checkbox" class="dfd-create-table-check" tabindex="-1" aria-label="' || h(t.table_ref) || '">' ||
        '<span>' || h(t.table_ref) || '</span><small>' || h(t.column_count || ' columns') || '</small></button>';
    end loop;

    for a in (
      select distinct property_value alias_name
        from ggadmin.fabric_node_property
       where property_name = 'useridalias'
         and property_value is not null
      union
      select 'src_ogg' from dual
      order by 1
    ) loop
      l_alias_options := l_alias_options || '<option value="' || h(a.alias_name) || '">' || h(a.alias_name) || '</option>';
    end loop;

    for tr in (
      select resource_ref trail_name
        from ggadmin.fabric_node
       where node_type = 'TRAIL'
         and resource_ref is not null
       order by display_order, resource_ref
    ) loop
      l_trail_options := l_trail_options || '<option value="' || h(tr.trail_name) || '">' || h(tr.trail_name) || '</option>';
    end loop;

    l_html := to_clob(q'~<style>
.dfd-wrap{--ink:#172033;--muted:#64748b;--line:#d8e1eb;--soft:#f8fafc;--blue:#1f6feb;--green:#22c55e;--orange:#f59e0b;color:var(--ink)}
.dfd-wrap *{box-sizing:border-box}
.dfd-shell{border:1px solid var(--line);border-radius:8px;background:#fff;overflow:hidden}
.dfd-head{display:flex;align-items:center;justify-content:space-between;padding:14px 16px;border-bottom:1px solid #e5e7eb}
.dfd-title{font-size:20px;font-weight:900}
.dfd-sub{margin-top:4px;color:var(--muted);font-size:12px}
.dfd-toolbar{min-height:42px;display:flex;gap:8px;align-items:center;flex-wrap:wrap;padding:6px 14px;border-bottom:1px solid #e5e7eb;background:#fafafa}
.dfd-tool{border:1px solid #d1d5db;border-radius:6px;background:#fff;padding:7px 10px;font-size:12px;font-weight:800}
.dfd-tool.primary{border-color:#1f6feb;background:#1f6feb;color:#fff}
.dfd-layout{display:grid;grid-template-columns:minmax(780px,1fr) 320px;min-height:620px}
.dfd-canvas-wrap{overflow:auto;background:#f8fafc}
.dfd-canvas{position:relative;width:1180px;height:620px;background:#fff;background-image:linear-gradient(#f1f5f9 1px,transparent 1px),linear-gradient(90deg,#f1f5f9 1px,transparent 1px);background-size:28px 28px}
.dfd-lines{position:absolute;left:0;top:0;width:1180px;height:620px;pointer-events:none}
.dfd-node{position:absolute;width:168px;min-height:70px;border:2px solid #cbd5e1;border-radius:8px;background:#fff;padding:10px;box-shadow:0 2px 5px rgba(15,23,42,.06);cursor:pointer}
.dfd-node.extract,.dfd-node.replicat,.dfd-node.stream{border-color:#f59e0b}
.dfd-node.trail,.dfd-node.target{border-color:#22c55e}
.dfd-node.offline{border-style:dashed;opacity:.72}
.dfd-node.selected{outline:4px solid rgba(31,111,235,.18);box-shadow:0 0 0 2px #1f6feb,0 8px 20px rgba(15,23,42,.12)}
.dfd-node-title{font-size:13px;font-weight:900;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.dfd-node-meta{font-size:11px;color:#64748b;line-height:1.3;margin-top:4px}
.dfd-port{position:absolute;right:-6px;top:50%;width:10px;height:10px;margin-top:-5px;border-radius:50%;background:#fff;border:2px solid currentColor}
.dfd-port.in{left:-6px;right:auto}
.dfd-status{display:inline-block;margin-top:7px;border-radius:999px;padding:3px 7px;font-size:9px;font-weight:900}
.dfd-status.active{background:#dcfce7;color:#166534}
.dfd-status.offline{background:#fee2e2;color:#991b1b}
.dfd-side{border-left:1px solid #e5e7eb;background:#fff;padding:16px}
.dfd-side h3{margin:0 0 8px;font-size:16px}
.dfd-note{font-size:12px;color:#64748b;line-height:1.45;margin-bottom:12px}
.dfd-field{border-top:1px solid #edf2f7;padding-top:10px;margin-top:10px}
.dfd-label{font-size:10px;font-weight:900;color:#64748b;text-transform:uppercase}
.dfd-value{font-size:13px;font-weight:800;margin-top:4px;word-break:break-word}
.dfd-detail{font-size:12px;line-height:1.45;color:#334155;margin-top:6px;white-space:pre-line}
.dfd-pill{display:inline-block;border-radius:999px;background:#e0f2fe;color:#075985;font-size:11px;font-weight:800;padding:4px 8px;margin:4px 4px 0 0}
.dfd-actions{display:grid;grid-template-columns:1fr 1fr;gap:8px;margin-top:12px}
.dfd-actions button{border:1px solid #d1d5db;border-radius:6px;background:#fff;padding:8px;font-size:12px;font-weight:800}
.dfd-actions .danger{display:none;grid-column:1/-1;border-color:#fca5a5;color:#b91c1c}
.dfd-actions .danger.active{display:block}
.dfd-actions .danger:hover{background:#fef2f2}
.dfd-view-button{grid-column:1/-1;color:#b91c1c}
.dfd-modal-backdrop{display:none;position:fixed;inset:0;background:rgba(15,23,42,.34);z-index:9100;padding:64px 18px}
.dfd-modal-backdrop.active{display:grid;place-items:start center}
.dfd-modal{width:min(760px,100%);max-height:78vh;border:1px solid #d8e1eb;border-radius:8px;background:#fff;box-shadow:0 24px 60px rgba(15,23,42,.25);overflow:hidden}
.dfd-modal-head{display:flex;align-items:center;justify-content:space-between;gap:12px;padding:13px 16px;border-bottom:1px solid #e5e7eb}
.dfd-modal-title{font-size:16px;font-weight:900}
.dfd-modal-sub{margin-top:3px;font-size:12px;color:#64748b}
.dfd-close{border:1px solid #d1d5db;border-radius:6px;background:#fff;padding:6px 10px;font-size:12px;font-weight:900}
.dfd-table-search{padding:14px 16px 10px;background:#f8fafc;border-bottom:1px solid #e5e7eb}
.dfd-table-search input{width:100%;border:1px solid #cbd5e1;border-radius:7px;padding:10px 12px;font-size:13px}
.dfd-table-list{display:grid;gap:8px;color:#334155;max-height:52vh;overflow:auto;padding:12px 16px 16px;background:#f8fafc}
.dfd-table-row,.dfd-check-row,.dfd-history-row{display:flex;justify-content:space-between;gap:12px;text-align:left;border:1px solid #dbe4ef;border-radius:7px;background:#fff;padding:10px 12px}
.dfd-create-steps{display:grid;grid-template-columns:repeat(4,1fr);gap:8px;padding:12px 16px;background:#f8fafc;border-bottom:1px solid #e5e7eb}
.dfd-create-step{border:1px solid #dbe4ef;border-radius:7px;background:#fff;padding:9px;font-size:12px;font-weight:900}
.dfd-create-step.active{border-color:#1f6feb;box-shadow:0 0 0 3px rgba(31,111,235,.12)}
.dfd-create-body{padding:14px 16px;background:#f8fafc;max-height:58vh;overflow:auto}
.dfd-create-panel{display:none}
.dfd-create-panel.active{display:block}
.dfd-create-grid{display:grid;grid-template-columns:1fr 1fr;gap:12px}
.dfd-create-field{display:grid;gap:5px}
.dfd-create-field.full{grid-column:1/-1}
.dfd-create-field label{font-size:11px;font-weight:900;color:#64748b;text-transform:uppercase}
.dfd-create-field input,.dfd-create-field select,.dfd-create-field textarea{width:100%;border:1px solid #cbd5e1;border-radius:7px;background:#fff;padding:10px 12px;font-size:13px}
.dfd-create-field textarea{min-height:180px;font-family:monospace}
.dfd-create-table-list{display:grid;gap:8px;max-height:360px;overflow:auto}
.dfd-create-table{display:grid;grid-template-columns:22px 1fr auto;align-items:center;gap:10px;text-align:left;border:1px solid #dbe4ef;border-radius:7px;background:#fff;padding:10px;cursor:pointer}
.dfd-create-table input{width:16px;height:16px;margin:0;accent-color:#1f6feb;pointer-events:none}
.dfd-create-table span{font-size:13px;font-weight:900}
.dfd-create-table small{font-size:11px;color:#64748b}
.dfd-create-table.selected{border-color:#1f6feb;background:#eff6ff}
.dfd-create-preview{border:1px solid #dbe4ef;border-radius:7px;background:#fff;padding:11px;font-size:12px;line-height:1.45;white-space:pre-line;color:#334155}
.dfd-create-preview.editable textarea{min-height:230px}
.dfd-create-actions{display:flex;gap:8px;justify-content:flex-end;padding:12px 16px;border-top:1px solid #e5e7eb;background:#fff}
.dfd-command-row{display:grid;grid-template-columns:1fr 76px;gap:10px;align-items:start;border:1px solid #dbe4ef;border-radius:7px;background:#fff;padding:10px;margin-bottom:8px}
.dfd-command-row code{font-size:12px;white-space:pre-wrap}
.dfd-command-status{border-radius:999px;padding:4px 7px;text-align:center;font-size:10px;font-weight:900;background:#e5e7eb;color:#374151}
.dfd-command-status.ok{background:#dcfce7;color:#166534}
.dfd-command-status.fail{background:#fee2e2;color:#991b1b}
.dfd-table-row span{font-size:13px;font-weight:900}
.dfd-table-row small{font-size:11px;color:#64748b;white-space:nowrap}
.dfd-check-row{display:block;line-height:1.45}
.dfd-check-row strong,.dfd-history-row strong{display:block;font-size:13px}
.dfd-check-row span,.dfd-history-row span{display:block;margin-top:3px;font-size:12px;color:#64748b}
.dfd-check-row.ok{border-color:#86efac;background:#f0fdf4}
.dfd-check-row.warn{border-color:#fbbf24;background:#fffbeb}
.dfd-check-row.fail{border-color:#fca5a5;background:#fef2f2}
.dfd-history-row{display:block}
.dfd-history-row small{display:block;margin-top:7px;font-size:11px;color:#334155;white-space:pre-wrap}
.dfd-empty{font-size:12px;color:#64748b;padding:10px}
.dfd-toast{display:none;margin-top:10px;border-radius:6px;background:#ecfdf5;color:#166534;padding:8px;font-size:12px;font-weight:800}@media(max-width:1100px){.dfd-layout{grid-template-columns:1fr}
.dfd-side{border-left:none;border-top:1px solid #e5e7eb}
.dfd-canvas{width:1000px}}
</style><section class="dfd-wrap"><div class="dfd-shell"><div class="dfd-head"><div><div class="dfd-title">Data Fabric Canvas Design</div><div class="dfd-sub">GoldenGate parameter와 runtime metadata에서 발견한 process topology를 보여줍니다. TABLE/MAP 상세는 선택한 node의 Workbench에서 확인합니다.</div></div><button type="button" class="dfd-tool" id="dfd-impact-top">Impact Analyzer</button></div><div class="dfd-toolbar"><button type="button" class="dfd-tool">Select</button><button type="button" class="dfd-tool">Auto Layout</button><button type="button" class="dfd-tool primary" id="dfd-refresh">Refresh Metadata</button><button type="button" class="dfd-tool" id="dfd-create-lane">Create Lane</button><button type="button" class="dfd-tool" id="dfd-create-replicat-lane">Create Replicat Lane</button><button type="button" class="dfd-tool">Set Table</button><button type="button" class="dfd-tool" id="dfd-validate">Validate Fabric</button><button type="button" class="dfd-tool" id="dfd-history">Change History</button></div><div class="dfd-layout"><main class="dfd-canvas-wrap"><div class="dfd-canvas"><svg class="dfd-lines" viewBox="0 0 1180 620" preserveAspectRatio="none"><defs><marker id="dfd-arrow" markerWidth="8" markerHeight="8" refX="7" refY="4" orient="auto"><path d="M0,0 L8,4 L0,8 Z" fill="#64748b"></path></marker></defs></svg>~');

    for n in (
      select n.*,
             case
               when n.node_type = 'OGG_EXTRACT' then 52
               when n.node_type = 'TRAIL' then 380
               when n.node_type in ('OGG_REPLICAT','DATA_STREAM') then 710
               when n.node_type in ('LAKEHOUSE_TABLE','DATA_PRODUCT','DASHBOARD') then 1020
               else 52
             end x_pos,
             70 + (row_number() over (
               partition by case
                 when n.node_type = 'OGG_EXTRACT' then 2
                 when n.node_type = 'TRAIL' then 3
                 when n.node_type in ('OGG_REPLICAT','DATA_STREAM') then 4
                 when n.node_type in ('LAKEHOUSE_TABLE','DATA_PRODUCT','DASHBOARD') then 5
                 else 1
               end
               order by n.display_order, n.node_name
             ) - 1) * 95 y_pos
       from ggadmin.fabric_node n
       where n.node_type in ('OGG_EXTRACT','TRAIL','OGG_REPLICAT','DATA_STREAM','LAKEHOUSE_TABLE')
         and (n.node_code like 'OGG\_%' escape '\' or n.node_code = 'ICEBERG_BRONZE_CFUND')
         and n.status in ('ACTIVE','OFFLINE')
       order by x_pos, y_pos
    ) loop
      l_props := node_properties(n.node_code);
      l_html := l_html || '<div class="dfd-node ' ||
        case when n.node_type = 'OGG_EXTRACT' then 'extract' when n.node_type = 'OGG_REPLICAT' then 'replicat' when n.node_type = 'TRAIL' then 'trail' when n.node_type = 'DATA_STREAM' then 'stream' else 'target' end ||
        case when n.status = 'OFFLINE' then ' offline' end ||
        '" data-node-code="' || h(n.node_code) || '" data-node-name="' || h(n.node_name) || '" data-node-type="' || h(n.node_type) || '" data-node-ref="' || h(n.resource_ref) || '" data-node-alias="' || h(prop_value(n.node_code, 'useridalias')) || '" data-node-trail="' || h(prop_value(n.node_code, 'trail')) || '" data-node-detail="' || h(detail_text(n.node_code)) || '" data-node-tables="' || h(table_text(n.node_code)) ||
        '" style="left:' || to_char(n.x_pos) || 'px;top:' || to_char(n.y_pos) || 'px"><span class="dfd-port in"></span><span class="dfd-port"></span><div class="dfd-node-title">' || h(n.node_name) || '</div><div class="dfd-node-meta">' || h(n.resource_ref) || '</div>' ||
        case when l_props is not null then '<div class="dfd-node-meta">' || h(l_props) || '</div>' end ||
        '<span class="dfd-status ' || lower(n.status) || '">' || h(n.status) || '</span></div>';
    end loop;

    for e in (
      select e.edge_code, e.from_node_code, e.to_node_code, e.edge_type, e.mapping_ref, e.status, e.description
        from ggadmin.fabric_edge e
       where (e.edge_code like 'DISC\_%' escape '\'
         or e.edge_type in ('WRITE_TRAIL','APPLY')
          or e.edge_code in ('E_TRAIL_K2_TO_DS_LAKE','E_DS_LAKE_TO_BRONZE'))
         and e.status in ('ACTIVE','OFFLINE')
         and exists (select 1 from ggadmin.fabric_node f where f.node_code = e.from_node_code)
         and exists (select 1 from ggadmin.fabric_node t where t.node_code = e.to_node_code)
       order by e.edge_code
    ) loop
      l_html := l_html || '<span class="dfd-edge-data" data-from="' || h(e.from_node_code) || '" data-to="' || h(e.to_node_code) || '" data-edge-type="' || h(e.edge_type) || '" data-ref="' || h(e.mapping_ref) || '" data-status="' || h(e.status) || '" data-desc="' || h(e.description) || '" style="display:none"></span>';
    end loop;

    l_html := l_html || q'~</div></main><aside class="dfd-side"><h3 id="dfd-title">Select a node</h3><div class="dfd-note">Canvas는 process, trail, stream, target 중심으로 유지합니다. TABLE/MAP 목록은 View Tables 팝업에서 확인합니다.</div><div class="dfd-field"><div class="dfd-label">Type</div><div class="dfd-value" id="dfd-type">-</div></div><div class="dfd-field"><div class="dfd-label">Reference</div><div class="dfd-value" id="dfd-ref">-</div></div><div class="dfd-field"><div class="dfd-label">Process Summary</div><div class="dfd-detail" id="dfd-detail">Extract 또는 Replicat node를 선택하세요.</div></div><div class="dfd-field"><div class="dfd-label">Analysis</div><span class="dfd-pill">Complexity: Medium</span><span class="dfd-pill">Metadata-driven</span><span class="dfd-pill">Set table guarded</span></div><div class="dfd-actions"><button type="button" id="dfd-impact">Estimate Impact</button><button type="button" id="dfd-pin">Set Table</button><button type="button" id="dfd-prm">Inspect PRM</button><button type="button" id="dfd-remove">Remove Table</button><button type="button" id="dfd-move">Move Table</button><button type="button" id="dfd-drop-process" class="danger">Drop Process</button><button type="button" id="dfd-view-tables" class="dfd-view-button">View Tables</button></div><div class="dfd-toast" id="dfd-toast"></div></aside></div></div><div class="dfd-modal-backdrop" id="dfd-table-modal" role="dialog" aria-modal="true" aria-labelledby="dfd-table-title"><div class="dfd-modal"><div class="dfd-modal-head"><div><div class="dfd-modal-title" id="dfd-table-title">TABLE / MAP List</div><div class="dfd-modal-sub" id="dfd-table-sub">Select a node first.</div></div><button type="button" class="dfd-close" id="dfd-close-tables">Close</button></div><div class="dfd-table-search"><input id="dfd-table-filter" placeholder="예: cfund, opstatus, tot"></div><div class="dfd-table-list" id="dfd-table-list"></div></div></div><div class="dfd-modal-backdrop" id="dfd-create-modal" role="dialog" aria-modal="true" aria-labelledby="dfd-create-title"><div class="dfd-modal"><div class="dfd-modal-head"><div><div class="dfd-modal-title" id="dfd-create-title">Create Extract Lane</div><div class="dfd-modal-sub">GoldenGate에 실제 Extract와 EXTTRAIL을 생성한 뒤 metadata refresh로 Canvas에 반영합니다.</div></div><button type="button" class="dfd-close" id="dfd-close-create">Close</button></div><div class="dfd-create-grid"><div class="dfd-create-field"><label>Extract Name</label><input id="dfd-new-extract" maxlength="8" placeholder="예: FCT1"></div><div class="dfd-create-field"><label>Trail Prefix</label><input id="dfd-new-trail" maxlength="2" placeholder="예: t3"></div><div class="dfd-create-field"><label>USERIDALIAS</label><input id="dfd-new-alias" value="src_ogg"></div><div class="dfd-create-field"><label>Start After Create</label><input id="dfd-new-start" value="Y"></div><div class="dfd-create-field full"><label>TABLE List</label><textarea id="dfd-new-tables" placeholder="SOE.CFUND_DT&#10;SOE.OPSTATUS"></textarea></div><div class="dfd-create-preview" id="dfd-create-preview">Extract 이름, trail prefix, TABLE 목록을 입력하세요.</div><div class="dfd-create-actions"><button type="button" class="dfd-tool" id="dfd-create-cancel">Cancel</button><button type="button" class="dfd-tool primary" id="dfd-create-apply">Apply Create</button></div></div></div></div><div id="dfd-history-data" style="display:none">~' ||
      l_history ||
      q'~</div><div id="dfd-create-candidate-data" style="display:none">~' ||
      l_create_candidates ||
      q'~</div><select id="dfd-create-alias-data" style="display:none">~' ||
      l_alias_options ||
      q'~</select><select id="dfd-create-trail-data" style="display:none">~' ||
      l_trail_options ||
      q'~</select>
<script>
(function(){
  var root=document.currentScript.closest('.dfd-wrap');if(!root){return;}
  var currentTables='', currentNodeCode='', currentNodeType='', currentNodeRef='', currentNodeAlias='', currentNodeTrail='';
  function toast(msg){var t=root.querySelector('#dfd-toast');t.textContent=msg;t.style.display='block';setTimeout(function(){t.style.display='none';},2600);}
  function normalize(text){return (text||'').split(' | ').join('\n');}
  function tableFromLine(line){
    var text=(line||'').trim().replace(/;$/,'');
    var upper=text.toUpperCase();
    if(upper.indexOf('TABLE ')===0){return {kind:'TABLE',name:text.substring(6).trim().toUpperCase()};}
    if(upper.indexOf('MAP ')===0){return {kind:'MAP',name:text.substring(4).split(',')[0].trim().toUpperCase()};}
    if(upper.indexOf('TABLE:')===0){return {kind:'TABLE',name:text.substring(6).trim().toUpperCase()};}
    return text?{kind:'ENTRY',name:text.toUpperCase()}:null;
  }
  function renderTableBrowser(){
    var list=root.querySelector('#dfd-table-list');
    var filter=(root.querySelector('#dfd-table-filter').value||'').toUpperCase();
    var rows=(currentTables||'').split(/\n+/).map(tableFromLine).filter(function(row,i,arr){
      return row&&row.name&&row.name.indexOf(filter)>=0&&arr.findIndex(function(x){return x&&x.name===row.name;})===i;
    });
    if(!rows.length){
      list.innerHTML='<div class="dfd-empty">표시할 TABLE/MAP 항목이 없습니다.</div>';
      return;
    }
    list.innerHTML=rows.map(function(row){
      return '<div class="dfd-table-row"><span>'+row.name+'</span><small>'+row.kind+' mapping</small></div>';
    }).join('');
  }
  function currentNode(){return root.querySelector('.dfd-node.selected');}
  function allNodes(){return Array.prototype.slice.call(root.querySelectorAll('.dfd-node'));}
  function nodeName(node){return node?node.getAttribute('data-node-name'):'';}
  function nodeType(node){return node?node.getAttribute('data-node-type'):'';}
  function nodeCode(node){return node?node.getAttribute('data-node-code'):'';}
  function edgeList(){
    return Array.prototype.slice.call(root.querySelectorAll('.dfd-edge-data')).map(function(e){
      return {from:e.getAttribute('data-from'),to:e.getAttribute('data-to'),type:e.getAttribute('data-edge-type'),ref:e.getAttribute('data-ref')||'',status:e.getAttribute('data-status')||'',desc:e.getAttribute('data-desc')||''};
    });
  }
  function edgeConfidence(edge){
    var ref=(edge.ref||'').toUpperCase();
    if(ref.indexOf('CONFIDENCE=HIGH')>=0){return 'HIGH';}
    if(ref.indexOf('CONFIDENCE=MEDIUM')>=0){return 'MEDIUM';}
    if(ref.indexOf('CONFIDENCE=LOW')>=0){return 'LOW';}
    return edge.type==='APPLY'?'UNKNOWN':'HIGH';
  }
  function connectedNames(edges, side){
    var names=edges.map(function(e){
      var code=side==='from'?e.from:e.to;
      var n=root.querySelector('.dfd-node[data-node-code="'+code+'"]');
      return n?nodeName(n):code;
    }).filter(Boolean);
    return names.length?names.join(', '):'none discovered';
  }
  function drawEdges(){
    var svg=root.querySelector('.dfd-lines');
    if(!svg){return;}
    Array.prototype.slice.call(svg.querySelectorAll('path.dfd-edge-path')).forEach(function(path){path.remove();});
    root.querySelectorAll('.dfd-edge-data').forEach(function(edge){
      var from=root.querySelector('.dfd-node[data-node-code="'+edge.getAttribute('data-from')+'"]');
      var to=root.querySelector('.dfd-node[data-node-code="'+edge.getAttribute('data-to')+'"]');
      if(!from||!to){return;}
      var x1=from.offsetLeft+from.offsetWidth;
      var y1=from.offsetTop+(from.offsetHeight/2);
      var x2=to.offsetLeft;
      var y2=to.offsetTop+(to.offsetHeight/2);
      var mid=Math.max(40,(x2-x1)/2);
      var path=document.createElementNS('http://www.w3.org/2000/svg','path');
      path.setAttribute('class','dfd-edge-path');
      path.setAttribute('d','M '+x1+' '+y1+' C '+(x1+mid)+' '+y1+' '+(x2-mid)+' '+y2+' '+x2+' '+y2);
      path.setAttribute('stroke','#64748b');
      path.setAttribute('stroke-width','2');
      path.setAttribute('fill','none');
      path.setAttribute('marker-end','url(#dfd-arrow)');
      svg.appendChild(path);
    });
  }
  function nodeTables(node){
    return (node?node.getAttribute('data-node-tables'):'').split(/\n+/).map(tableFromLine).filter(function(row,i,arr){
      return row&&row.name&&arr.findIndex(function(x){return x&&x.name===row.name;})===i;
    });
  }
  function openResultModal(title, sub, html, searchable){
    root.querySelector('#dfd-table-title').textContent=title;
    root.querySelector('#dfd-table-sub').textContent=sub||'';
    root.querySelector('#dfd-table-filter').value='';
    root.querySelector('.dfd-table-search').style.display=searchable?'block':'none';
    root.querySelector('#dfd-table-list').innerHTML=html;
    root.querySelector('#dfd-table-modal').classList.add('active');
  }
  function tableSet(nodes, kind){
    var owner={};
    nodes.forEach(function(n){
      nodeTables(n).filter(function(r){return r.kind===kind;}).forEach(function(r){
        if(!owner[r.name]){owner[r.name]=[];}
        owner[r.name].push(nodeName(n));
      });
    });
    return owner;
  }
  function validateFabric(){
    var extracts=allNodes().filter(function(n){return nodeType(n)==='OGG_EXTRACT';});
    var reps=allNodes().filter(function(n){return nodeType(n)==='OGG_REPLICAT';});
    var trails=allNodes().filter(function(n){return nodeType(n)==='TRAIL';});
    var edges=edgeList();
    var captured=tableSet(extracts,'TABLE');
    var mapped=tableSet(reps,'MAP');
    var rows=[];
    var trailMismatch={};
    var trailMismatchRows={};
    function namesFor(nodes){return nodes.map(nodeName).filter(Boolean).join(', ')||'none discovered';}
    trails.forEach(function(trail){
      var trailCode=nodeCode(trail);
      var writers=edges.filter(function(e){return e.to===trailCode&&e.type==='WRITE_TRAIL';}).map(function(e){return root.querySelector('.dfd-node[data-node-code="'+e.from+'"]');}).filter(Boolean);
      var readers=edges.filter(function(e){return e.from===trailCode&&e.type==='APPLY';}).map(function(e){return root.querySelector('.dfd-node[data-node-code="'+e.to+'"]');}).filter(Boolean);
      if(!writers.length||!readers.length){return;}
      var trailCaptured={};
      writers.forEach(function(writer){
        nodeTables(writer).filter(function(r){return r.kind==='TABLE';}).forEach(function(r){trailCaptured[r.name]=true;});
      });
      readers.forEach(function(reader){
        nodeTables(reader).filter(function(r){return r.kind==='MAP';}).forEach(function(r){
          var mismatchKey=trailCode+'|'+nodeCode(reader)+'|'+r.name;
          if(!trailCaptured[r.name]&&!trailMismatchRows[mismatchKey]){
            trailMismatchRows[mismatchKey]=true;
            trailMismatch[r.name]=true;
            rows.push({
              level:'fail',
              title:'Trail-scoped MAP mismatch',
              text:nodeName(reader)+' maps '+r.name+' from '+nodeName(trail)+', but upstream '+namesFor(writers)+' does not capture that TABLE. Remove this MAP or add the TABLE to the upstream Extract lane.'
            });
          }
        });
      });
    });
    Object.keys(captured).forEach(function(t){if(!mapped[t]){rows.push({level:'warn',title:'Captured but not mapped',text:t+' is captured by '+captured[t].join(', ')+' but no Replicat MAP was found.'});}});
    Object.keys(mapped).forEach(function(t){if(!captured[t]&&!trailMismatch[t]){rows.push({level:'fail',title:'Mapped without capture',text:t+' is mapped by '+mapped[t].join(', ')+' but no Extract TABLE was found.'});}});
    Object.keys(captured).forEach(function(t){if(captured[t].length>1){rows.push({level:'warn',title:'Duplicate capture',text:t+' appears in '+captured[t].join(', ')+'.'});}});
    Object.keys(mapped).forEach(function(t){if(mapped[t].length>1){rows.push({level:'warn',title:'Duplicate apply',text:t+' appears in '+mapped[t].join(', ')+'.'});}});
    if(!rows.length){rows.push({level:'ok',title:'Validation passed',text:'All captured TABLE entries have downstream MAP entries, and no orphan MAP entries were detected.'});}
    openResultModal('Validate Fabric', extracts.length+' extract lanes · '+reps.length+' replicat lanes', rows.map(function(r){return '<div class="dfd-check-row '+r.level+'"><strong>'+r.title+'</strong><span>'+r.text+'</span></div>';}).join(''), false);
  }
  function impactForSelected(){
    var node=currentNode();
    if(!node){toast('먼저 canvas에서 process, trail, stream, target node를 선택하세요.');return;}
    var tables=nodeTables(node);
    var code=node.getAttribute('data-node-code')||'';
    var edges=edgeList();
    var incoming=edges.filter(function(e){return e.to===code;});
    var outgoing=edges.filter(function(e){return e.from===code;});
    var confidence=edges.filter(function(e){return e.from===code||e.to===code;}).map(edgeConfidence);
    var hasMedium=confidence.indexOf('MEDIUM')>=0, hasUnknown=confidence.indexOf('UNKNOWN')>=0;
    var confidenceText=!confidence.length?'No discovered edge':(hasUnknown?'UNKNOWN':(hasMedium?'MEDIUM':'HIGH'));
    var reads=incoming.length?connectedNames(incoming,'from'):(nodeType(node)==='OGG_EXTRACT'?'Source database tables from parameter TABLE entries':'none discovered');
    var writes=outgoing.length?connectedNames(outgoing,'to'):(nodeType(node)==='OGG_REPLICAT'?'Target database MAP entries from parameter':'none discovered');
    var restart=nodeType(node)==='OGG_EXTRACT'||nodeType(node)==='OGG_REPLICAT'?nodeName(node)+' only':'No direct process restart; connected process decides restart scope';
    var affected=outgoing.length?'Downstream discovered path: '+connectedNames(outgoing,'to'):'Only the selected node metadata is directly affected.';
    var notAffected=allNodes().filter(function(n){return nodeCode(n)!==code&&!incoming.some(function(e){return e.from===nodeCode(n);})&&!outgoing.some(function(e){return e.to===nodeCode(n);});}).slice(0,6).map(nodeName).join(', ')||'none';
    var complexity=tables.length>20?'High':(tables.length>5?'Medium':'Low');
    var html='<div class="dfd-check-row ok"><strong>Selected</strong><span>'+nodeName(node)+'</span></div>'+
      '<div class="dfd-check-row"><strong>Reads</strong><span>'+reads+'</span></div>'+
      '<div class="dfd-check-row"><strong>Writes / Applies to</strong><span>'+writes+'</span></div>'+
      '<div class="dfd-check-row '+(confidenceText==='HIGH'?'ok':'warn')+'"><strong>Discovery confidence</strong><span>'+confidenceText+'</span></div>'+
      '<div class="dfd-check-row warn"><strong>Restart required</strong><span>'+restart+'</span></div>'+
      '<div class="dfd-check-row"><strong>Mapped tables</strong><span>'+tables.length+' TABLE/MAP entries · Complexity: '+complexity+'</span></div>'+
      '<div class="dfd-check-row warn"><strong>Affected</strong><span>'+affected+'</span></div>'+
      '<div class="dfd-check-row ok"><strong>Not affected examples</strong><span>'+notAffected+'</span></div>';
    if(tables.length){
      html+='<div class="dfd-check-row"><strong>Sample entries</strong><span>'+tables.slice(0,8).map(function(t){return t.name;}).join(', ')+(tables.length>8?' ...':'')+'</span></div>';
    }
    openResultModal('Impact Analyzer', nodeName(node), html, false);
  }
  function showHistory(){
    openResultModal('Change History','Recent Set / Remove / Move apply requests',root.querySelector('#dfd-history-data').innerHTML,false);
  }
  function canvasUrl(){
    var appId=(window.apex&&apex.env&&apex.env.APP_ID)||'101';
    var session=(window.apex&&apex.env&&apex.env.APP_SESSION)||'';
    return 'f?p='+appId+':202:'+session;
  }
  var createStep=1, createEdit=false;
  function closeCreateModal(){root.querySelector('#dfd-create-modal').classList.remove('active');}
  function selectedCreateTables(){
    return Array.prototype.slice.call(root.querySelectorAll('#dfd-create-table-list .dfd-create-table.selected')).map(function(b){return b.getAttribute('data-table');});
  }
  function createPayload(){
    var param=root.querySelector('#dfd-new-param');
    return {
      extract:(root.querySelector('#dfd-new-extract').value||'').trim().toUpperCase(),
      trail:(root.querySelector('#dfd-new-trail').value||'').trim(),
      alias:(root.querySelector('#dfd-new-alias').value||'src_ogg').trim(),
      tables:selectedCreateTables().join('\n'),
      parameterText:param?(param.value||'').trim():''
    };
  }
  function buildCreateParameter(){
    var p=createPayload();
    var tables=selectedCreateTables();
    var lines=['EXTRACT '+(p.extract||'-'),'USERIDALIAS '+(p.alias||'src_ogg')+' DOMAIN OracleGoldenGate','TRANLOGOPTIONS INTEGRATEDPARAMS (max_sga_size 256)','UPDATERECORDFORMAT COMPACT','DDL INCLUDE MAPPED','EXTTRAIL '+(p.trail||'-')];
    tables.forEach(function(t){lines.push('TABLE '+t+';');});
    return lines.join('\n');
  }
  function createCommands(){
    var p=createPayload();
    return ['REGISTER EXTRACT '+(p.extract||'-')+' DATABASE','ADD EXTRACT '+(p.extract||'-')+', INTEGRATED TRANLOG, BEGIN NOW','ADD EXTTRAIL '+(p.trail||'-')+', EXTRACT '+(p.extract||'-')];
  }
  function commandRows(rows){
    return rows.map(function(r){
      var status=(r.status||'PENDING').toLowerCase();
      return '<div class="dfd-command-row"><code>'+r.cmd+'</code><span class="dfd-command-status '+(status==='ok'?'ok':(status==='fail'?'fail':''))+'">'+(r.status||'PENDING')+'</span></div>';
    }).join('');
  }
  function processEdges(){
    var edges=edgeList(), code=currentNodeCode;
    return {
      incoming:edges.filter(function(e){return e.to===code;}),
      outgoing:edges.filter(function(e){return e.from===code;})
    };
  }
  function dropCommands(){
    var name=currentNodeRef||'-', alias=currentNodeAlias||'<from parameter>', trail=currentNodeTrail||'<from parameter>';
    if(currentNodeType==='OGG_EXTRACT'){
      var cmds=['DBLOGIN USERIDALIAS '+alias,'STOP EXTRACT '+name+'!','DELETE EXTRACT '+name+'!','UNREGISTER EXTRACT '+name+' DATABASE'];
      if(trail){cmds.push('DELETE EXTTRAIL '+trail);}
      return cmds;
    }
    if(currentNodeType==='OGG_REPLICAT'){
      return ['DBLOGIN USERIDALIAS '+alias,'STOP REPLICAT '+name+'!','DELETE REPLICAT '+name+'!'];
    }
    return [];
  }
  function openDropProcess(){
    if(currentNodeType!=='OGG_EXTRACT'&&currentNodeType!=='OGG_REPLICAT'){toast('Extract 또는 Replicat node를 선택하세요.');return;}
    var modal=root.querySelector('#dfd-create-modal');
    var box=modal.querySelector('.dfd-modal');
    var edges=processEdges();
    var downstream=edges.outgoing.length?connectedNames(edges.outgoing,'to'):'none discovered';
    var upstream=edges.incoming.length?connectedNames(edges.incoming,'from'):'none discovered';
    var title='Drop '+(currentNodeType==='OGG_EXTRACT'?'Extract':'Replicat')+' Process';
    var summary='<div class="dfd-check-row warn"><strong>Selected process</strong><span>'+currentNodeRef+' · '+currentNodeType+'</span></div>'+
      '<div class="dfd-check-row"><strong>Upstream</strong><span>'+upstream+'</span></div>'+
      '<div class="dfd-check-row"><strong>Downstream</strong><span>'+downstream+'</span></div>'+
      '<div class="dfd-check-row"><strong>TABLE/MAP metadata</strong><span>'+(nodeTables(currentNode()).length)+' entries discovered from parameter metadata.</span></div>'+
      '<div class="dfd-check-row warn"><strong>Guardrail</strong><span>Submit 전에는 아무 명령도 실행하지 않습니다. 성공 후 parameter file은 .dropped 백업으로 보관됩니다.</span></div>';
    box.innerHTML='<div class="dfd-modal-head"><div><div class="dfd-modal-title">'+title+'</div><div class="dfd-modal-sub">Canvas에서 확인한 연결 구조를 기준으로 불필요한 GoldenGate process lane을 정리합니다.</div></div><button type="button" class="dfd-close" id="dfd-close-create">Close</button></div>'+
      '<div class="dfd-create-body"><div class="dfd-create-preview">'+summary+'</div><div class="dfd-create-preview" id="dfd-drop-command-preview">'+commandRows(dropCommands().map(function(cmd){return {cmd:cmd,status:'PENDING'};}))+'</div></div>'+
      '<div class="dfd-create-actions"><button type="button" class="dfd-tool" id="dfd-create-cancel">Cancel</button><button type="button" class="dfd-tool primary" id="dfd-drop-apply">Submit</button></div>';
    modal.classList.add('active');
    box.querySelector('#dfd-close-create').addEventListener('click',closeCreateModal);
    box.querySelector('#dfd-create-cancel').addEventListener('click',closeCreateModal);
    box.querySelector('#dfd-drop-apply').addEventListener('click',function(){
      var btn=this,result=box.querySelector('#dfd-drop-command-preview');
      if(btn.disabled){return;}
      if(!window.apex||!apex.server){result.textContent='APEX runtime을 찾을 수 없습니다.';return;}
      btn.disabled=true;
      btn.textContent='Dropping...';
      result.innerHTML=commandRows(dropCommands().map(function(cmd){return {cmd:cmd,status:'RUNNING'};}));
      apex.server.process('DROP_FABRIC_PROCESS',{
        x01:currentNodeRef,
        x02:currentNodeType,
        x03:currentNodeAlias,
        x04:currentNodeTrail
      },{
        dataType:'json',
        success:function(data){
          var rows=(data.commands||[]).map(function(r){return {cmd:(r.cmd||'').toUpperCase(),status:r.status||'OK'};});
          result.innerHTML=commandRows(rows)+'<div class="dfd-create-preview">Status: '+data.status+'\nParameter backup: '+(data.backup||'-')+'\nMetadata를 다시 읽는 중입니다.</div>';
          if(data.status==='APPLIED'||data.status==='PARTIAL'){refreshMetadataAfterCreate();}else{btn.disabled=false;btn.textContent='Submit';}
        },
        error:function(jq){
          btn.disabled=false;
          btn.textContent='Submit';
          result.innerHTML=commandRows(dropCommands().map(function(cmd){return {cmd:cmd,status:'FAIL'};}))+'<div class="dfd-create-preview">Drop 실패: '+(jq.responseText||jq.statusText||'unknown error')+'</div>';
        }
      });
    });
  }
  function showCreateStep(n){
    createStep=n;
    root.querySelectorAll('.dfd-create-panel').forEach(function(p){p.classList.toggle('active',p.getAttribute('data-create-step')===String(n));});
    root.querySelectorAll('.dfd-create-step').forEach(function(s){s.classList.toggle('active',s.getAttribute('data-create-tab')===String(n));});
    root.querySelector('#dfd-create-prev').style.display=n===1?'none':'inline-block';
    root.querySelector('#dfd-create-next').style.display=n===4?'none':'inline-block';
    root.querySelector('#dfd-create-edit').style.display=n===3?'inline-block':'none';
    root.querySelector('#dfd-create-apply').style.display=n===4?'inline-block':'none';
    updateCreatePreview();
  }
  function updateCreatePreview(){
    var p=createPayload();
    if(createStep===3){
      var prm=root.querySelector('#dfd-new-param');
      if(!createEdit){prm.value=buildCreateParameter();}
      root.querySelector('#dfd-create-param-view').textContent=prm.value;
      root.querySelector('#dfd-create-param-view').style.display=createEdit?'none':'block';
      root.querySelector('#dfd-create-param-edit').style.display=createEdit?'block':'none';
    }
    if(createStep===4){
      root.querySelector('#dfd-create-command-preview').innerHTML=commandRows(createCommands().map(function(cmd){return {cmd:cmd,status:'PENDING'};}));
    }
  }
  function refreshMetadataAfterCreate(){
    apex.server.process('REFRESH_FABRIC_METADATA',{},{
      dataType:'json',
      success:function(data){
        toast('create 완료 후 metadata refresh 완료: '+data.nodes+' nodes, '+data.edges+' edges');
        window.location.reload();
      },
      error:function(jq){
        toast('create는 완료됐지만 metadata refresh 실패: '+(jq.responseText||jq.statusText||'unknown error'));
      }
    });
  }
  root.querySelectorAll('.dfd-node').forEach(function(node){
    node.addEventListener('click',function(){
      root.querySelectorAll('.dfd-node').forEach(function(n){n.classList.remove('selected');});
      node.classList.add('selected');
      currentNodeCode=node.getAttribute('data-node-code')||'';
      currentNodeType=node.getAttribute('data-node-type')||'';
      currentNodeRef=node.getAttribute('data-node-ref')||'';
      currentNodeAlias=node.getAttribute('data-node-alias')||'';
      currentNodeTrail=node.getAttribute('data-node-trail')||'';
      root.querySelector('#dfd-title').textContent=node.getAttribute('data-node-name');
      root.querySelector('#dfd-type').textContent=node.getAttribute('data-node-type');
      root.querySelector('#dfd-ref').textContent=node.getAttribute('data-node-ref');
      root.querySelector('#dfd-detail').textContent=normalize(node.getAttribute('data-node-detail'));
      currentTables=node.getAttribute('data-node-tables')||'';
      root.querySelector('#dfd-drop-process').classList.toggle('active',currentNodeType==='OGG_EXTRACT'||currentNodeType==='OGG_REPLICAT');
    });
  });
  drawEdges();
  window.addEventListener('resize',drawEdges);
  root.querySelector('#dfd-impact').addEventListener('click',impactForSelected);
  root.querySelector('#dfd-impact-top').addEventListener('click',impactForSelected);
  root.querySelector('#dfd-validate').addEventListener('click',validateFabric);
  root.querySelector('#dfd-history').addEventListener('click',showHistory);
  root.querySelector('#dfd-refresh').addEventListener('click',function(){
    var btn=this;
    if(btn.disabled){return;}
    if(!window.apex||!apex.server){window.location.reload();return;}
    btn.disabled=true;
    btn.textContent='Refreshing...';
    toast('GoldenGate parameter와 runtime metadata를 다시 읽는 중입니다.');
    apex.server.process('REFRESH_FABRIC_METADATA',{},{
      dataType:'json',
      success:function(data){
        toast('metadata refresh 완료: '+data.nodes+' nodes, '+data.edges+' edges');
        window.location.reload();
      },
      error:function(jq){
        btn.disabled=false;
        btn.textContent='Refresh Metadata';
        toast('metadata refresh 실패: '+(jq.responseText||jq.statusText||'unknown error'));
      }
    });
  });
  root.querySelector('#dfd-create-lane').addEventListener('click',function(){
    var modal=root.querySelector('#dfd-create-modal');
    var box=modal.querySelector('.dfd-modal');
    box.innerHTML='<div class="dfd-modal-head"><div><div class="dfd-modal-title" id="dfd-create-title">Create Extract Lane</div><div class="dfd-modal-sub">Oracle source는 표준 Integrated Extract로 생성하고, 세부 튜닝은 공식 GoldenGate Web UI/AdminClient에서 이어갑니다.</div></div><button type="button" class="dfd-close" id="dfd-close-create">Close</button></div><div class="dfd-create-steps"><div class="dfd-create-step active" data-create-tab="1">1. Lane 기본값</div><div class="dfd-create-step" data-create-tab="2">2. Table 선택</div><div class="dfd-create-step" data-create-tab="3">3. Parameter 확인</div><div class="dfd-create-step" data-create-tab="4">4. Register</div></div><div class="dfd-create-body"><div class="dfd-create-panel active" data-create-step="1"><div class="dfd-create-grid"><div class="dfd-create-field"><label>Extract Name</label><input id="dfd-new-extract" maxlength="8" placeholder="예: FCT1"></div><div class="dfd-create-field"><label>Trail Prefix</label><input id="dfd-new-trail" maxlength="2" placeholder="예: t3"></div><div class="dfd-create-field full"><label>USERIDALIAS</label><select id="dfd-new-alias">'+root.querySelector('#dfd-create-alias-data').innerHTML+'</select></div></div></div><div class="dfd-create-panel" data-create-step="2"><div class="dfd-table-search"><input id="dfd-create-table-filter" placeholder="예: cfund, opstatus, tot"></div><div class="dfd-create-table-list" id="dfd-create-table-list">'+root.querySelector('#dfd-create-candidate-data').innerHTML+'</div></div><div class="dfd-create-panel" data-create-step="3"><div class="dfd-create-preview" id="dfd-create-param-view"></div><div class="dfd-create-field full" id="dfd-create-param-edit" style="display:none"><label>Parameter Text</label><textarea id="dfd-new-param"></textarea></div></div><div class="dfd-create-panel" data-create-step="4"><div class="dfd-create-preview" id="dfd-create-command-preview"></div></div></div><div class="dfd-create-actions"><button type="button" class="dfd-tool" id="dfd-create-cancel">Cancel</button><button type="button" class="dfd-tool" id="dfd-create-prev">Previous</button><button type="button" class="dfd-tool" id="dfd-create-edit">Edit</button><button type="button" class="dfd-tool primary" id="dfd-create-next">Next</button><button type="button" class="dfd-tool primary" id="dfd-create-apply">Submit</button></div>';
    createStep=1;
    createEdit=false;
    modal.classList.add('active');
    box.querySelector('#dfd-close-create').addEventListener('click',closeCreateModal);
    box.querySelector('#dfd-create-cancel').addEventListener('click',closeCreateModal);
    ['dfd-new-extract','dfd-new-trail','dfd-new-alias'].forEach(function(id){box.querySelector('#'+id).addEventListener('input',updateCreatePreview);});
    box.querySelector('#dfd-create-table-filter').addEventListener('input',function(){var q=this.value.toUpperCase();box.querySelectorAll('.dfd-create-table').forEach(function(b){b.style.display=(b.getAttribute('data-table').indexOf(q)>=0)?'flex':'none';});});
    box.querySelectorAll('.dfd-create-table').forEach(function(b){b.addEventListener('click',function(){b.classList.toggle('selected');var c=b.querySelector('.dfd-create-table-check');if(c){c.checked=b.classList.contains('selected');}updateCreatePreview();});});
    box.querySelector('#dfd-create-prev').addEventListener('click',function(){showCreateStep(Math.max(1,createStep-1));});
    box.querySelector('#dfd-create-next').addEventListener('click',function(){
      var p=createPayload();
      if(createStep===1&&(!p.extract||!p.trail)){toast('Extract name과 Trail prefix를 입력하세요.');return;}
      if(createStep===2&&!selectedCreateTables().length){toast('하나 이상의 TABLE을 선택하세요.');return;}
      if(createStep===3&&!box.querySelector('#dfd-new-param').value.trim()){toast('parameter 내용을 확인하세요.');return;}
      createEdit=false;
      showCreateStep(Math.min(4,createStep+1));
    });
    box.querySelector('#dfd-create-edit').addEventListener('click',function(){createEdit=!createEdit;this.textContent=createEdit?'Preview':'Edit';updateCreatePreview();});
    box.querySelector('#dfd-create-apply').addEventListener('click',function(){
      var btn=this, p=createPayload(), result=box.querySelector('#dfd-create-command-preview');
      if(btn.disabled){return;}
      if(!window.apex||!apex.server){result.textContent='APEX runtime을 찾을 수 없습니다.';return;}
      btn.disabled=true;
      btn.textContent='Submitting...';
      result.innerHTML=commandRows(createCommands().map(function(cmd){return {cmd:cmd,status:'RUNNING'};}));
      apex.server.process('CREATE_FABRIC_LANE',{
        x01:p.extract,
        x02:p.trail,
        x03:p.alias,
        x04:p.parameterText,
        x05:p.tables
      },{
        dataType:'json',
        success:function(data){
          var rows=(data.commands||[]).map(function(r){return {cmd:(r.cmd||'').toUpperCase(),status:r.status||'OK'};});
          result.innerHTML=commandRows(rows)+'<div class="dfd-create-preview">Parameter file: '+data.parameter_file+'\nStatus: '+data.status+'\nMetadata를 다시 읽는 중입니다.</div>';
          if(data.status==='APPLIED'){refreshMetadataAfterCreate();}else{btn.disabled=false;btn.textContent='Submit';}
        },
        error:function(jq){
          btn.disabled=false;
          btn.textContent='Submit';
          result.innerHTML=commandRows(createCommands().map(function(cmd){return {cmd:cmd,status:'FAIL'};}))+'<div class="dfd-create-preview">Create 실패: '+(jq.responseText||jq.statusText||'unknown error')+'</div>';
        }
      });
    });
    showCreateStep(1);
  });
~';
    l_html := l_html || q'~
  root.querySelector('#dfd-create-replicat-lane').addEventListener('click',function(){
    var modal=root.querySelector('#dfd-create-modal');
    var box=modal.querySelector('.dfd-modal');
    function replPayload(){
      var param=box.querySelector('#dfd-new-param');
      return {
        name:(box.querySelector('#dfd-new-replicat').value||'').trim().toUpperCase(),
        mode:(box.querySelector('#dfd-replicat-mode').value||'classic'),
        alias:(box.querySelector('#dfd-new-alias').value||'trg_ogg').trim(),
        trail:(box.querySelector('#dfd-new-trail-select').value||'').trim(),
        maxSga:(box.querySelector('#dfd-opt-max-sga')?box.querySelector('#dfd-opt-max-sga').value:'256'),
        parallelism:(box.querySelector('#dfd-opt-parallelism')?box.querySelector('#dfd-opt-parallelism').value:'2'),
        threads:(box.querySelector('#dfd-opt-threads')?box.querySelector('#dfd-opt-threads').value:'3'),
        mapParallelism:(box.querySelector('#dfd-opt-map-parallelism')?box.querySelector('#dfd-opt-map-parallelism').value:'2'),
        splitTransRec:(box.querySelector('#dfd-opt-split-trans-rec')?box.querySelector('#dfd-opt-split-trans-rec').value:'100000'),
        minParallelism:(box.querySelector('#dfd-opt-min-parallelism')?box.querySelector('#dfd-opt-min-parallelism').value:'2'),
        maxParallelism:(box.querySelector('#dfd-opt-max-parallelism')?box.querySelector('#dfd-opt-max-parallelism').value:'4'),
        tables:selectedCreateTables().join('\n'),
        parameterText:param?(param.value||'').trim():''
      };
    }
    function renderModeOptions(){
      var p=replPayload(), html='';
      if(p.mode==='integrated'){
        html='<div class="dfd-create-field"><label>MAX_SGA_SIZE</label><input id="dfd-opt-max-sga" value="256"></div><div class="dfd-create-field"><label>PARALLELISM</label><input id="dfd-opt-parallelism" value="2"></div>';
      }else if(p.mode==='coordinated'){
        html='<div class="dfd-create-field"><label>MAXTHREADS</label><input id="dfd-opt-threads" value="3"></div>';
      }else if(p.mode==='parallel-non-integrated'){
        html='<div class="dfd-create-field"><label>MAP_PARALLELISM</label><input id="dfd-opt-map-parallelism" value="2"></div><div class="dfd-create-field"><label>SPLIT_TRANS_REC</label><input id="dfd-opt-split-trans-rec" value="100000"></div>';
      }else if(p.mode==='parallel-integrated'){
        html='<div class="dfd-create-field"><label>MAX_SGA_SIZE</label><input id="dfd-opt-max-sga" value="256"></div><div class="dfd-create-field"><label>MIN_PARALLELISM</label><input id="dfd-opt-min-parallelism" value="2"></div><div class="dfd-create-field"><label>MAX_PARALLELISM</label><input id="dfd-opt-max-parallelism" value="4"></div><div class="dfd-create-field"><label>SPLIT_TRANS_REC</label><input id="dfd-opt-split-trans-rec" value="100000"></div>';
      }
      box.querySelector('#dfd-replicat-mode-options').innerHTML=html;
      box.querySelectorAll('#dfd-replicat-mode-options input').forEach(function(i){i.addEventListener('input',updateReplPreview);});
      updateReplPreview();
    }
    function buildReplParameter(){
      var p=replPayload(), tables=selectedCreateTables();
      var lines=['REPLICAT '+(p.name||'-'),'CACHEMGR CACHESIZE 128M','USERIDALIAS '+(p.alias||'trg_ogg')+' DOMAIN OracleGoldenGate','ASSUMETARGETDEFS','APPLYNOOPUPDATES'];
      if(p.mode==='integrated'){lines.push('DBOPTIONS INTEGRATEDPARAMS (max_sga_size '+(p.maxSga||'256')+', parallelism '+(p.parallelism||'2')+')');}
      if(p.mode==='coordinated'){lines.push('-- Coordinated Replicat uses MAXTHREADS '+(p.threads||'3')+' in ADD REPLICAT.');}
      if(p.mode==='parallel-non-integrated'){lines.push('MAP_PARALLELISM '+(p.mapParallelism||'2'));lines.push('SPLIT_TRANS_REC '+(p.splitTransRec||'100000'));}
      if(p.mode==='parallel-integrated'){lines.push('DBOPTIONS INTEGRATEDPARAMS (max_sga_size '+(p.maxSga||'256')+', min_parallelism '+(p.minParallelism||'2')+', max_parallelism '+(p.maxParallelism||'4')+')');lines.push('SPLIT_TRANS_REC '+(p.splitTransRec||'100000'));}
      lines.push('DISCARDFILE '+(p.name||'-')+'.dsc, PURGE, MEGABYTES 100','REPORTCOUNT EVERY 1 MINUTES RATE','DDL INCLUDE MAPPED','DDLERROR 4080 IGNORE','DDLERROR 942 IGNORE','DDLERROR 4043 IGNORE','DDLERROR 1434 IGNORE');
      tables.forEach(function(t){lines.push('MAP '+t+', TARGET '+t+';');});
      return lines.join('\n');
    }
    function replCommands(){
      var p=replPayload(), cmd;
      if(p.mode==='classic'){cmd='ADD REPLICAT '+(p.name||'-')+', EXTTRAIL '+(p.trail||'-')+', BEGIN NOW';}
      else if(p.mode==='integrated'){cmd='ADD REPLICAT '+(p.name||'-')+', INTEGRATED, EXTTRAIL '+(p.trail||'-')+', BEGIN NOW';}
      else if(p.mode==='coordinated'){cmd='ADD REPLICAT '+(p.name||'-')+', COORDINATED MAXTHREADS '+(p.threads||'3')+', EXTTRAIL '+(p.trail||'-')+', BEGIN NOW';}
      else if(p.mode==='parallel-non-integrated'){cmd='ADD REPLICAT '+(p.name||'-')+', PARALLEL, EXTTRAIL '+(p.trail||'-')+', BEGIN NOW';}
      else{cmd='ADD REPLICAT '+(p.name||'-')+', PARALLEL, INTEGRATED, EXTTRAIL '+(p.trail||'-')+', BEGIN NOW';}
      return [cmd];
    }
    function updateReplPreview(){
      var prm=box.querySelector('#dfd-new-param');
      if(createStep===3){
        if(!createEdit){prm.value=buildReplParameter();}
        box.querySelector('#dfd-create-param-view').textContent=prm.value;
        box.querySelector('#dfd-create-param-view').style.display=createEdit?'none':'block';
        box.querySelector('#dfd-create-param-edit').style.display=createEdit?'block':'none';
      }
      if(createStep===4){box.querySelector('#dfd-create-command-preview').innerHTML=commandRows(replCommands().map(function(cmd){return {cmd:cmd,status:'PENDING'};}));}
    }
    function showReplStep(n){
      createStep=n;
      box.querySelectorAll('.dfd-create-panel').forEach(function(p){p.classList.toggle('active',p.getAttribute('data-create-step')===String(n));});
      box.querySelectorAll('.dfd-create-step').forEach(function(s){s.classList.toggle('active',s.getAttribute('data-create-tab')===String(n));});
      box.querySelector('#dfd-create-prev').style.display=n===1?'none':'inline-block';
      box.querySelector('#dfd-create-next').style.display=n===4?'none':'inline-block';
      box.querySelector('#dfd-create-edit').style.display=n===3?'inline-block':'none';
      box.querySelector('#dfd-create-apply').style.display=n===4?'inline-block':'none';
      updateReplPreview();
    }
    box.innerHTML=
      '<div class="dfd-modal-head"><div><div class="dfd-modal-title">Create Replicat Lane</div><div class="dfd-modal-sub">Replicat mode를 선택하고, 기존 trail과 MAP 대상 table을 연결합니다.</div></div><button type="button" class="dfd-close" id="dfd-close-create">Close</button></div>'+
      '<div class="dfd-create-steps"><div class="dfd-create-step active" data-create-tab="1">1. Mode / Trail</div><div class="dfd-create-step" data-create-tab="2">2. Table 선택</div><div class="dfd-create-step" data-create-tab="3">3. Parameter 확인</div><div class="dfd-create-step" data-create-tab="4">4. Register</div></div>'+
      '<div class="dfd-create-body"><div class="dfd-create-panel active" data-create-step="1"><div class="dfd-create-grid"><div class="dfd-create-field"><label>Replicat Name</label><input id="dfd-new-replicat" maxlength="8" placeholder="예: RCT1"></div>'+
      '<div class="dfd-create-field"><label>Mode</label><select id="dfd-replicat-mode"><option value="classic">Classic</option><option value="integrated">Integrated</option><option value="coordinated">Coordinated</option><option value="parallel-non-integrated">Parallel Non-Integrated</option><option value="parallel-integrated">Parallel Integrated</option></select></div>'+
      '<div class="dfd-create-field"><label>USERIDALIAS</label><select id="dfd-new-alias">'+root.querySelector('#dfd-create-alias-data').innerHTML+'</select></div>'+
      '<div class="dfd-create-field"><label>Trail</label><select id="dfd-new-trail-select">'+root.querySelector('#dfd-create-trail-data').innerHTML+'</select></div>'+
      '<div class="dfd-create-field full"><label>Mode Options</label><div class="dfd-create-grid" id="dfd-replicat-mode-options"></div></div></div></div>'+
      '<div class="dfd-create-panel" data-create-step="2"><div class="dfd-table-search"><input id="dfd-create-table-filter" placeholder="예: cfund, opstatus, tot"></div><div class="dfd-create-table-list" id="dfd-create-table-list">'+root.querySelector('#dfd-create-candidate-data').innerHTML+'</div></div>'+
      '<div class="dfd-create-panel" data-create-step="3"><div class="dfd-create-preview" id="dfd-create-param-view"></div><div class="dfd-create-field full" id="dfd-create-param-edit" style="display:none"><label>Parameter Text</label><textarea id="dfd-new-param"></textarea></div></div>'+
      '<div class="dfd-create-panel" data-create-step="4"><div class="dfd-create-preview" id="dfd-create-command-preview"></div></div></div>'+
      '<div class="dfd-create-actions"><button type="button" class="dfd-tool" id="dfd-create-cancel">Cancel</button><button type="button" class="dfd-tool" id="dfd-create-prev">Previous</button><button type="button" class="dfd-tool" id="dfd-create-edit">Edit</button><button type="button" class="dfd-tool primary" id="dfd-create-next">Next</button><button type="button" class="dfd-tool primary" id="dfd-create-apply">Submit</button></div>';
    createStep=1;createEdit=false;modal.classList.add('active');
    box.querySelector('#dfd-close-create').addEventListener('click',closeCreateModal);
    box.querySelector('#dfd-create-cancel').addEventListener('click',closeCreateModal);
    ['dfd-new-replicat','dfd-new-alias','dfd-new-trail-select'].forEach(function(id){box.querySelector('#'+id).addEventListener('input',updateReplPreview);});
    box.querySelector('#dfd-replicat-mode').addEventListener('change',renderModeOptions);
    box.querySelector('#dfd-create-table-filter').addEventListener('input',function(){var q=this.value.toUpperCase();box.querySelectorAll('.dfd-create-table').forEach(function(b){b.style.display=(b.getAttribute('data-table').indexOf(q)>=0)?'grid':'none';});});
    box.querySelectorAll('.dfd-create-table').forEach(function(b){b.addEventListener('click',function(){b.classList.toggle('selected');var c=b.querySelector('.dfd-create-table-check');if(c){c.checked=b.classList.contains('selected');}updateReplPreview();});});
    box.querySelector('#dfd-create-prev').addEventListener('click',function(){showReplStep(Math.max(1,createStep-1));});
    box.querySelector('#dfd-create-next').addEventListener('click',function(){var p=replPayload();if(createStep===1&&(!p.name||!p.trail)){toast('Replicat name과 trail을 선택하세요.');return;}if(createStep===2&&!selectedCreateTables().length){toast('하나 이상의 TABLE을 선택하세요.');return;}if(createStep===3&&!box.querySelector('#dfd-new-param').value.trim()){toast('parameter 내용을 확인하세요.');return;}createEdit=false;showReplStep(Math.min(4,createStep+1));});
    box.querySelector('#dfd-create-edit').addEventListener('click',function(){createEdit=!createEdit;this.textContent=createEdit?'Preview':'Edit';updateReplPreview();});
    box.querySelector('#dfd-create-apply').addEventListener('click',function(){
      var btn=this,p=replPayload(),result=box.querySelector('#dfd-create-command-preview');
      if(btn.disabled){return;}
      if(!window.apex||!apex.server){result.textContent='APEX runtime을 찾을 수 없습니다.';return;}
      btn.disabled=true;
      btn.textContent='Submitting...';
      result.innerHTML=commandRows(replCommands().map(function(cmd){return {cmd:cmd,status:'RUNNING'};}));
      apex.server.process('CREATE_REPLICAT_LANE',{
        x01:p.name,x02:p.mode,x03:p.alias,x04:p.trail,x05:p.tables,
        x06:p.parameterText,x07:p.maxSga,x08:p.parallelism,x09:p.threads,x10:p.mapParallelism
      },{
        dataType:'json',
        success:function(data){
          var rows=(data.commands||[]).map(function(r){return {cmd:(r.cmd||'').toUpperCase(),status:r.status||'OK'};});
          result.innerHTML=commandRows(rows)+'<div class="dfd-create-preview">Parameter file: '+data.parameter_file+'\nStatus: '+data.status+'\nMetadata를 다시 읽는 중입니다.</div>';
          if(data.status==='APPLIED'){refreshMetadataAfterCreate();}else{btn.disabled=false;btn.textContent='Submit';}
        },
        error:function(jq){
          btn.disabled=false;
          btn.textContent='Submit';
          result.innerHTML=commandRows(replCommands().map(function(cmd){return {cmd:cmd,status:'FAIL'};}))+'<div class="dfd-create-preview">Create 실패: '+(jq.responseText||jq.statusText||'unknown error')+'</div>';
        }
      });
    });
    renderModeOptions();
    showReplStep(1);
  });
  root.querySelector('#dfd-pin').addEventListener('click',function(){
    if(!currentNodeCode){toast('먼저 canvas에서 Extract 또는 Replicat node를 선택하세요.');return;}
    var appId=(window.apex&&apex.env&&apex.env.APP_ID)||'101';
    var session=(window.apex&&apex.env&&apex.env.APP_SESSION)||'';
    try{window.sessionStorage.setItem('gg_fabric_set_table_node',currentNodeCode);window.sessionStorage.setItem('gg_fabric_table_action','ADD');}catch(e){}
    window.location.href='f?p='+appId+':203:'+session+'#'+encodeURIComponent(currentNodeCode);
  });
  function openTableModal(title){
    if(!root.querySelector('.dfd-node.selected')){toast('먼저 canvas에서 Extract 또는 Replicat node를 선택하세요.');return;}
    root.querySelector('#dfd-table-title').textContent=title;
    root.querySelector('#dfd-table-sub').textContent=root.querySelector('#dfd-title').textContent;
    root.querySelector('.dfd-table-search').style.display='block';
    root.querySelector('#dfd-table-filter').value='';
    renderTableBrowser();
    root.querySelector('#dfd-table-modal').classList.add('active');
  }
  root.querySelector('#dfd-prm').addEventListener('click',function(){openTableModal('Parameter TABLE / MAP List');});
  root.querySelector('#dfd-drop-process').addEventListener('click',openDropProcess);
  root.querySelector('#dfd-remove').addEventListener('click',function(){
    if(!currentNodeCode){toast('먼저 canvas에서 Extract 또는 Replicat node를 선택하세요.');return;}
    if(!currentTables){toast('선택한 node에 제거할 TABLE/MAP metadata가 없습니다.');return;}
    var appId=(window.apex&&apex.env&&apex.env.APP_ID)||'101';
    var session=(window.apex&&apex.env&&apex.env.APP_SESSION)||'';
    try{window.sessionStorage.setItem('gg_fabric_set_table_node',currentNodeCode);window.sessionStorage.setItem('gg_fabric_table_action','REMOVE');window.sessionStorage.setItem('gg_fabric_remove_tables',currentTables);}catch(e){}
    window.location.href='f?p='+appId+':203:'+session+'#'+encodeURIComponent(currentNodeCode);
  });
  root.querySelector('#dfd-move').addEventListener('click',function(){
    if(!currentNodeCode){toast('먼저 canvas에서 Extract 또는 Replicat node를 선택하세요.');return;}
    if(!currentTables){toast('선택한 node에 이동할 TABLE/MAP metadata가 없습니다.');return;}
    var appId=(window.apex&&apex.env&&apex.env.APP_ID)||'101';
    var session=(window.apex&&apex.env&&apex.env.APP_SESSION)||'';
    try{window.sessionStorage.setItem('gg_fabric_set_table_node',currentNodeCode);window.sessionStorage.setItem('gg_fabric_table_action','MOVE');window.sessionStorage.setItem('gg_fabric_remove_tables',currentTables);}catch(e){}
    window.location.href='f?p='+appId+':203:'+session+'#'+encodeURIComponent(currentNodeCode);
  });
  root.querySelector('#dfd-view-tables').addEventListener('click',function(){
    openTableModal('TABLE / MAP List');
  });
  root.querySelector('#dfd-close-tables').addEventListener('click',function(){root.querySelector('#dfd-table-modal').classList.remove('active');});
  root.querySelector('#dfd-table-filter').addEventListener('input',renderTableBrowser);
  root.querySelector('#dfd-table-modal').addEventListener('click',function(evt){if(evt.target===this){this.classList.remove('active');}});
  root.querySelector('#dfd-create-modal').addEventListener('click',function(evt){if(evt.target===this){closeCreateModal();}});
  document.addEventListener('keydown',function(evt){if(evt.key==='Escape'){root.querySelector('#dfd-table-modal').classList.remove('active');closeCreateModal();}});
})();
</script></section>~';

    return l_html;
  end render_canvas_design;

  function render_set_table_wizard(p_node_code varchar2) return clob is
    l_html clob;
    l_node ggadmin.fabric_node%rowtype;
    l_mode varchar2(20);
    l_candidates clob;
    l_targets clob;
    l_process_catalog clob;
  begin
    begin
      select *
        into l_node
        from ggadmin.fabric_node
       where node_code = upper(nvl(p_node_code, 'OGG_EXTRACT_FC02'));
    exception
      when no_data_found then
        return '<div class="t-Alert t-Alert--warning"><div class="t-Alert-body">Canvas에서 Extract 또는 Replicat node를 먼저 선택하세요.</div></div>';
    end;

    if l_node.node_type not in ('OGG_EXTRACT','OGG_REPLICAT') then
      return '<div class="t-Alert t-Alert--warning"><div class="t-Alert-body">Set Table wizard는 Extract 또는 Replicat node에서 사용합니다. 선택 node: ' || h(l_node.node_name) || '</div></div>';
    end if;

    l_mode := case when l_node.node_type = 'OGG_EXTRACT' then 'EXTRACT' else 'REPLICAT' end;
    l_candidates := to_clob('');
    l_targets := to_clob('');
    l_process_catalog := to_clob('');

    for t in (
      select c.owner_name || '.' || c.table_name table_ref,
             min(nvl(c.column_comment, c.table_name)) keep (dense_rank first order by c.column_id nulls last) sample_comment,
             count(*) column_count,
             max(nvl(s.schema_prepared, 'N')) schema_prepared,
             max(nvl(s.table_prepared, 'N')) table_prepared,
             max(nvl(s.pk_logging, '-')) pk_logging,
             max(nvl(s.ui_logging, '-')) ui_logging,
             max(nvl(s.fk_logging, '-')) fk_logging,
             max(nvl(s.all_logging, '-')) all_logging,
             max(nvl(s.check_note, 'supplemental logging cache가 아직 수집되지 않았다.')) check_note
        from ggadmin.fabric_table_column c
       left join ggadmin.fabric_supplemental_log s
         on s.owner_name = c.owner_name
         and s.table_name = c.table_name
         and s.source_system = 'demo_osrc_23ai'
       where c.owner_name = 'SOE'
       group by c.owner_name, c.table_name
       order by c.owner_name, c.table_name
    ) loop
      l_candidates := l_candidates ||
        '<button type="button" class="stw-candidate" data-table="' || h(t.table_ref) ||
        '" data-schema-prepared="' || h(t.schema_prepared) ||
        '" data-table-prepared="' || h(t.table_prepared) ||
        '" data-pk-logging="' || h(t.pk_logging) ||
        '" data-ui-logging="' || h(t.ui_logging) ||
        '" data-fk-logging="' || h(t.fk_logging) ||
        '" data-all-logging="' || h(t.all_logging) ||
        '" data-log-note="' || h(t.check_note) || '">' ||
        '<input type="checkbox" class="stw-candidate-check" tabindex="-1" aria-label="' || h(t.table_ref) || '">' ||
        '<span>' || h(t.table_ref) || '</span><small>' || h(t.column_count || ' columns') || '</small></button>';
    end loop;

    for p in (
      select node_code, node_name, system_name, nvl(description, '-') description
        from ggadmin.fabric_node
       where node_type = l_node.node_type
         and node_code <> l_node.node_code
       order by node_name
    ) loop
      l_targets := l_targets ||
        '<button type="button" class="stw-target-process" data-process="' || h(p.node_name) ||
        '" data-node-code="' || h(p.node_code) || '">' ||
        '<span>' || h(p.node_name) || '</span></button>';
    end loop;

    for p in (
      select node_code, node_name, node_type, system_name, nvl(description, '-') description
        from ggadmin.fabric_node
       where node_type in ('OGG_EXTRACT','OGG_REPLICAT')
       order by node_type, node_name
    ) loop
      l_process_catalog := l_process_catalog ||
        '<button type="button" class="stw-process-catalog-item" data-node-code="' || h(p.node_code) ||
        '" data-process="' || h(p.node_name) ||
        '" data-node-type="' || h(p.node_type) ||
        '" data-system="' || h(p.system_name) ||
        '" data-description="' || h(p.description) || '"></button>';
    end loop;

    l_html := to_clob(q'~<style>
.stw-wrap{--ink:#172033;--muted:#64748b;--line:#d8e1eb;--blue:#1f6feb;--green:#22c55e;--orange:#f59e0b;color:var(--ink)}
.stw-wrap *{box-sizing:border-box}
.stw-shell{border:1px solid var(--line);border-radius:8px;background:#fff;overflow:hidden}
.stw-head{display:flex;justify-content:space-between;gap:14px;padding:18px 20px;border-bottom:1px solid #e5e7eb}
.stw-title{font-size:22px;font-weight:900}
.stw-sub{font-size:12px;color:var(--muted);margin-top:5px}
.stw-mode{border-radius:999px;background:#e0f2fe;color:#075985;padding:6px 10px;font-size:11px;font-weight:900;align-self:start}
.stw-steps{display:grid;grid-template-columns:repeat(3,1fr);gap:10px;padding:14px 20px;background:#f8fafc;border-bottom:1px solid #e5e7eb}
.stw-step{border:1px solid #dbe4ef;border-radius:7px;background:#fff;padding:10px;font-size:12px;font-weight:900}
.stw-step.active{border-color:#1f6feb;box-shadow:0 0 0 3px rgba(31,111,235,.12)}
.stw-body{display:grid;grid-template-columns:360px 1fr;min-height:460px}
.stw-left{border-right:1px solid #e5e7eb;background:#f8fafc;padding:16px}
.stw-right{padding:18px}
.stw-search{width:100%;border:1px solid #cbd5e1;border-radius:7px;padding:10px 12px;font-size:13px}
.stw-list{margin-top:12px;display:grid;gap:8px;max-height:360px;overflow:auto}
.stw-candidate,.stw-target-process{display:flex;align-items:center;justify-content:space-between;gap:10px;text-align:left;border:1px solid #dbe4ef;border-radius:7px;background:#fff;padding:10px;cursor:pointer}
.stw-candidate-check{width:16px;height:16px;flex:0 0 auto;accent-color:#1f6feb}
.stw-candidate span,.stw-target-process span{font-size:13px;font-weight:900}
.stw-candidate small,.stw-target-process small{font-size:11px;color:#64748b}
.stw-target-list{max-width:140px}
.stw-target-process{width:136px;min-height:44px;align-items:center}
.stw-target-process small{display:none}
.stw-candidate.selected,.stw-target-process.selected{border-color:#1f6feb;background:#eff6ff}
.stw-panel{display:none}
.stw-panel.active{display:block}
.stw-field{margin-top:12px}
.stw-label{font-size:11px;font-weight:900;color:#64748b;text-transform:uppercase}
.stw-input,.stw-textarea{width:100%;margin-top:6px;border:1px solid #cbd5e1;border-radius:7px;padding:10px 12px;font-size:13px}
.stw-textarea{min-height:120px;font-family:monospace}
.stw-box{margin-top:12px;border:1px solid #dbe4ef;border-radius:7px;background:#f8fafc;padding:12px;font-size:13px;line-height:1.55;white-space:pre-line}
.stw-box.ok{border-color:#86efac;background:#f0fdf4;color:#166534}
.stw-box.warn{border-color:#fbbf24;background:#fffbeb;color:#92400e}
.stw-result{display:none;margin-top:12px;border:1px solid #93c5fd;border-radius:7px;background:#eff6ff;color:#1e3a8a;padding:12px;font-size:13px;line-height:1.55;white-space:pre-line}
.stw-actions{display:flex;gap:8px;margin-top:16px}
.stw-btn{border:1px solid #cbd5e1;border-radius:7px;background:#fff;padding:9px 12px;font-size:12px;font-weight:900}
.stw-btn.primary{border-color:#1f6feb;background:#1f6feb;color:#fff}
.stw-btn.disabled{opacity:.55}
.stw-empty{font-size:12px;color:#64748b;padding:10px}
</style><section class="stw-wrap"><div class="stw-shell"><div class="stw-head"><div><div class="stw-title">Set Table Wizard</div><div class="stw-sub">Canvas에서 선택한 GoldenGate process에 TABLE/MAP 변경 후보를 안전하게 구성합니다.</div></div><div class="stw-mode">~') || h(l_mode) || q'~</div></div><div class="stw-steps"><div class="stw-step active" data-step-tab="1">1. Table 선택</div><div class="stw-step" data-step-tab="2">2. ~' ||
      case when l_mode = 'EXTRACT' then 'Supplemental Logging 확인' else 'MAP / COLMAP 구성' end ||
      q'~</div><div class="stw-step" data-step-tab="3">3. Summary</div></div><div class="stw-body"><aside class="stw-left"><input class="stw-search" id="stw-search" placeholder="예: cfund, opstatus, tot"><div class="stw-list" id="stw-list">~' ||
      l_candidates ||
      q'~</div></aside><main class="stw-right"><div class="stw-panel active" data-step="1"><div class="stw-label">Selected Process</div><div class="stw-box" id="stw-process-box">~' ||
      h(l_node.node_name || chr(10) || l_node.node_type || ' - ' || l_node.system_name || chr(10) || nvl(l_node.description, '-')) ||
      q'~</div><div class="stw-box" id="stw-selected">table 후보를 검색하고 선택하세요.</div><div class="stw-actions"><button type="button" class="stw-btn primary" data-next="2">Next</button></div></div><div class="stw-panel" data-step="2">~';

    if l_mode = 'EXTRACT' then
      l_html := l_html || q'~<div class="stw-label">Supplemental Logging Check</div><div class="stw-box" id="stw-check">table을 선택하면 supplemental logging 확인 결과를 표시합니다.</div><div class="stw-actions"><button type="button" class="stw-btn" data-prev="1">Previous</button><button type="button" class="stw-btn primary" data-next="3">Next</button></div>~';
    else
      l_html := l_html || q'~<div class="stw-field"><div class="stw-label">Source Table</div><input class="stw-input" id="stw-source" readonly></div><div class="stw-field"><div class="stw-label">Target Table</div><input class="stw-input" id="stw-target"></div><div class="stw-field"><div class="stw-label">COLMAP</div><textarea class="stw-textarea" id="stw-colmap" placeholder="Transformation이 필요할 때만 COLMAP 내용을 입력합니다."></textarea></div><div class="stw-box" id="stw-map-preview">table을 선택하면 MAP preview를 표시합니다.</div><div class="stw-actions"><button type="button" class="stw-btn" data-prev="1">Previous</button><button type="button" class="stw-btn primary" data-next="3">Next</button></div>~';
    end if;

    l_html := l_html || q'~</div><div class="stw-panel" data-step="3"><div class="stw-label">Preview</div><div class="stw-box" id="stw-summary">아직 선택된 table이 없습니다.</div><div class="stw-result" id="stw-result"></div><div class="stw-actions"><button type="button" class="stw-btn" data-prev="2">Previous</button><button type="button" class="stw-btn primary" id="stw-apply">Apply Change</button><button type="button" class="stw-btn" id="stw-back-canvas">Back to Canvas</button></div></div></main></div><div id="stw-process-catalog" style="display:none">~' ||
      l_process_catalog ||
      q'~</div><div id="stw-move-targets" style="display:none">~' ||
      l_targets ||
      q'~</div></div>
<script>
(function(){
  var root=document.currentScript.closest('.stw-wrap');if(!root){return;}
  var mode='~' || h(l_mode) || q'~', processName='~' || h(l_node.node_name) || q'~', actionMode='ADD', selected='', selectedTables=[], selectedMeta=null, currentSql='', supplementalOk='N', targetProcess='';
  try{actionMode=(window.sessionStorage.getItem('gg_fabric_table_action')||'ADD').toUpperCase();}catch(e){actionMode='ADD';}
  function canvasUrl(){var appId=(window.apex&&apex.env&&apex.env.APP_ID)||'101';var session=(window.apex&&apex.env&&apex.env.APP_SESSION)||'';return 'f?p='+appId+':202:'+session;}
  var selectedNodeCode='';
  try{selectedNodeCode=(window.sessionStorage.getItem('gg_fabric_set_table_node')||'').toUpperCase();}catch(e){selectedNodeCode='';}
  function processCatalog(){
    return Array.prototype.slice.call(root.querySelectorAll('#stw-process-catalog .stw-process-catalog-item')).map(function(b){
      return {
        nodeCode:(b.getAttribute('data-node-code')||'').toUpperCase(),
        process:b.getAttribute('data-process')||'',
        nodeType:b.getAttribute('data-node-type')||'',
        system:b.getAttribute('data-system')||'',
        description:b.getAttribute('data-description')||''
      };
    });
  }
  function selectedProcess(){
    var items=processCatalog();
    for(var i=0;i<items.length;i++){if(items[i].nodeCode===selectedNodeCode){return items[i];}}
    return null;
  }
  var selectedProc=selectedProcess();
  if(selectedProc){
    processName=selectedProc.process;
    mode=selectedProc.nodeType==='OGG_REPLICAT'?'REPLICAT':'EXTRACT';
    root.querySelector('.stw-mode').textContent=mode;
    root.querySelector('#stw-process-box').textContent=selectedProc.process+'\n'+selectedProc.nodeType+' - '+selectedProc.system+'\n'+selectedProc.description;
  }
  function configureAddStep2(){
    if(actionMode!=='ADD'){return;}
    var tab=root.querySelector('[data-step-tab="2"]');
    var panel=root.querySelector('[data-step="2"]');
    if(!tab||!panel){return;}
    if(mode==='REPLICAT'){
      tab.textContent='2. MAP / COLMAP 구성';
      panel.innerHTML='<div class="stw-field"><div class="stw-label">Source Table</div><input class="stw-input" id="stw-source" readonly></div><div class="stw-field"><div class="stw-label">Target Table</div><input class="stw-input" id="stw-target"></div><div class="stw-field"><div class="stw-label">COLMAP</div><textarea class="stw-textarea" id="stw-colmap" placeholder="Transformation이 필요할 때만 COLMAP 내용을 입력합니다."></textarea></div><div class="stw-box" id="stw-map-preview">table을 선택하면 MAP preview를 표시합니다.</div><div class="stw-actions"><button type="button" class="stw-btn" data-prev="1">Previous</button><button type="button" class="stw-btn primary" data-next="3">Next</button></div>';
    }else{
      tab.textContent='2. Supplemental Logging 확인';
      panel.innerHTML='<div class="stw-label">Supplemental Logging Check</div><div class="stw-box" id="stw-check">table을 선택하면 supplemental logging 확인 결과를 표시합니다.</div><div class="stw-actions"><button type="button" class="stw-btn" data-prev="1">Previous</button><button type="button" class="stw-btn primary" data-next="3">Next</button></div>';
    }
  }
  configureAddStep2();
  function tableFromLine(line){
    var text=(line||'').trim().replace(/;$/,'');
    var upper=text.toUpperCase();
    if(upper.indexOf('TABLE ')===0){return text.substring(6).trim().toUpperCase();}
    if(upper.indexOf('MAP ')===0){return text.substring(4).split(',')[0].trim().toUpperCase();}
    return '';
  }
  if(actionMode==='REMOVE'){
    root.querySelector('.stw-title').textContent='Remove Table Wizard';
    root.querySelector('.stw-sub').textContent='선택한 GoldenGate process에서 TABLE/MAP 제거 요청을 생성합니다.';
    root.querySelector('[data-step-tab="1"]').textContent='1. 제거 대상 선택';
    root.querySelector('[data-step-tab="2"]').textContent='2. 영향도 확인';
    root.querySelector('#stw-selected').textContent='현재 process의 TABLE/MAP 목록에서 제거 대상을 선택하세요.';
    root.querySelector('#stw-search').placeholder='제거할 table 검색';
    var list=root.querySelector('#stw-list');
    var removeText='';
    try{removeText=window.sessionStorage.getItem('gg_fabric_remove_tables')||'';}catch(e){}
    var rows=removeText.split(/\s*\|\s*|\n/).map(tableFromLine).filter(function(v,i,a){return v&&a.indexOf(v)===i;});
    list.innerHTML=rows.length?rows.map(function(t){return '<button type="button" class="stw-candidate" data-table="'+t+'" data-schema-prepared="Y" data-table-prepared="Y" data-pk-logging="-" data-ui-logging="-" data-fk-logging="-" data-all-logging="-" data-log-note="현재 GoldenGate parameter에 등록된 TABLE/MAP 항목입니다."><input type="checkbox" class="stw-candidate-check" tabindex="-1" aria-label="'+t+'"><span>'+t+'</span><small>current mapping</small></button>';}).join(''):'<div class="stw-empty">현재 process에서 제거할 TABLE/MAP metadata가 없습니다.</div>';
  }
  if(actionMode==='MOVE'){
    root.querySelector('.stw-title').textContent='Move Table Wizard';
    root.querySelector('.stw-sub').textContent='선택한 GoldenGate process의 TABLE/MAP을 같은 유형의 다른 process로 이동합니다.';
    root.querySelector('[data-step-tab="1"]').textContent='1. 이동 대상 선택';
    root.querySelector('[data-step-tab="2"]').textContent='2. 대상 process 선택';
    root.querySelector('#stw-selected').textContent='현재 process의 TABLE/MAP 목록에서 이동할 대상을 선택하세요.';
    root.querySelector('#stw-search').placeholder='이동할 table 검색';
    var listMove=root.querySelector('#stw-list');
    var moveText='';
    try{moveText=window.sessionStorage.getItem('gg_fabric_remove_tables')||'';}catch(e){}
    var moveRows=moveText.split(/\s*\|\s*|\n/).map(tableFromLine).filter(function(v,i,a){return v&&a.indexOf(v)===i;});
    listMove.innerHTML=moveRows.length?moveRows.map(function(t){return '<button type="button" class="stw-candidate" data-table="'+t+'" data-schema-prepared="Y" data-table-prepared="Y" data-pk-logging="-" data-ui-logging="-" data-fk-logging="-" data-all-logging="-" data-log-note="현재 GoldenGate parameter에 등록된 TABLE/MAP 항목입니다."><input type="checkbox" class="stw-candidate-check" tabindex="-1" aria-label="'+t+'"><span>'+t+'</span><small>current mapping</small></button>';}).join(''):'<div class="stw-empty">현재 process에서 이동할 TABLE/MAP metadata가 없습니다.</div>';
    var targetType=mode==='REPLICAT'?'OGG_REPLICAT':'OGG_EXTRACT';
    var targetHtml=processCatalog().filter(function(p){return p.nodeType===targetType&&p.nodeCode!==selectedNodeCode;}).map(function(p){
      return '<button type="button" class="stw-target-process" data-process="'+p.process+'" data-node-code="'+p.nodeCode+'"><span>'+p.process+'</span></button>';
    }).join('');
    root.querySelector('[data-step="2"]').innerHTML='<div class="stw-label">Target Process</div><div class="stw-box">현재 '+mode+' process를 제외한 동일 유형의 parameter만 표시합니다. 이동할 대상 process를 선택하세요.</div><div class="stw-list stw-target-list" id="stw-target-list">'+(targetHtml||'<div class="stw-empty">선택 가능한 target process가 없습니다.</div>')+'</div><div class="stw-box" id="stw-target-selected">target process를 선택하세요.</div><div class="stw-actions"><button type="button" class="stw-btn" data-prev="1">Previous</button><button type="button" class="stw-btn primary" data-next="3">Next</button></div>';
    var targetList=root.querySelector('#stw-target-list');
    var targetButtons=targetList?Array.prototype.slice.call(targetList.querySelectorAll('.stw-target-process')):[];
    function selectTarget(btn){
      targetButtons.forEach(function(x){x.classList.remove('selected');});
      btn.classList.add('selected');
      targetProcess=btn.getAttribute('data-process')||'';
      root.querySelector('#stw-target-selected').textContent='Target process: '+targetProcess;
      update();
    }
    targetButtons.forEach(function(b){b.addEventListener('click',function(){selectTarget(b);});});
    if(targetButtons.length===1){selectTarget(targetButtons[0]);}
  }
  function showStep(n){root.querySelectorAll('.stw-panel').forEach(function(p){p.classList.toggle('active',p.getAttribute('data-step')===String(n));});root.querySelectorAll('.stw-step').forEach(function(s){s.classList.toggle('active',s.getAttribute('data-step-tab')===String(n));});}
  function candidateMeta(btn){
    return {schemaPrepared:btn.getAttribute('data-schema-prepared')||'N',tablePrepared:btn.getAttribute('data-table-prepared')||'N',pk:btn.getAttribute('data-pk-logging')||'-',ui:btn.getAttribute('data-ui-logging')||'-',fk:btn.getAttribute('data-fk-logging')||'-',all:btn.getAttribute('data-all-logging')||'-',note:btn.getAttribute('data-log-note')||''};
  }
  function selectedButtons(){return Array.prototype.slice.call(root.querySelectorAll('.stw-candidate.selected'));}
  function refreshSelected(){
    var buttons=selectedButtons();
    selectedTables=buttons.map(function(b){return b.getAttribute('data-table');});
    selected=selectedTables[0]||'';
    selectedMeta=buttons.length?candidateMeta(buttons[0]):null;
    root.querySelectorAll('.stw-candidate').forEach(function(b){var c=b.querySelector('.stw-candidate-check');if(c){c.checked=b.classList.contains('selected');}});
    root.querySelector('#stw-selected').textContent=selectedTables.length?'Selected tables ('+selectedTables.length+'): '+selectedTables.join(', '):'table 후보를 검색하고 선택하세요.';
    if(mode==='REPLICAT'){
      var srcInput=root.querySelector('#stw-source'),tgtInput=root.querySelector('#stw-target');
      if(srcInput&&tgtInput){
        if(selectedTables.length===1){srcInput.value=selected;tgtInput.value=selected;}
        else if(selectedTables.length>1){srcInput.value='multiple selected';tgtInput.value='same as source table';}
        else{srcInput.value='';tgtInput.value='';}
      }
    }
  }
  function sqlForTable(tableName){
    if(actionMode==='REMOVE'){return (mode==='EXTRACT'?'REMOVE TABLE ':'REMOVE MAP ')+tableName+';';}
    if(actionMode==='MOVE'){return (mode==='EXTRACT'?'MOVE TABLE ':'MOVE MAP ')+tableName+';';}
    if(mode==='EXTRACT'){return 'TABLE '+tableName+';';}
    var tgt=root.querySelector('#stw-target'), col=root.querySelector('#stw-colmap');
    var target=(selectedTables.length===1&&tgt&&tgt.value&&tgt.value.indexOf('multiple selected')<0&&tgt.value.indexOf('same as source')<0)?tgt.value:tableName;
    var colmap=(selectedTables.length===1&&col)?(col.value||'').trim():'';
    return 'MAP '+tableName+', TARGET '+target+(colmap?', COLMAP ('+colmap+')':'')+';';
  }
  function selectedSql(){return selectedTables.map(sqlForTable).join('\n');}
  function extractLoggingOk(){
    return selectedButtons().every(function(b){var m=candidateMeta(b);return m.schemaPrepared==='Y'||m.tablePrepared==='Y';});
  }
  function update(){
    refreshSelected();
    if(actionMode==='REMOVE'){
      supplementalOk='Y';
      currentSql=selectedSql();
      var impact=mode==='EXTRACT'?'이 테이블의 CDC capture가 중단됩니다.':'이 테이블의 target apply가 중단됩니다.';
      root.querySelector('#stw-summary').textContent=selectedTables.length?'REMOVE preview\nProcess: '+processName+'\nSelected count: '+selectedTables.length+'\n'+currentSql+'\n\nImpact: '+impact+'\nConfirm 단계에서 선택한 TABLE/MAP별 change request를 순차 적용합니다.':'아직 선택된 table이 없습니다.';
      var check=root.querySelector('#stw-check');
      if(check){check.className='stw-box warn';check.textContent=selectedTables.length?'WARNING: '+selectedTables.join(', ')+'\n'+impact+'\nPRM 백업 후 선택한 TABLE/MAP 줄을 제거하고 process restart가 필요합니다.':'제거할 table을 선택하세요.';}
      return;
    }
    if(actionMode==='MOVE'){
      supplementalOk='Y';
      currentSql=selectedSql();
      root.querySelector('#stw-summary').textContent=selectedTables.length?'MOVE preview\nSource process: '+processName+'\nTarget process: '+(targetProcess||'not selected')+'\nSelected count: '+selectedTables.length+'\n'+currentSql+'\n\nApply 단계에서 선택한 TABLE/MAP별로 source parameter에서는 제거하고 target parameter에는 추가한 뒤 process를 restart합니다.':'아직 선택된 table이 없습니다.';
      return;
    }
    if(mode==='EXTRACT'){
      var ok=selectedTables.length&&extractLoggingOk();
      supplementalOk=ok?'Y':'N';
      currentSql=selectedSql();
      root.querySelector('#stw-check').className='stw-box '+(selectedTables.length?(ok?'ok':'warn'):'');
      root.querySelector('#stw-check').textContent=selectedTables.length?(ok?'OK: ':'WARNING: ')+selectedTables.join(', ')+'\nSelected count: '+selectedTables.length+'\nSupplemental logging: '+(ok?'PASS':'CHECK REQUIRED')+'\nSource: demo_osrc_23ai dictionary cache':'table을 선택하면 supplemental logging 확인 결과를 표시합니다.';
      root.querySelector('#stw-summary').textContent=selectedTables.length?'EXTRACT TABLE preview\nProcess: '+processName+'\n'+currentSql+'\n\nSupplemental logging: '+(ok?'PASS':'CHECK REQUIRED')+'\nConfirm 단계에서 선택한 TABLE별 change request를 순차 적용합니다.':'아직 선택된 table이 없습니다.';
    }else{
      supplementalOk='Y';
      currentSql=selectedSql();
      root.querySelector('#stw-map-preview').textContent=currentSql||'table을 선택하면 MAP preview를 표시합니다.';
      root.querySelector('#stw-summary').textContent=selectedTables.length?'REPLICAT MAP preview\nProcess: '+processName+'\nSelected count: '+selectedTables.length+'\n'+currentSql+'\n\nConfirm 단계에서 선택한 MAP별 change request를 순차 적용합니다.':'아직 선택된 table이 없습니다.';
    }
  }
  root.querySelector('#stw-search').addEventListener('input',function(){var q=this.value.toUpperCase();root.querySelectorAll('.stw-candidate').forEach(function(b){b.style.display=(b.getAttribute('data-table').indexOf(q)>=0)?'flex':'none';});});
  root.querySelectorAll('.stw-candidate').forEach(function(b){b.addEventListener('click',function(){b.classList.toggle('selected');update();});});
  root.querySelectorAll('[data-next]').forEach(function(b){b.addEventListener('click',function(){update();if(!selectedTables.length){root.querySelector('#stw-selected').textContent='먼저 table을 하나 이상 선택하세요.';return;}if(actionMode==='MOVE'&&b.getAttribute('data-next')==='3'&&!targetProcess){var ts=root.querySelector('#stw-target-selected');if(ts){ts.textContent='먼저 target process를 선택하세요.';}return;}showStep(b.getAttribute('data-next'));});});
  root.querySelectorAll('[data-prev]').forEach(function(b){b.addEventListener('click',function(){showStep(b.getAttribute('data-prev'));});});
  root.querySelector('#stw-back-canvas').addEventListener('click',function(){window.location.href=canvasUrl();});
  ['stw-target','stw-colmap'].forEach(function(id){var el=root.querySelector('#'+id);if(el){el.addEventListener('input',update);}});
  root.querySelector('#stw-apply').addEventListener('click',function(){
    var result=root.querySelector('#stw-result');
    var applyButton=root.querySelector('#stw-apply');
    if(applyButton.disabled){return;}
    update();
    if(!selectedTables.length||!currentSql){result.style.display='block';result.textContent='먼저 table을 하나 이상 선택하고 Summary를 확인하세요.';return;}
    if(actionMode==='MOVE'&&!targetProcess){result.style.display='block';result.textContent='먼저 target process를 선택하세요.';return;}
    if(actionMode==='MOVE'&&targetProcess===processName){result.style.display='block';result.textContent='source와 target process가 같습니다. 다른 target process를 선택하세요.';return;}
    if(mode==='EXTRACT'&&supplementalOk!=='Y'){result.style.display='block';result.textContent='Supplemental logging 확인이 통과되지 않아 change request를 만들 수 없습니다.';return;}
    if(!window.apex||!apex.server){result.style.display='block';result.textContent='APEX runtime을 찾을 수 없습니다.';return;}
    applyButton.disabled=true;
    applyButton.classList.add('disabled');
    applyButton.textContent='Applying...';
    result.style.display='block';
    result.textContent='변경을 적용하는 중입니다. 선택한 TABLE/MAP을 순차 처리합니다.';
    var todo=selectedTables.slice(), done=[];
    function applyOne(i){
      if(i>=todo.length){
        applyButton.textContent='Applied';
        root.querySelector('#stw-back-canvas').classList.add('primary');
        root.querySelector('#stw-back-canvas').textContent='Canvas Design';
        result.textContent='Applied successfully\nAction: '+actionMode+'\nApplied count: '+done.length+'\nRequests: '+done.map(function(d){return '#'+d.request_id+' '+d.source_table;}).join(', ');
        return;
      }
      var tableName=todo[i], sql=sqlForTable(tableName);
      result.textContent='Applying '+(i+1)+'/'+todo.length+': '+tableName+'\n'+done.map(function(d){return 'OK #'+d.request_id+' '+d.source_table;}).join('\n');
      apex.server.process('APPLY_FABRIC_CHANGE',{
        x01:processName,
        x02:mode,
        x03:tableName,
        x04:sql,
        x05:supplementalOk,
        x06:(mode==='REPLICAT'&&actionMode==='ADD'?(todo.length===1&&root.querySelector('#stw-target')?root.querySelector('#stw-target').value:tableName):''),
        x07:(todo.length===1&&root.querySelector('#stw-colmap')?root.querySelector('#stw-colmap').value:''),
        x08:targetProcess,
        x09:actionMode
      },{
        dataType:'json',
        success:function(data){data.source_table=tableName;done.push(data);applyOne(i+1);},
        error:function(jq){
        applyButton.disabled=false;
        applyButton.classList.remove('disabled');
        applyButton.textContent='Apply Change';
          result.textContent='변경 적용 실패: '+tableName+'\n'+(jq.responseText||jq.statusText||'unknown error')+'\nCompleted: '+done.length+'/'+todo.length;
        }
      });
    }
    applyOne(0);
  });
})();
</script></section>~';

    return l_html;
  end render_set_table_wizard;
end fabric_designer_pkg;
/
show errors package body ggadmin.fabric_designer_pkg

grant select on ggadmin.fabric_node to apex_260100;
grant select on ggadmin.fabric_edge to apex_260100;
grant select on ggadmin.fabric_node_property to apex_260100;
grant select on ggadmin.fabric_table_column to apex_260100;
grant select on ggadmin.fabric_supplemental_log to apex_260100;
grant execute on ggadmin.fabric_designer_pkg to apex_260100;
-- END APP101 FABRIC SUPPORTING OBJECTS

prompt --application/set_environment
declare
  l_workspace_id number;
begin
  select workspace_id
    into l_workspace_id
    from apex_workspaces
   where workspace = 'OGG';

  apex_util.set_security_group_id(l_workspace_id);
  wwv_flow_imp.import_begin (
   p_version_yyyy_mm_dd=>'2026.03.30'
  ,p_release=>'26.1.0'
  ,p_default_workspace_id=>l_workspace_id
  ,p_default_application_id=>101
  ,p_default_id_offset=>10228337575640159
  ,p_default_owner=>'GGADMIN'
  );
end;
/

begin
  delete from apex_260100.wwv_flow_list_items
   where flow_id = 101
     and static_id in (
	       'data-fabric',
	       'data-fabric-designer',
	       'data-fabric-canvas',
	       'data-fabric-canvas-design',
	       'data-fabric-catalog',
	       'data-fabric-assets',
	       'data-fabric-pipelines',
       'data-fabric-data-products',
       'data-fabric-lineage',
       'data-fabric-runtime-status',
       'data-fabric-governance',
       'app-mesh-graph'
     );
	  delete from apex_260100.wwv_flow_menu_options
	   where flow_id = 101
	     and static_id in ('bc-data-fabric-designer','bc-data-fabric-canvas','bc-data-fabric-canvas-design');
  commit;
exception
  when others then
    null;
end;
/

prompt --application/shared_components/navigation/data_fabric
declare
	  c_flow_id constant number := 101;
	  l_parent_id number := apex_260100.wwv_flow_id.next_val;
	  l_child_id  number;
	  l_bc_id     number := apex_260100.wwv_flow_id.next_val;
	  l_bc_canvas_design_id number := apex_260100.wwv_flow_id.next_val;
  l_nav_source_where varchar2(4000);
  l_bc_source_where  varchar2(4000);
  l_sql    varchar2(32767);
  l_cols   varchar2(32767);
  l_exprs  varchar2(32767);

  type t_map is table of varchar2(4000) index by varchar2(128);
  m t_map;

  function q(v varchar2) return varchar2 is
  begin
    return '''' || replace(v, '''', '''''') || '''';
  end;

  procedure put(c varchar2, v varchar2) is
  begin
    m(upper(c)) := v;
  end;

  procedure copy_row(t varchar2, w varchar2) is
  begin
    l_cols := null;
    l_exprs := null;
    for r in (
      select column_name
        from all_tab_cols
       where owner = 'APEX_260100'
         and table_name = upper(t)
         and virtual_column = 'NO'
         and hidden_column = 'NO'
       order by column_id
    ) loop
      if l_cols is not null then
        l_cols := l_cols || ',';
        l_exprs := l_exprs || ',';
      end if;
      l_cols := l_cols || r.column_name;
      l_exprs := l_exprs || case when m.exists(r.column_name) then m(r.column_name) else r.column_name end;
    end loop;

    l_sql := 'insert into apex_260100.' || t || ' (' || l_cols || ') select ' || l_exprs ||
             ' from apex_260100.' || t || ' where ' || w;
    execute immediate l_sql;
    if sql%rowcount <> 1 then
      raise_application_error(-20900, 'Expected one source row for ' || t || ', got ' || sql%rowcount);
    end if;
  end;

  procedure add_nav(
    p_static_id varchar2,
    p_seq number,
    p_text varchar2,
    p_target varchar2,
    p_icon varchar2,
    p_parent number,
    p_pages varchar2
  ) is
  begin
    l_child_id := apex_260100.wwv_flow_id.next_val;
    m.delete;
    put('ID', to_char(l_child_id));
    put('LIST_ITEM_DISPLAY_SEQUENCE', to_char(p_seq));
    put('LIST_ITEM_LINK_TEXT', q(p_text));
    put('STATIC_ID', q(p_static_id));
    put('LIST_ITEM_LINK_TARGET', q(p_target));
    put('LIST_ITEM_ICON', q(p_icon));
    if p_parent is not null then
      put('PARENT_LIST_ITEM_ID', to_char(p_parent));
    else
      put('PARENT_LIST_ITEM_ID', 'null');
    end if;
    put('LIST_ITEM_CURRENT_FOR_PAGES', q(p_pages));
    put('LIST_ITEM_CURRENT_TYPE', q('COLON_DELIMITED_PAGE_LIST'));
    put('CREATED_BY', q('CODEX'));
    put('CREATED_ON', 'sysdate');
    put('LAST_UPDATED_BY', q('CODEX'));
    put('LAST_UPDATED_ON', 'sysdate');
    copy_row('WWV_FLOW_LIST_ITEMS', l_nav_source_where);
  end;
begin
  l_nav_source_where := 'flow_id = 101 and static_id = ''data-streams''';
  l_bc_source_where := 'id = (select min(id) from apex_260100.wwv_flow_menu_options where flow_id = 101)';

  m.delete;
  put('ID', to_char(l_parent_id));
  put('LIST_ITEM_DISPLAY_SEQUENCE', '235');
  put('LIST_ITEM_LINK_TEXT', q('Data Fabric'));
  put('STATIC_ID', q('data-fabric'));
  put('LIST_ITEM_LINK_TARGET', q('#'));
  put('LIST_ITEM_ICON', q('fa-project-diagram'));
	  put('PARENT_LIST_ITEM_ID', 'null');
		  put('LIST_ITEM_CURRENT_FOR_PAGES', q('200:202'));
		  put('LIST_ITEM_CURRENT_TYPE', q('COLON_DELIMITED_PAGE_LIST'));
		  put('SUB_ITEM_COUNT', '9');
  put('CREATED_BY', q('CODEX'));
  put('CREATED_ON', 'sysdate');
  put('LAST_UPDATED_BY', q('CODEX'));
  put('LAST_UPDATED_ON', 'sysdate');
		  copy_row('WWV_FLOW_LIST_ITEMS', l_nav_source_where);

		  add_nav('data-fabric-designer', 10, 'Designer', 'f?p=&APP_ID.:200:&SESSION.::&DEBUG.:::#df-designer', 'fa-object-group', l_parent_id, '200');
		  add_nav('data-fabric-canvas-design', 30, 'Canvas Design', 'f?p=&APP_ID.:202:&SESSION.::&DEBUG.:::', 'fa-sitemap', l_parent_id, '202');
		  add_nav('data-fabric-catalog', 40, 'Catalog', 'f?p=&APP_ID.:200:&SESSION.::&DEBUG.:::#df-catalog', 'fa-search', l_parent_id, '200');
		  add_nav('data-fabric-assets', 50, 'Assets', 'f?p=&APP_ID.:200:&SESSION.::&DEBUG.:::#df-assets', 'fa-database', l_parent_id, '200');
		  add_nav('data-fabric-pipelines', 60, 'Pipelines', 'f?p=&APP_ID.:200:&SESSION.::&DEBUG.:::#df-pipelines', 'fa-random', l_parent_id, '200');
		  add_nav('data-fabric-data-products', 70, 'Data Products', 'f?p=&APP_ID.:200:&SESSION.::&DEBUG.:::#df-products', 'fa-cubes', l_parent_id, '200');
		  add_nav('data-fabric-lineage', 80, 'Lineage', 'f?p=&APP_ID.:200:&SESSION.::&DEBUG.:::#df-lineage', 'fa-sitemap', l_parent_id, '200');
		  add_nav('data-fabric-runtime-status', 90, 'Runtime Status', 'f?p=&APP_ID.:200:&SESSION.::&DEBUG.:::#df-runtime', 'fa-dashboard', l_parent_id, '200');
		  add_nav('data-fabric-governance', 100, 'Governance', 'f?p=&APP_ID.:200:&SESSION.::&DEBUG.:::#df-governance', 'fa-shield', l_parent_id, '200');

  m.delete;
  put('ID', to_char(l_bc_id));
  put('SHORT_NAME', q('Data Fabric Designer'));
  put('STATIC_ID', q('bc-data-fabric-designer'));
  put('LINK', q('f?p=&APP_ID.:200:&SESSION.::&DEBUG.:::'));
  put('PAGE_ID', '200');
  put('CREATED_BY', q('CODEX'));
  put('CREATED_ON', 'sysdate');
  put('LAST_UPDATED_BY', q('CODEX'));
		  put('LAST_UPDATED_ON', 'sysdate');
		  copy_row('WWV_FLOW_MENU_OPTIONS', l_bc_source_where);

		  m.delete;
		  put('ID', to_char(l_bc_canvas_design_id));
		  put('SHORT_NAME', q('Data Fabric Canvas Design'));
		  put('STATIC_ID', q('bc-data-fabric-canvas-design'));
		  put('LINK', q('f?p=&APP_ID.:202:&SESSION.::&DEBUG.:::'));
		  put('PAGE_ID', '202');
		  put('CREATED_BY', q('CODEX'));
		  put('CREATED_ON', 'sysdate');
		  put('LAST_UPDATED_BY', q('CODEX'));
		  put('LAST_UPDATED_ON', 'sysdate');
		  copy_row('WWV_FLOW_MENU_OPTIONS', l_bc_source_where);

  commit;
end;
/

prompt --application/pages/delete_00200
begin
  begin
    wwv_flow_imp_page.remove_page (p_flow_id=>wwv_flow.g_flow_id, p_page_id=>200);
  exception
    when others then
      null;
  end;
end;
/

prompt --application/pages/delete_00201
begin
  begin
    wwv_flow_imp_page.remove_page (p_flow_id=>wwv_flow.g_flow_id, p_page_id=>201);
  exception
    when others then
      null;
  end;
end;
/

prompt --application/pages/delete_00202
begin
  begin
    wwv_flow_imp_page.remove_page (p_flow_id=>wwv_flow.g_flow_id, p_page_id=>202);
  exception
    when others then
      null;
  end;
end;
/

prompt --application/pages/delete_00203
begin
  begin
    wwv_flow_imp_page.remove_page (p_flow_id=>wwv_flow.g_flow_id, p_page_id=>203);
  exception
    when others then
      null;
  end;
end;
/

prompt --application/pages/page_00200
declare
  l_page_template number;
  l_region_template number;
begin
  select step_template
    into l_page_template
    from apex_260100.wwv_flow_steps
   where flow_id = 101
     and id = 1;

  select plug_template
    into l_region_template
    from apex_260100.wwv_flow_page_plugs
   where flow_id = 101
     and page_id = 1
     and static_id = 'ogg-ops-command-center';

  wwv_flow_imp_page.create_page(
    p_id                      => 200,
    p_name                    => 'Data Fabric Designer',
    p_alias                   => 'DATA-FABRIC-DESIGNER',
    p_step_title              => 'Data Fabric Designer',
    p_warn_on_unsaved_changes => 'N',
    p_autocomplete_on_off     => 'OFF',
    p_step_template           => l_page_template,
    p_page_template_options   => '#DEFAULT#',
    p_protection_level        => 'C',
    p_page_component_map      => '27'
  );

  wwv_flow_imp_page.create_page_plug(
    p_id                      => wwv_flow_imp.id(2000000000000001),
    p_plug_name               => 'Data Fabric Designer',
    p_static_id               => 'data-fabric-designer',
    p_escape_on_http_output   => 'N',
    p_plug_template           => l_region_template,
    p_plug_display_sequence   => 10,
    p_plug_item_display_point => 'ABOVE',
    p_location                => null,
    p_plug_source             => wwv_flow_string.join(wwv_flow_t_varchar2(
      'declare',
      '  l_html clob;',
      '  l_pos pls_integer := 1;',
      '  l_len pls_integer;',
      'begin',
      '  l_html := ggadmin.fabric_designer_pkg.render;',
      '  l_len := dbms_lob.getlength(l_html);',
      '  while l_pos <= l_len loop',
      '    sys.htp.prn(dbms_lob.substr(l_html, 30000, l_pos));',
      '    l_pos := l_pos + 30000;',
      '  end loop;',
      'exception',
      '  when others then',
      '    sys.htp.prn(''<div class="t-Alert t-Alert--danger"><div class="t-Alert-body">Data Fabric Designer renderer failed: '' || apex_escape.html(sqlerrm) || ''</div></div>'');',
      'end;'
    )),
    p_plug_source_type        => 'NATIVE_PLSQL'
  );
end;
/

prompt --application/pages/page_00202
declare
  l_page_template number;
  l_region_template number;
begin
  select step_template
    into l_page_template
    from apex_260100.wwv_flow_steps
   where flow_id = 101
     and id = 1;

  select plug_template
    into l_region_template
    from apex_260100.wwv_flow_page_plugs
   where flow_id = 101
     and page_id = 1
     and static_id = 'ogg-ops-command-center';

  wwv_flow_imp_page.create_page(
    p_id                      => 202,
    p_name                    => 'Data Fabric Canvas Design',
    p_alias                   => 'DATA-FABRIC-CANVAS-DESIGN',
    p_step_title              => 'Data Fabric Canvas Design',
    p_warn_on_unsaved_changes => 'N',
    p_autocomplete_on_off     => 'OFF',
    p_step_template           => l_page_template,
    p_page_template_options   => '#DEFAULT#',
    p_protection_level        => 'C',
    p_page_component_map      => '27'
  );

  wwv_flow_imp_page.create_page_plug(
    p_id                      => wwv_flow_imp.id(2020000000000001),
    p_plug_name               => 'Data Fabric Canvas Design',
    p_static_id               => 'data-fabric-canvas-design',
    p_escape_on_http_output   => 'N',
    p_plug_template           => l_region_template,
    p_plug_display_sequence   => 10,
    p_plug_item_display_point => 'ABOVE',
    p_location                => null,
    p_plug_source             => wwv_flow_string.join(wwv_flow_t_varchar2(
      'declare',
      '  l_html clob;',
      '  l_pos pls_integer := 1;',
      '  l_len pls_integer;',
      'begin',
      '  l_html := ggadmin.fabric_designer_pkg.render_canvas_design;',
      '  l_len := dbms_lob.getlength(l_html);',
      '  while l_pos <= l_len loop',
      '    sys.htp.prn(dbms_lob.substr(l_html, 30000, l_pos));',
      '    l_pos := l_pos + 30000;',
      '  end loop;',
      'exception',
      '  when others then',
      '    sys.htp.prn(''<div class="t-Alert t-Alert--danger"><div class="t-Alert-body">Data Fabric Canvas Design renderer failed: '' || apex_escape.html(sqlerrm) || ''</div></div>'');',
      'end;'
    )),
    p_plug_source_type        => 'NATIVE_PLSQL'
  );

  wwv_flow_imp_page.create_page_process(
    p_id                      => wwv_flow_imp.id(2020000000000002),
    p_process_sequence        => 10,
    p_process_point           => 'ON_DEMAND',
    p_process_type            => 'NATIVE_PLSQL',
    p_process_name            => 'REFRESH_FABRIC_METADATA',
    p_static_id               => 'refresh-fabric-metadata',
    p_process_sql_clob        => wwv_flow_string.join(wwv_flow_t_varchar2(
      'declare',
      '  l_resp clob;',
      '  l_nodes number;',
      '  l_edges number;',
      'begin',
      '  apex_web_service.set_request_headers(',
      '    p_name_01 => ''X-Fabric-Token'',',
      '    p_value_01 => ''lab20-fabric-apply-token'',',
      '    p_reset => true);',
      '  l_resp := apex_web_service.make_rest_request(',
      '    p_url => ''http://demo_ogg_23ai:18091/metadata'',',
      '    p_http_method => ''GET'');',
      '',
      '  if apex_web_service.g_status_code < 200 or apex_web_service.g_status_code >= 300 then',
      '    raise_application_error(-20000, ''Metadata helper failed: '' || dbms_lob.substr(l_resp, 1000, 1));',
      '  end if;',
      '',
      '  delete from ggadmin.fabric_edge',
      '   where edge_code like ''DISC_%''',
      '      or from_node_code in (select node_code from ggadmin.fabric_node where node_type in (''OGG_EXTRACT'',''TRAIL'',''OGG_REPLICAT''))',
      '      or to_node_code in (select node_code from ggadmin.fabric_node where node_type in (''OGG_EXTRACT'',''TRAIL'',''OGG_REPLICAT''));',
      '  delete from ggadmin.fabric_node_property',
      '   where node_code in (select node_code from ggadmin.fabric_node where node_type in (''OGG_EXTRACT'',''TRAIL'',''OGG_REPLICAT''));',
      '  delete from ggadmin.fabric_node',
      '   where node_type in (''OGG_EXTRACT'',''TRAIL'',''OGG_REPLICAT'');',
      '',
      '  insert into ggadmin.fabric_node (node_code, node_name, node_type, domain_name, system_name, layer_no, display_order, status, resource_ref, description)',
      '  select node_code, node_name, node_type, domain_name, system_name, layer_no, display_order, status, resource_ref, description',
      '    from json_table(l_resp, ''$.nodes[*]'' columns (',
      '      node_code varchar2(80) path ''$.node_code'',',
      '      node_name varchar2(200) path ''$.node_name'',',
      '      node_type varchar2(40) path ''$.node_type'',',
      '      domain_name varchar2(100) path ''$.domain_name'',',
      '      system_name varchar2(100) path ''$.system_name'',',
      '      layer_no number path ''$.layer_no'',',
      '      display_order number path ''$.display_order'',',
      '      status varchar2(30) path ''$.status'',',
      '      resource_ref varchar2(500) path ''$.resource_ref'',',
      '      description varchar2(1000) path ''$.description''',
      '    ));',
      '  l_nodes := sql%rowcount;',
      '',
      '  insert into ggadmin.fabric_node_property (node_code, property_name, property_value)',
      '  select node_code, property_name, property_value',
      '    from json_table(l_resp, ''$.properties[*]'' columns (',
      '      node_code varchar2(80) path ''$.node_code'',',
      '      property_name varchar2(100) path ''$.property_name'',',
      '      property_value varchar2(1000) path ''$.property_value''',
      '    ));',
      '',
      '  insert into ggadmin.fabric_edge (edge_code, from_node_code, to_node_code, edge_type, mapping_ref, status, description)',
      '  select edge_code, from_node_code, to_node_code, edge_type, mapping_ref, status, description',
      '    from json_table(l_resp, ''$.edges[*]'' columns (',
      '      edge_code varchar2(100) path ''$.edge_code'',',
      '      from_node_code varchar2(80) path ''$.from_node_code'',',
      '      to_node_code varchar2(80) path ''$.to_node_code'',',
      '      edge_type varchar2(40) path ''$.edge_type'',',
      '      mapping_ref varchar2(500) path ''$.mapping_ref'',',
      '      status varchar2(30) path ''$.status'',',
      '      description varchar2(1000) path ''$.description''',
      '    ));',
      '  l_edges := sql%rowcount;',
      '',
      '  insert into ggadmin.fabric_edge (edge_code, from_node_code, to_node_code, edge_type, mapping_ref, status, description)',
      '  select ''E_TRAIL_K2_TO_DS_LAKE'', ''OGG_TRAIL_K2'', ''OGG_DATA_STREAM_DS_LAKE'', ''PUBLISH_STREAM'', ''trail k2 -> DS_LAKE'', ''ACTIVE'', ''Data Streams가 heavy lane trail을 stream으로 제공''',
      '    from dual',
      '   where exists (select 1 from ggadmin.fabric_node where node_code = ''OGG_TRAIL_K2'')',
      '     and exists (select 1 from ggadmin.fabric_node where node_code = ''OGG_DATA_STREAM_DS_LAKE'');',
      '',
      '  commit;',
      '  apex_json.open_object;',
      '  apex_json.write(''status'', ''REFRESHED'');',
      '  apex_json.write(''nodes'', l_nodes);',
      '  apex_json.write(''edges'', l_edges);',
      '  apex_json.close_object;',
      'exception',
      '  when others then',
      '    rollback;',
      '    apex_json.open_object;',
      '    apex_json.write(''error'', sqlerrm);',
      '    apex_json.close_object;',
      '    raise;',
      'end;'
    )),
    p_process_clob_language   => 'PLSQL',
    p_error_display_location  => 'INLINE_IN_NOTIFICATION'
  );

  wwv_flow_imp_page.create_page_process(
    p_id                      => wwv_flow_imp.id(2020000000000003),
    p_process_sequence        => 20,
    p_process_point           => 'ON_DEMAND',
    p_process_type            => 'NATIVE_PLSQL',
    p_process_name            => 'CREATE_FABRIC_LANE',
    p_static_id               => 'create-fabric-lane',
    p_process_sql_clob        => wwv_flow_string.join(wwv_flow_t_varchar2(
      'declare',
      '  l_body clob;',
      '  l_resp clob;',
      'begin',
      '  apex_json.initialize_clob_output;',
      '  apex_json.open_object;',
      '  apex_json.write(''extract_name'', upper(apex_application.g_x01));',
      '  apex_json.write(''trail_name'', apex_application.g_x02);',
      '  apex_json.write(''useridalias'', nvl(apex_application.g_x03, ''src_ogg''));',
      '  apex_json.write(''parameter_text'', apex_application.g_x04);',
      '  apex_json.write(''tables'', apex_application.g_x05);',
      '  apex_json.close_object;',
      '  l_body := apex_json.get_clob_output;',
      '  apex_json.free_output;',
      '',
      '  apex_web_service.set_request_headers(',
      '    p_name_01 => ''Content-Type'', p_value_01 => ''application/json'',',
      '    p_name_02 => ''X-Fabric-Token'', p_value_02 => ''lab20-fabric-apply-token'',',
      '    p_reset => true);',
      '  l_resp := apex_web_service.make_rest_request(',
      '    p_url => ''http://demo_ogg_23ai:18091/create-lane'',',
      '    p_http_method => ''POST'',',
      '    p_body => l_body);',
      '',
      '  if apex_web_service.g_status_code < 200 or apex_web_service.g_status_code >= 300 then',
      '    raise_application_error(-20000, ''Create lane helper failed: '' || dbms_lob.substr(l_resp, 1000, 1));',
      '  end if;',
      '',
      '  sys.htp.prn(l_resp);',
      'exception',
      '  when others then',
      '    apex_json.open_object;',
      '    apex_json.write(''error'', sqlerrm);',
      '    apex_json.close_object;',
      '    raise;',
      'end;'
    )),
    p_process_clob_language   => 'PLSQL',
    p_error_display_location  => 'INLINE_IN_NOTIFICATION'
  );

  wwv_flow_imp_page.create_page_process(
    p_id                      => wwv_flow_imp.id(2020000000000004),
    p_process_sequence        => 30,
    p_process_point           => 'ON_DEMAND',
    p_process_type            => 'NATIVE_PLSQL',
    p_process_name            => 'CREATE_REPLICAT_LANE',
    p_static_id               => 'create-replicat-lane',
    p_process_sql_clob        => wwv_flow_string.join(wwv_flow_t_varchar2(
      'declare',
      '  l_body clob;',
      '  l_resp clob;',
      'begin',
      '  apex_json.initialize_clob_output;',
      '  apex_json.open_object;',
      '  apex_json.write(''replicat_name'', upper(apex_application.g_x01));',
      '  apex_json.write(''mode'', apex_application.g_x02);',
      '  apex_json.write(''useridalias'', nvl(apex_application.g_x03, ''trg_ogg''));',
      '  apex_json.write(''trail_name'', apex_application.g_x04);',
      '  apex_json.write(''tables'', apex_application.g_x05);',
      '  apex_json.write(''parameter_text'', apex_application.g_x06);',
      '  apex_json.write(''max_sga_size'', apex_application.g_x07);',
      '  apex_json.write(''parallelism'', apex_application.g_x08);',
      '  apex_json.write(''threads'', apex_application.g_x09);',
      '  apex_json.write(''map_parallelism'', apex_application.g_x10);',
      '  apex_json.close_object;',
      '  l_body := apex_json.get_clob_output;',
      '  apex_json.free_output;',
      '',
      '  apex_web_service.set_request_headers(',
      '    p_name_01 => ''Content-Type'', p_value_01 => ''application/json'',',
      '    p_name_02 => ''X-Fabric-Token'', p_value_02 => ''lab20-fabric-apply-token'',',
      '    p_reset => true);',
      '  l_resp := apex_web_service.make_rest_request(',
      '    p_url => ''http://demo_ogg_23ai:18091/create-replicat-lane'',',
      '    p_http_method => ''POST'',',
      '    p_body => l_body);',
      '',
      '  if apex_web_service.g_status_code < 200 or apex_web_service.g_status_code >= 300 then',
      '    raise_application_error(-20000, ''Create replicat lane helper failed: '' || dbms_lob.substr(l_resp, 1000, 1));',
      '  end if;',
      '',
      '  sys.htp.prn(l_resp);',
      'exception',
      '  when others then',
      '    apex_json.open_object;',
      '    apex_json.write(''error'', sqlerrm);',
      '    apex_json.close_object;',
      '    raise;',
      'end;'
    )),
    p_process_clob_language   => 'PLSQL',
    p_error_display_location  => 'INLINE_IN_NOTIFICATION'
  );

  wwv_flow_imp_page.create_page_process(
    p_id                      => wwv_flow_imp.id(2020000000000005),
    p_process_sequence        => 40,
    p_process_point           => 'ON_DEMAND',
    p_process_type            => 'NATIVE_PLSQL',
    p_process_name            => 'DROP_FABRIC_PROCESS',
    p_static_id               => 'drop-fabric-process',
    p_process_sql_clob        => wwv_flow_string.join(wwv_flow_t_varchar2(
      'declare',
      '  l_body clob;',
      '  l_resp clob;',
      'begin',
      '  apex_json.initialize_clob_output;',
      '  apex_json.open_object;',
      '  apex_json.write(''process_name'', upper(apex_application.g_x01));',
      '  apex_json.write(''process_type'', apex_application.g_x02);',
      '  apex_json.write(''useridalias'', apex_application.g_x03);',
      '  apex_json.write(''trail_name'', apex_application.g_x04);',
      '  apex_json.close_object;',
      '  l_body := apex_json.get_clob_output;',
      '  apex_json.free_output;',
      '',
      '  apex_web_service.set_request_headers(',
      '    p_name_01 => ''Content-Type'', p_value_01 => ''application/json'',',
      '    p_name_02 => ''X-Fabric-Token'', p_value_02 => ''lab20-fabric-apply-token'',',
      '    p_reset => true);',
      '  l_resp := apex_web_service.make_rest_request(',
      '    p_url => ''http://demo_ogg_23ai:18091/drop-process'',',
      '    p_http_method => ''POST'',',
      '    p_body => l_body);',
      '',
      '  if apex_web_service.g_status_code < 200 or apex_web_service.g_status_code >= 300 then',
      '    raise_application_error(-20000, ''Drop process helper failed: '' || dbms_lob.substr(l_resp, 1000, 1));',
      '  end if;',
      '',
      '  sys.htp.prn(l_resp);',
      'exception',
      '  when others then',
      '    apex_json.open_object;',
      '    apex_json.write(''error'', sqlerrm);',
      '    apex_json.close_object;',
      '    raise;',
      'end;'
    )),
    p_process_clob_language   => 'PLSQL',
    p_error_display_location  => 'INLINE_IN_NOTIFICATION'
  );
end;
/

prompt --application/pages/page_00203
declare
  l_page_template number;
  l_region_template number;
begin
  select step_template
    into l_page_template
    from apex_260100.wwv_flow_steps
   where flow_id = 101
     and id = 1;

  select plug_template
    into l_region_template
    from apex_260100.wwv_flow_page_plugs
   where flow_id = 101
     and page_id = 1
     and static_id = 'ogg-ops-command-center';

  wwv_flow_imp_page.create_page(
    p_id                      => 203,
    p_name                    => 'Data Fabric Set Table Wizard',
    p_alias                   => 'DATA-FABRIC-SET-TABLE-WIZARD',
    p_step_title              => 'Data Fabric Set Table Wizard',
    p_warn_on_unsaved_changes => 'N',
    p_autocomplete_on_off     => 'OFF',
    p_step_template           => l_page_template,
    p_page_template_options   => '#DEFAULT#',
    p_protection_level        => 'C',
    p_page_component_map      => '27'
  );

  wwv_flow_imp_page.create_page_plug(
    p_id                      => wwv_flow_imp.id(2030000000000001),
    p_plug_name               => 'Data Fabric Set Table Wizard',
    p_static_id               => 'data-fabric-set-table-wizard',
    p_escape_on_http_output   => 'N',
    p_plug_template           => l_region_template,
    p_plug_display_sequence   => 10,
    p_plug_item_display_point => 'ABOVE',
    p_location                => null,
    p_plug_source             => wwv_flow_string.join(wwv_flow_t_varchar2(
      'declare',
      '  l_html clob;',
      '  l_pos pls_integer := 1;',
      '  l_len pls_integer;',
      'begin',
      '  l_html := ggadmin.fabric_designer_pkg.render_set_table_wizard(:P203_NODE_CODE);',
      '  l_len := dbms_lob.getlength(l_html);',
      '  while l_pos <= l_len loop',
      '    sys.htp.prn(dbms_lob.substr(l_html, 30000, l_pos));',
      '    l_pos := l_pos + 30000;',
      '  end loop;',
      'exception',
      '  when others then',
      '    sys.htp.prn(''<div class="t-Alert t-Alert--danger"><div class="t-Alert-body">Data Fabric Set Table Wizard renderer failed: '' || apex_escape.html(sqlerrm) || ''</div></div>'');',
      'end;'
    )),
    p_plug_source_type        => 'NATIVE_PLSQL'
  );

  wwv_flow_imp_page.create_page_item(
    p_id                      => wwv_flow_imp.id(2030000000000002),
    p_name                    => 'P203_NODE_CODE',
    p_item_sequence           => 10,
    p_source_type             => 'ALWAYS_NULL',
    p_display_as              => 'NATIVE_HIDDEN',
    p_attributes              => wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
      'value_protected', 'N')).to_clob
  );

  wwv_flow_imp_page.create_page_process(
    p_id                      => wwv_flow_imp.id(2030000000000003),
    p_process_sequence        => 10,
    p_process_point           => 'ON_DEMAND',
    p_process_type            => 'NATIVE_PLSQL',
    p_process_name            => 'APPLY_FABRIC_CHANGE',
    p_static_id               => 'apply-fabric-change',
    p_process_sql_clob        => wwv_flow_string.join(wwv_flow_t_varchar2(
      'declare',
      '  l_request_id number;',
      '  l_restart_plan varchar2(1000);',
      '  l_body clob;',
      '  l_resp clob;',
      '  l_backup varchar2(1000);',
      '  l_process varchar2(100);',
      '  l_target_process varchar2(100);',
      '  l_tables varchar2(4000);',
      '  l_target_tables varchar2(4000);',
      '  l_node_code varchar2(100);',
      '  l_target_node_code varchar2(100);',
      '  l_table_count number;',
      '  l_target_table_count number;',
      '  l_node_prefix varchar2(40);',
      '  l_property_name varchar2(40);',
      '  l_count_property_name varchar2(40);',
      'begin',
      '  l_node_prefix := case when upper(apex_application.g_x02) = ''REPLICAT'' then ''OGG_REPLICAT_'' else ''OGG_EXTRACT_'' end;',
      '  l_property_name := case when upper(apex_application.g_x02) = ''REPLICAT'' then ''maps'' else ''tables'' end;',
      '  l_count_property_name := case when upper(apex_application.g_x02) = ''REPLICAT'' then ''map_count'' else ''table_count'' end;',
      '  l_restart_plan := case',
      '    when upper(apex_application.g_x09) = ''MOVE'' then ''Move TABLE/MAP from source parameter to target parameter, restart both processes, then refresh Fabric metadata.''',
      '    when upper(apex_application.g_x04) like ''REMOVE TABLE %'' then ''Stop Extract, remove TABLE clause from parameter, start Extract, then refresh Fabric metadata.''',
      '    when upper(apex_application.g_x04) like ''REMOVE MAP %'' then ''Stop Replicat, remove MAP clause from parameter, start Replicat, then refresh Fabric metadata.''',
      '    when upper(apex_application.g_x02) = ''EXTRACT'' then ''Stop Extract, update parameter TABLE clause, start Extract, then refresh Fabric metadata.''',
      '    else ''Stop Replicat, update parameter MAP clause, start Replicat, then refresh Fabric metadata.''',
      '  end;',
      '',
      '  insert into ggadmin.fabric_change_request (',
      '    request_status,',
      '    process_name,',
      '    process_type,',
      '    source_table,',
      '    target_table,',
      '    change_sql,',
      '    supplemental_ok,',
      '    restart_plan,',
      '    requested_by',
      '  ) values (',
      '    ''PLANNED'',',
      '    substr(apex_application.g_x01, 1, 128),',
      '    substr(upper(apex_application.g_x02), 1, 40),',
      '    substr(upper(apex_application.g_x03), 1, 261),',
      '    substr(nullif(upper(apex_application.g_x06), ''''), 1, 261),',
      '    apex_application.g_x04,',
      '    case when apex_application.g_x05 = ''Y'' then ''Y'' else ''N'' end,',
      '    l_restart_plan,',
      '    coalesce(v(''APP_USER''), user)',
      '  ) returning request_id into l_request_id;',
      '',
      '  apex_json.initialize_clob_output;',
      '  apex_json.open_object;',
      '  apex_json.write(''request_id'', l_request_id);',
      '  apex_json.write(''process_name'', apex_application.g_x01);',
      '  apex_json.write(''process_type'', upper(apex_application.g_x02));',
      '  apex_json.write(''source_table'', upper(apex_application.g_x03));',
      '  apex_json.write(''change_sql'', apex_application.g_x04);',
      '  apex_json.write(''target_process'', apex_application.g_x08);',
      '  apex_json.write(''action_mode'', apex_application.g_x09);',
      '  apex_json.close_object;',
      '  l_body := apex_json.get_clob_output;',
      '  apex_json.free_output;',
      '',
      '  apex_web_service.set_request_headers(',
      '    p_name_01 => ''Content-Type'', p_value_01 => ''application/json'',',
      '    p_name_02 => ''X-Fabric-Token'', p_value_02 => ''lab20-fabric-apply-token'',',
      '    p_reset => true);',
      '  l_resp := apex_web_service.make_rest_request(',
      '    p_url => ''http://demo_ogg_23ai:18091/apply'',',
      '    p_http_method => ''POST'',',
      '    p_body => l_body);',
      '',
      '  if apex_web_service.g_status_code < 200 or apex_web_service.g_status_code >= 300 then',
      '    raise_application_error(-20000, ''Apply helper failed: '' || dbms_lob.substr(l_resp, 1000, 1));',
      '  end if;',
      '',
      '  select backup, process, target_process',
      '    into l_backup, l_process, l_target_process',
      '    from json_table(l_resp, ''$'' columns (',
      '      backup varchar2(1000) path ''$.backup'',',
      '      process varchar2(100) path ''$.process'',',
      '      target_process varchar2(100) path ''$.target_process''',
      '    ));',
      '',
      '  select listagg(table_name, '', '') within group (order by rn), count(*)',
      '    into l_tables, l_table_count',
      '    from json_table(l_resp, ''$.tables[*]'' columns (',
      '      rn for ordinality,',
      '      table_name varchar2(261) path ''$''',
      '    ));',
      '',
      '  select listagg(table_name, '', '') within group (order by rn), count(*)',
      '    into l_target_tables, l_target_table_count',
      '    from json_table(l_resp, ''$.target_tables[*]'' columns (',
      '      rn for ordinality,',
      '      table_name varchar2(261) path ''$''',
      '    ));',
      '',
      '  l_node_code := l_node_prefix || l_process;',
      '  merge into ggadmin.fabric_node_property d',
      '  using (select l_node_code node_code, l_property_name property_name, l_tables property_value from dual) s',
      '     on (d.node_code = s.node_code and d.property_name = s.property_name)',
      '   when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp',
      '   when not matched then insert (node_code, property_name, property_value) values (s.node_code, s.property_name, s.property_value);',
      '',
      '  merge into ggadmin.fabric_node_property d',
      '  using (select l_node_code node_code, l_count_property_name property_name, to_char(l_table_count) property_value from dual) s',
      '     on (d.node_code = s.node_code and d.property_name = s.property_name)',
      '   when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp',
      '   when not matched then insert (node_code, property_name, property_value) values (s.node_code, s.property_name, s.property_value);',
      '',
      '  if l_target_process is not null then',
      '    l_target_node_code := l_node_prefix || l_target_process;',
      '    merge into ggadmin.fabric_node_property d',
      '    using (select l_target_node_code node_code, l_property_name property_name, l_target_tables property_value from dual) s',
      '       on (d.node_code = s.node_code and d.property_name = s.property_name)',
      '     when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp',
      '     when not matched then insert (node_code, property_name, property_value) values (s.node_code, s.property_name, s.property_value);',
      '',
      '    merge into ggadmin.fabric_node_property d',
      '    using (select l_target_node_code node_code, l_count_property_name property_name, to_char(l_target_table_count) property_value from dual) s',
      '       on (d.node_code = s.node_code and d.property_name = s.property_name)',
      '     when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp',
      '     when not matched then insert (node_code, property_name, property_value) values (s.node_code, s.property_name, s.property_value);',
      '  end if;',
      '',
      '  update ggadmin.fabric_change_request',
      '     set request_status = ''APPLIED''',
      '   where request_id = l_request_id;',
      '',
      '  commit;',
      '  apex_json.open_object;',
      '  apex_json.write(''request_id'', l_request_id);',
      '  apex_json.write(''status'', ''APPLIED'');',
      '  apex_json.write(''restart_plan'', l_restart_plan);',
      '  apex_json.write(''backup'', l_backup);',
      '  apex_json.write(''process'', l_process);',
      '  apex_json.write(''target_process'', l_target_process);',
      '  apex_json.write(''tables'', l_tables);',
      '  apex_json.write(''target_tables'', l_target_tables);',
      '  apex_json.close_object;',
      'exception',
      '  when others then',
      '    rollback;',
      '    apex_json.open_object;',
      '    apex_json.write(''error'', sqlerrm);',
      '    apex_json.close_object;',
      '    raise;',
      'end;'
    )),
    p_process_clob_language   => 'PLSQL',
    p_error_display_location  => 'INLINE_IN_NOTIFICATION'
  );
end;
/

prompt --application/end_environment
begin
wwv_flow_imp.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false));
begin
  apex_util.clear_app_cache(101);
exception
  when others then
    null;
end;
commit;
end;
/

set verify on feedback on define on

prompt == Verify App 101 Data Fabric Designer ==
select id, name, alias, step_title
  from apex_260100.wwv_flow_steps
 where flow_id = 101
   and id = 200;

select list_item_display_sequence seq,
       static_id,
       list_item_link_text,
       list_item_link_target
  from apex_260100.wwv_flow_list_items
 where flow_id = 101
   and static_id like 'data-fabric%'
 order by list_item_display_sequence, static_id;

select count(*) fabric_nodes from ggadmin.fabric_node;
select count(*) fabric_edges from ggadmin.fabric_edge;
select count(*) fabric_columns from ggadmin.fabric_table_column;

declare
  l_valid_objects number;
begin
  select count(*)
    into l_valid_objects
    from dba_objects
   where owner = 'GGADMIN'
     and object_name = 'FABRIC_DESIGNER_PKG'
     and object_type in ('PACKAGE', 'PACKAGE BODY')
     and status = 'VALID';

  if l_valid_objects <> 2 then
    raise_application_error(
      -20020,
      'GGADMIN.FABRIC_DESIGNER_PKG package and package body are not both VALID');
  end if;
end;
/

prompt App 101 Data Fabric Designer installed.
