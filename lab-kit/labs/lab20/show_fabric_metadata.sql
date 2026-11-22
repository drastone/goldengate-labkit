alter session set container=ORCLPDB1;

set pages 100
set lines 220

col node_code format a28
col node_name format a32
col node_type format a20
col system_name format a22
col status format a10
col edge_code format a30
col from_node_code format a28
col to_node_code format a28
col edge_type format a18
col table_name format a24
col column_name format a24
col column_comment format a70
col property_name format a16
col property_value format a100

select node_code,
       node_name,
       node_type,
       system_name,
       layer_no,
       status
  from ggadmin.fabric_node
 order by layer_no, display_order, node_code;

select edge_code,
       from_node_code,
       to_node_code,
       edge_type,
       status
  from ggadmin.fabric_edge
 order by created_at, edge_code;

prompt
prompt == parameter metadata discovered from prm files ==
select node_code,
       property_name,
       case
         when length(property_value) > 100 then substr(property_value, 1, 97) || '...'
         else property_value
       end property_value
  from ggadmin.fabric_node_property
 where property_name in ('trail','table_count','map_count','parameter_file')
 order by node_code,
          case property_name
            when 'trail' then 1
            when 'table_count' then 2
            when 'map_count' then 3
            when 'parameter_file' then 4
            else 5
          end;

prompt
prompt == dictionary comment metadata ==
select table_name,
       count(*) column_count,
       count(column_comment) commented_columns
  from ggadmin.fabric_table_column
 group by table_name
 order by table_name;

prompt
prompt == sample column comments ==
select table_name,
       column_name,
       column_comment
  from ggadmin.fabric_table_column
 where column_comment is not null
   and table_name in ('CFUND_DT','OPSTATUS','TOT_AMT','CUST_INFO')
 order by table_name, column_id
 fetch first 20 rows only;
