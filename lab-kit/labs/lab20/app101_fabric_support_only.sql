--------------------------------------------------------------------------------
-- Chapter 20 Data Fabric Designer supporting objects
-- Page 200 is included in the APEX export above. This block creates the
-- GGADMIN.FABRIC_* metadata tables and renderer package required by the page.
--------------------------------------------------------------------------------

set define off
set serveroutput on size unlimited
whenever sqlerror exit sql.sqlcode rollback


--------------------------------------------------------------------------------
-- Chapter 20 - Data Fabric Designer
--
-- Purpose
--   Add the first Data Fabric Designer page to App 101 GoldenGate Integrated
--   Operations Console. The page is intentionally metadata-driven. It does not
--   require Kafka, Iceberg, Trino, or dashboard containers to be running.
--------------------------------------------------------------------------------

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

comment on table ggadmin.fabric_node is
  'Data Fabric Designer에서 source table, GoldenGate process, stream, data product, dashboard 같은 asset node를 관리한다.';
comment on table ggadmin.fabric_edge is
  'Data Fabric Designer에서 node 간 CDC/stream/transform/serve 관계를 관리한다.';
comment on table ggadmin.fabric_node_property is
  'Data Fabric node별 보조 속성을 관리한다.';
comment on table ggadmin.fabric_table_column is
  'Data Fabric Designer가 DB dictionary comment에서 수집한 업무 table/column metadata cache.';

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
         'E_SRC_CUST_TO_C01',
         'E_TRAIL_CA_TO_F02',
         'E_TRAIL_CA_TO_KAF01',
         'E_SRC_CFUND_TO_C01',
         'E_SRC_OPSTATUS_TO_C01',
         'E_SRC_TOT_AMT_TO_C01',
         'E_SRC_CUST_TO_C02',
         'E_C01_TO_TRAIL_CA',
         'E_C02_TO_TRAIL_CB',
         'E_TRAIL_CA_TO_F01',
         'E_TRAIL_CB_TO_F02',
         'E_TRAIL_CB_TO_KAF01'
       )
      or from_node_code in ('OGG_REPLICAT_D01','OGG_EXTRACT_C01','OGG_EXTRACT_C02','OGG_REPLICAT_F01','OGG_REPLICAT_F02','OGG_TRAIL_CA','OGG_TRAIL_CB')
      or to_node_code in ('OGG_REPLICAT_D01','OGG_EXTRACT_C01','OGG_EXTRACT_C02','OGG_REPLICAT_F01','OGG_REPLICAT_F02','OGG_TRAIL_CA','OGG_TRAIL_CB');
  delete from ggadmin.fabric_node_property
   where node_code in ('OGG_REPLICAT_D01','OGG_EXTRACT_C01','OGG_EXTRACT_C02','OGG_REPLICAT_F01','OGG_REPLICAT_F02','OGG_TRAIL_CA','OGG_TRAIL_CB');
  delete from ggadmin.fabric_node
   where node_code in ('OGG_REPLICAT_D01','OGG_EXTRACT_C01','OGG_EXTRACT_C02','OGG_REPLICAT_F01','OGG_REPLICAT_F02','OGG_TRAIL_CA','OGG_TRAIL_CB');

  upsert_node('SRC_SOE_CFUND_DT', 'SOE.CFUND_DT', 'SOURCE_TABLE', '보험료/펀드', 'demo_osrc_23ai', 1, 10, 'ACTIVE', 'SOE.CFUND_DT', table_comment('SOE', 'CFUND_DT', 'Source 업무계에서 발생하는 펀드/납입 변경 이벤트'));
  upsert_node('SRC_SOE_OPSTATUS', 'SOE.OPSTATUS', 'SOURCE_TABLE', '운영상태', 'demo_osrc_23ai', 1, 11, 'ACTIVE', 'SOE.OPSTATUS', table_comment('SOE', 'OPSTATUS', '업무 처리 상태와 운영 activity event'));
  upsert_node('SRC_SOE_TOT_AMT', 'SOE.TOT_AMT', 'SOURCE_TABLE', '보험료/펀드', 'demo_osrc_23ai', 1, 12, 'ACTIVE', 'SOE.TOT_AMT', table_comment('SOE', 'TOT_AMT', '집계성 금액 변동 event'));
  upsert_node('SRC_SOE_CUST_INFO', 'SOE.CUST_INFO', 'SOURCE_TABLE', '고객', 'demo_osrc_23ai', 1, 20, 'ACTIVE', 'SOE.CUST_INFO', table_comment('SOE', 'CUST_INFO', '고객 마스터와 고객 식별 정보'));
  upsert_node('OGG_EXTRACT_C01', 'Extract C01', 'OGG_EXTRACT', 'Normal Capture', 'demo_ogg_23ai', 2, 10, 'ACTIVE', 'C01', 'CFUND_DT, OPSTATUS, TOT_AMT를 제외한 나머지 SOE table을 capture');
  upsert_node('OGG_EXTRACT_C02', 'Extract C02', 'OGG_EXTRACT', 'Heavy Capture', 'demo_ogg_23ai', 2, 20, 'ACTIVE', 'C02', 'CFUND_DT, OPSTATUS, TOT_AMT heavy/batch-like 업무 변경을 capture');
  upsert_node('OGG_TRAIL_K1', 'Trail k1', 'TRAIL', 'Normal Trail', 'demo_ogg_23ai', 3, 10, 'ACTIVE', 'k1', 'C01이 기록하는 normal table lane trail');
  upsert_node('OGG_TRAIL_K2', 'Trail k2', 'TRAIL', 'Heavy Trail', 'demo_ogg_23ai', 3, 20, 'ACTIVE', 'k2', 'C02가 기록하는 heavy table lane trail');
  upsert_node('OGG_REPLICAT_FD01', 'Replicat FD01', 'OGG_REPLICAT', 'Oracle Target', 'demo_ogg_23ai', 4, 10, 'ACTIVE', 'FD01', 'k1 trail의 일반 업무 table을 target으로 apply');
  upsert_node('OGG_REPLICAT_FD02', 'Replicat FD02', 'OGG_REPLICAT', 'Oracle Target', 'demo_ogg_23ai', 4, 20, 'ACTIVE', 'FD02', 'k2 trail에서 SOE.CFUND_DT만 분리 apply');
  upsert_node('OGG_REPLICAT_FD03', 'Replicat FD03', 'OGG_REPLICAT', 'Oracle Target', 'demo_ogg_23ai', 4, 30, 'ACTIVE', 'FD03', 'k2 trail에서 SOE.OPSTATUS, SOE.TOT_AMT를 분리 apply');
  upsert_node('OGG_REPLICAT_KAF01', 'Replicat KAF01', 'OGG_REPLICAT', 'Kafka Target', 'demo_oggbd_23ai', 4, 20, 'DESIGN', 'KAF01', 'OGG for Big Data Kafka apply 경로. 20장에서는 parameter mapping 확인 대상');
  upsert_node('OGG_DATA_STREAM_DS_LAKE', 'Data Stream DS_LAKE', 'DATA_STREAM', 'Data Streams', 'demo_ogg_23ai', 4, 40, 'ACTIVE', 'DS_LAKE', 'GoldenGate heavy lane trail을 WebSocket Data Stream으로 개방');
  upsert_node('ICEBERG_BRONZE_CFUND', 'Bronze ds_cfund_dt_events', 'LAKEHOUSE_TABLE', 'Lakehouse Bronze', 'demo_iceberg_catalog', 5, 10, 'OFFLINE', 'insurance.ds_cfund_dt_events', '19장에서 적재한 원본 CDC event table');
  upsert_node('ICEBERG_SILVER_ACTIVITY', 'Silver customer_fund_activity', 'TRANSFORM_JOB', 'Lakehouse Silver', 'demo_iceberg_catalog', 5, 20, 'OFFLINE', 'insurance.silver_customer_fund_activity', 'Bronze event를 고객/업무 컬럼 중심으로 정제');
  upsert_node('ICEBERG_GOLD_ACTION', 'Gold channel_action_candidate', 'DATA_PRODUCT', 'Lakehouse Gold', 'demo_iceberg_catalog', 6, 10, 'OFFLINE', 'insurance.gold_channel_action_candidate', '채널 실행 후보 data product');
  upsert_node('DASHBOARD_GOLD_CHANNEL', 'Gold Channel Action Dashboard', 'DASHBOARD', '업무 실행', 'demo_gold_dashboard', 6, 20, 'OFFLINE', 'gold_channel_action_dashboard.html', 'Gold data product를 업무 실행 후보 화면으로 제공');
  upsert_node('APEX_DATA_FABRIC', 'Data Fabric Designer', 'APEX_APP', 'Control Plane', 'demo_otrg_23ai', 6, 30, 'ACTIVE', 'App 101 Page 200', 'GoldenGate 통합 Console 안에서 fabric metadata를 시각화');

  upsert_edge('E_SRC_CUST_TO_C01', 'SRC_SOE_CUST_INFO', 'OGG_EXTRACT_C01', 'CAPTURE', 'TABLE SOE.CUST_INFO', 'ACTIVE', '고객 마스터와 일반 업무 table을 C01 lane에서 관리');
  upsert_edge('E_SRC_CFUND_TO_C02', 'SRC_SOE_CFUND_DT', 'OGG_EXTRACT_C02', 'CAPTURE', 'TABLE SOE.CFUND_DT', 'ACTIVE', '펀드 활동 table 변경을 C02가 capture');
  upsert_edge('E_SRC_OPSTATUS_TO_C02', 'SRC_SOE_OPSTATUS', 'OGG_EXTRACT_C02', 'CAPTURE', 'TABLE SOE.OPSTATUS', 'ACTIVE', '운영상태 table 변경을 C02가 capture');
  upsert_edge('E_SRC_TOT_AMT_TO_C02', 'SRC_SOE_TOT_AMT', 'OGG_EXTRACT_C02', 'CAPTURE', 'TABLE SOE.TOT_AMT', 'ACTIVE', '집계성 금액 table 변경을 C02가 capture');
  upsert_edge('E_C01_TO_TRAIL_K1', 'OGG_EXTRACT_C01', 'OGG_TRAIL_K1', 'WRITE_TRAIL', 'EXTTRAIL k1', 'ACTIVE', 'C01이 일반 table 변경을 k1 trail에 기록');
  upsert_edge('E_C02_TO_TRAIL_K2', 'OGG_EXTRACT_C02', 'OGG_TRAIL_K2', 'WRITE_TRAIL', 'EXTTRAIL k2', 'ACTIVE', 'C02가 heavy table 변경을 k2 trail에 기록');
  upsert_edge('E_TRAIL_K1_TO_FD01', 'OGG_TRAIL_K1', 'OGG_REPLICAT_FD01', 'APPLY', 'explicit MAP entries except CFUND_DT, OPSTATUS, TOT_AMT', 'ACTIVE', 'FD01이 k1의 일반 업무 table을 apply');
  upsert_edge('E_TRAIL_K2_TO_FD02', 'OGG_TRAIL_K2', 'OGG_REPLICAT_FD02', 'APPLY', 'MAP SOE.CFUND_DT', 'ACTIVE', 'FD02가 k2에서 CFUND_DT만 apply');
  upsert_edge('E_TRAIL_K2_TO_FD03', 'OGG_TRAIL_K2', 'OGG_REPLICAT_FD03', 'APPLY', 'MAP SOE.OPSTATUS, SOE.TOT_AMT', 'ACTIVE', 'FD03이 k2에서 OPSTATUS/TOT_AMT를 apply');
  upsert_edge('E_TRAIL_K1_TO_KAF01', 'OGG_TRAIL_K1', 'OGG_REPLICAT_KAF01', 'APPLY', 'Kafka handler mapping', 'DESIGN', 'Kafka target 후보 경로');
  upsert_edge('E_TRAIL_K2_TO_DS_LAKE', 'OGG_TRAIL_K2', 'OGG_DATA_STREAM_DS_LAKE', 'PUBLISH_STREAM', 'trail k2 -> DS_LAKE', 'ACTIVE', 'Data Streams가 heavy lane trail을 stream으로 제공');
  upsert_edge('E_DS_LAKE_TO_BRONZE', 'OGG_DATA_STREAM_DS_LAKE', 'ICEBERG_BRONZE_CFUND', 'APPEND_BRONZE', 'demo_iceberg_writer', 'OFFLINE', 'Lightweight writer가 CDC event를 Bronze table에 append');
  upsert_edge('E_BRONZE_TO_SILVER', 'ICEBERG_BRONZE_CFUND', 'ICEBERG_SILVER_ACTIVITY', 'BUILD_SILVER', 'build_silver_fund_activity.sh', 'OFFLINE', 'Bronze event를 고객별 업무 activity로 정제');
  upsert_edge('E_SILVER_TO_GOLD', 'ICEBERG_SILVER_ACTIVITY', 'ICEBERG_GOLD_ACTION', 'BUILD_GOLD', 'build_gold_channel_action.sh', 'OFFLINE', 'Silver activity를 채널 실행 후보 data product로 집계');
  upsert_edge('E_GOLD_TO_DASHBOARD', 'ICEBERG_GOLD_ACTION', 'DASHBOARD_GOLD_CHANNEL', 'SERVE_DASHBOARD', 'build_gold_dashboard.sh', 'OFFLINE', 'Gold data product를 dashboard로 노출');
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

  commit;
end;
/

create or replace package ggadmin.fabric_designer_pkg authid definer as
  function render return clob;
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
    l_props varchar2(1000);
  begin
    select count(*)
      into l_nodes
      from ggadmin.fabric_node;

    select count(*)
      into l_edges
      from ggadmin.fabric_edge;

    select count(*)
      into l_products
      from ggadmin.fabric_node
     where node_type in ('DATA_PRODUCT','DASHBOARD');

    select count(*)
      into l_columns
      from ggadmin.fabric_table_column
     where column_comment is not null;

    l_html := to_clob(q'~<style>
.df-wrap{--ink:#172033;--muted:#64748b;--line:#d8e1eb;--soft:#f7fafc;--blue:#1f6feb;--green:#0f9f6e;--amber:#b7791f;--red:#c2410c;color:var(--ink)}
.df-wrap *{box-sizing:border-box}.df-head{border:1px solid var(--line);border-left:5px solid var(--blue);border-radius:8px;background:#fff;padding:18px 20px;margin-bottom:12px}
.df-head h1{font-size:24px;margin:0 0 6px}.df-head p{margin:0;color:var(--muted);line-height:1.45}
.df-kpis{display:grid;grid-template-columns:repeat(4,minmax(0,1fr));gap:10px;margin-bottom:12px}.df-kpi{border:1px solid var(--line);border-radius:8px;background:#fff;padding:14px}.df-kpi-label{font-size:12px;color:var(--muted)}.df-kpi-value{font-size:26px;font-weight:800;margin-top:4px}
.df-canvas{display:grid;grid-template-columns:repeat(6,minmax(150px,1fr));gap:10px;align-items:start}.df-lane{border:1px solid var(--line);border-radius:8px;background:var(--soft);padding:10px;min-height:380px}.df-lane h2{font-size:14px;margin:0 0 10px;color:#334155}
.df-node{border:1px solid #cbd5e1;border-radius:8px;background:#fff;padding:10px;margin-bottom:10px;box-shadow:0 1px 4px rgba(15,23,42,.05)}.df-node-title{font-size:14px;font-weight:800;margin-bottom:4px}.df-node-type{font-size:11px;color:var(--muted);text-transform:uppercase}.df-node-ref{font-size:12px;color:#334155;margin-top:6px;word-break:break-word}.df-node-desc{font-size:12px;color:var(--muted);line-height:1.35;margin-top:6px}
.df-badge{display:inline-block;border-radius:999px;font-size:10px;font-weight:800;line-height:1;padding:5px 8px;margin-top:8px}.df-badge.ok{background:#dcfce7;color:#166534}.df-badge.design{background:#fef3c7;color:#92400e}.df-badge.off{background:#fee2e2;color:#991b1b}.df-badge.optional{background:#e0f2fe;color:#075985}.df-badge.muted{background:#e5e7eb;color:#374151}
.df-flow{margin-top:12px;border:1px solid var(--line);border-radius:8px;background:#fff;padding:14px}.df-flow h2{font-size:16px;margin:0 0 10px}.df-flow-row{display:grid;grid-template-columns:190px 24px 190px minmax(0,1fr);gap:8px;align-items:start;border-top:1px solid #edf2f7;padding:8px 0}.df-flow-row:first-of-type{border-top:none}.df-flow-node{font-weight:700}.df-flow-type{font-size:11px;color:#475569}.df-flow-desc{color:var(--muted);line-height:1.35}
.df-dict-grid{display:grid;grid-template-columns:repeat(4,minmax(0,1fr));gap:10px}.df-dict-card{border:1px solid #e2e8f0;border-radius:8px;padding:10px;background:#fff}.df-dict-title{font-weight:800;margin-bottom:5px}.df-dict-meta{font-size:11px;color:var(--muted);text-transform:uppercase}.df-dict-desc{font-size:12px;color:#475569;line-height:1.35;margin-top:6px}
.df-tabs{display:flex;gap:6px;margin:10px 0 12px;flex-wrap:wrap}.df-tab{border:1px solid var(--line);border-radius:999px;padding:7px 11px;background:#fff;color:#334155;font-size:12px}.df-tab.active{background:#172033;color:#fff;border-color:#172033}
</style><section class="df-wrap">~');

    l_html := l_html ||
      '<div class="df-head"><h1>Data Fabric Designer</h1><p>GoldenGate process parameter와 운영 metadata를 기반으로 source table, trail, stream, target 후보, data product 관계를 하나의 fabric으로 표현합니다. 20장 기본 실습에서는 downstream target을 모두 기동하지 않고 metadata control plane을 먼저 구성합니다.</p></div>' ||
      '<div class="df-tabs"><span class="df-tab active">Designer</span><span class="df-tab">Assets</span><span class="df-tab">Pipelines</span><span class="df-tab">Data Products</span><span class="df-tab">Lineage</span><span class="df-tab">Runtime Status</span><span class="df-tab">Governance</span></div>' ||
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
      for n in (
        select *
          from ggadmin.fabric_node
         where layer_no = lane.layer_no
         order by display_order, node_name
      ) loop
        l_props := node_properties(n.node_code);
        l_html := l_html ||
          '<div class="df-node"><div class="df-node-title">' || h(n.node_name) || '</div>' ||
          '<div class="df-node-type">' || h(n.node_type) || ' · ' || h(n.system_name) || '</div>' ||
          '<div class="df-node-ref">' || h(n.resource_ref) || '</div>' ||
          '<div class="df-node-desc">' || h(n.description) || '</div>' ||
          case when l_props is not null then '<div class="df-node-desc">' || h(l_props) || '</div>' end ||
          status_badge(n.status) || '</div>';
      end loop;
      l_html := l_html || '</div>';
    end loop;
    l_html := l_html || '</div>';

    l_html := l_html || '<div class="df-flow"><h2>Dictionary Metadata</h2><div class="df-dict-grid">';
    for d in (
      select n.resource_ref table_name,
             n.description table_comment,
             count(c.column_name) column_count,
             count(c.column_comment) commented_count,
             min(c.column_name) keep (dense_rank first order by c.column_id) first_column
        from ggadmin.fabric_node n
        left join ggadmin.fabric_table_column c
          on n.node_type = 'SOURCE_TABLE'
         and c.owner_name || '.' || c.table_name = n.resource_ref
       where n.node_type = 'SOURCE_TABLE'
       group by n.resource_ref, n.description, n.display_order
       order by n.display_order
    ) loop
      l_html := l_html ||
        '<div class="df-dict-card"><div class="df-dict-title">' || h(d.table_name) || '</div>' ||
        '<div class="df-dict-meta">' || d.column_count || ' columns · ' || d.commented_count || ' comments</div>' ||
        '<div class="df-dict-desc">' || h(d.table_comment) || '</div></div>';
    end loop;
    l_html := l_html || '</div></div>';

    l_html := l_html || '<div class="df-flow"><h2>Lineage Trace</h2>';
    for e in (
      select e.edge_type,
             e.mapping_ref,
             e.description,
             e.status,
             f.node_name from_name,
             t.node_name to_name
        from ggadmin.fabric_edge e
             join ggadmin.fabric_node f on f.node_code = e.from_node_code
             join ggadmin.fabric_node t on t.node_code = e.to_node_code
       order by e.created_at, e.edge_code
    ) loop
      l_html := l_html ||
        '<div class="df-flow-row"><div><div class="df-flow-node">' || h(e.from_name) || '</div><div class="df-flow-type">' || h(e.edge_type) || '</div></div>' ||
        '<div>→</div><div><div class="df-flow-node">' || h(e.to_name) || '</div><div class="df-flow-type">' || h(e.mapping_ref) || '</div></div>' ||
        '<div class="df-flow-desc">' || h(e.description) || ' ' || status_badge(e.status) || '</div></div>';
    end loop;
    l_html := l_html || '</div></section>';

    return l_html;
  end render;
end fabric_designer_pkg;
/
show errors package body ggadmin.fabric_designer_pkg

grant select on ggadmin.fabric_node to apex_260100;
grant select on ggadmin.fabric_edge to apex_260100;
grant select on ggadmin.fabric_node_property to apex_260100;
grant select on ggadmin.fabric_table_column to apex_260100;
grant execute on ggadmin.fabric_designer_pkg to apex_260100;
