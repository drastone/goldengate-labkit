set define off
whenever sqlerror exit sql.sqlcode rollback
alter session set container=ORCLPDB1;

delete from ggadmin.fabric_edge where edge_code like 'DISC\_%' escape '\';

delete from ggadmin.fabric_node_property
 where property_name in ('parameter_file','trail','table_count','tables','map_count','maps','runtime_status','useridalias');

merge into ggadmin.fabric_node d
using (select 'OGG_EXTRACT_C01' node_code, 'Extract C01' node_name, 'OGG_EXTRACT' node_type, 'GoldenGate' domain_name, 'demo_ogg_23ai' system_name, 2 layer_no, '10' display_order, 'ACTIVE' status, 'C01' resource_ref, 'Discovered from GoldenGate parameter file /u02/Deployment/etc/conf/ogg/c01.prm. Runtime status: RUNNING. TABLE count: 1.' description from dual) s
   on (d.node_code = s.node_code)
 when matched then update set d.node_name = s.node_name, d.node_type = s.node_type, d.domain_name = s.domain_name, d.system_name = s.system_name, d.layer_no = s.layer_no, d.display_order = s.display_order, d.status = s.status, d.resource_ref = s.resource_ref, d.description = s.description, d.updated_at = systimestamp
 when not matched then insert (node_code, node_name, node_type, domain_name, system_name, layer_no, display_order, status, resource_ref, description)
   values (s.node_code, s.node_name, s.node_type, s.domain_name, s.system_name, s.layer_no, s.display_order, s.status, s.resource_ref, s.description);

merge into ggadmin.fabric_node d
using (select 'OGG_EXTRACT_C02' node_code, 'Extract C02' node_name, 'OGG_EXTRACT' node_type, 'GoldenGate' domain_name, 'demo_ogg_23ai' system_name, 2 layer_no, '20' display_order, 'OFFLINE' status, 'C02' resource_ref, 'Discovered from GoldenGate parameter file /u02/Deployment/etc/conf/ogg/c02.prm. Runtime status: UNKNOWN. TABLE count: 3.' description from dual) s
   on (d.node_code = s.node_code)
 when matched then update set d.node_name = s.node_name, d.node_type = s.node_type, d.domain_name = s.domain_name, d.system_name = s.system_name, d.layer_no = s.layer_no, d.display_order = s.display_order, d.status = s.status, d.resource_ref = s.resource_ref, d.description = s.description, d.updated_at = systimestamp
 when not matched then insert (node_code, node_name, node_type, domain_name, system_name, layer_no, display_order, status, resource_ref, description)
   values (s.node_code, s.node_name, s.node_type, s.domain_name, s.system_name, s.layer_no, s.display_order, s.status, s.resource_ref, s.description);

merge into ggadmin.fabric_node d
using (select 'OGG_EXTRACT_CR01' node_code, 'Extract CR01' node_name, 'OGG_EXTRACT' node_type, 'GoldenGate' domain_name, 'demo_ogg_23ai' system_name, 2 layer_no, '30' display_order, 'OFFLINE' status, 'CR01' resource_ref, 'Discovered from GoldenGate parameter file /u02/Deployment/etc/conf/ogg/CR01.prm. Runtime status: STOPPED. TABLE count: 1.' description from dual) s
   on (d.node_code = s.node_code)
 when matched then update set d.node_name = s.node_name, d.node_type = s.node_type, d.domain_name = s.domain_name, d.system_name = s.system_name, d.layer_no = s.layer_no, d.display_order = s.display_order, d.status = s.status, d.resource_ref = s.resource_ref, d.description = s.description, d.updated_at = systimestamp
 when not matched then insert (node_code, node_name, node_type, domain_name, system_name, layer_no, display_order, status, resource_ref, description)
   values (s.node_code, s.node_name, s.node_type, s.domain_name, s.system_name, s.layer_no, s.display_order, s.status, s.resource_ref, s.description);

merge into ggadmin.fabric_node d
using (select 'OGG_EXTRACT_CW01' node_code, 'Extract CW01' node_name, 'OGG_EXTRACT' node_type, 'GoldenGate' domain_name, 'demo_ogg_23ai' system_name, 2 layer_no, '40' display_order, 'OFFLINE' status, 'CW01' resource_ref, 'Discovered from GoldenGate parameter file /u02/Deployment/etc/conf/ogg/CW01.prm. Runtime status: STOPPED. TABLE count: 1.' description from dual) s
   on (d.node_code = s.node_code)
 when matched then update set d.node_name = s.node_name, d.node_type = s.node_type, d.domain_name = s.domain_name, d.system_name = s.system_name, d.layer_no = s.layer_no, d.display_order = s.display_order, d.status = s.status, d.resource_ref = s.resource_ref, d.description = s.description, d.updated_at = systimestamp
 when not matched then insert (node_code, node_name, node_type, domain_name, system_name, layer_no, display_order, status, resource_ref, description)
   values (s.node_code, s.node_name, s.node_type, s.domain_name, s.system_name, s.layer_no, s.display_order, s.status, s.resource_ref, s.description);

merge into ggadmin.fabric_node d
using (select 'OGG_EXTRACT_FC01' node_code, 'Extract FC01' node_name, 'OGG_EXTRACT' node_type, 'GoldenGate' domain_name, 'demo_ogg_23ai' system_name, 2 layer_no, '50' display_order, 'ACTIVE' status, 'FC01' resource_ref, 'Discovered from GoldenGate parameter file /u02/Deployment/etc/conf/ogg/fc01.prm. Runtime status: RUNNING. TABLE count: 28.' description from dual) s
   on (d.node_code = s.node_code)
 when matched then update set d.node_name = s.node_name, d.node_type = s.node_type, d.domain_name = s.domain_name, d.system_name = s.system_name, d.layer_no = s.layer_no, d.display_order = s.display_order, d.status = s.status, d.resource_ref = s.resource_ref, d.description = s.description, d.updated_at = systimestamp
 when not matched then insert (node_code, node_name, node_type, domain_name, system_name, layer_no, display_order, status, resource_ref, description)
   values (s.node_code, s.node_name, s.node_type, s.domain_name, s.system_name, s.layer_no, s.display_order, s.status, s.resource_ref, s.description);

merge into ggadmin.fabric_node d
using (select 'OGG_EXTRACT_FC02' node_code, 'Extract FC02' node_name, 'OGG_EXTRACT' node_type, 'GoldenGate' domain_name, 'demo_ogg_23ai' system_name, 2 layer_no, '60' display_order, 'ACTIVE' status, 'FC02' resource_ref, 'Discovered from GoldenGate parameter file /u02/Deployment/etc/conf/ogg/fc02.prm. Runtime status: RUNNING. TABLE count: 3.' description from dual) s
   on (d.node_code = s.node_code)
 when matched then update set d.node_name = s.node_name, d.node_type = s.node_type, d.domain_name = s.domain_name, d.system_name = s.system_name, d.layer_no = s.layer_no, d.display_order = s.display_order, d.status = s.status, d.resource_ref = s.resource_ref, d.description = s.description, d.updated_at = systimestamp
 when not matched then insert (node_code, node_name, node_type, domain_name, system_name, layer_no, display_order, status, resource_ref, description)
   values (s.node_code, s.node_name, s.node_type, s.domain_name, s.system_name, s.layer_no, s.display_order, s.status, s.resource_ref, s.description);

merge into ggadmin.fabric_node d
using (select 'OGG_EXTRACT_T01' node_code, 'Extract T01' node_name, 'OGG_EXTRACT' node_type, 'GoldenGate' domain_name, 'demo_ogg_23ai' system_name, 2 layer_no, '70' display_order, 'OFFLINE' status, 'T01' resource_ref, 'Discovered from GoldenGate parameter file /u02/Deployment/etc/conf/ogg/t01.prm. Runtime status: UNKNOWN. TABLE count: 1.' description from dual) s
   on (d.node_code = s.node_code)
 when matched then update set d.node_name = s.node_name, d.node_type = s.node_type, d.domain_name = s.domain_name, d.system_name = s.system_name, d.layer_no = s.layer_no, d.display_order = s.display_order, d.status = s.status, d.resource_ref = s.resource_ref, d.description = s.description, d.updated_at = systimestamp
 when not matched then insert (node_code, node_name, node_type, domain_name, system_name, layer_no, display_order, status, resource_ref, description)
   values (s.node_code, s.node_name, s.node_type, s.domain_name, s.system_name, s.layer_no, s.display_order, s.status, s.resource_ref, s.description);

merge into ggadmin.fabric_node d
using (select 'OGG_TRAIL_CA' node_code, 'Trail ca' node_name, 'TRAIL' node_type, 'GoldenGate Trail' domain_name, 'demo_ogg_23ai' system_name, 3 layer_no, '10' display_order, 'ACTIVE' status, 'ca' resource_ref, 'Discovered from C01 parameter EXTTRAIL/RMTTRAIL ca.' description from dual) s
   on (d.node_code = s.node_code)
 when matched then update set d.node_name = s.node_name, d.node_type = s.node_type, d.domain_name = s.domain_name, d.system_name = s.system_name, d.layer_no = s.layer_no, d.display_order = s.display_order, d.status = s.status, d.resource_ref = s.resource_ref, d.description = s.description, d.updated_at = systimestamp
 when not matched then insert (node_code, node_name, node_type, domain_name, system_name, layer_no, display_order, status, resource_ref, description)
   values (s.node_code, s.node_name, s.node_type, s.domain_name, s.system_name, s.layer_no, s.display_order, s.status, s.resource_ref, s.description);

merge into ggadmin.fabric_node d
using (select 'OGG_TRAIL_CR' node_code, 'Trail cr' node_name, 'TRAIL' node_type, 'GoldenGate Trail' domain_name, 'demo_ogg_23ai' system_name, 3 layer_no, '30' display_order, 'OFFLINE' status, 'cr' resource_ref, 'Discovered from CR01 parameter EXTTRAIL/RMTTRAIL cr.' description from dual) s
   on (d.node_code = s.node_code)
 when matched then update set d.node_name = s.node_name, d.node_type = s.node_type, d.domain_name = s.domain_name, d.system_name = s.system_name, d.layer_no = s.layer_no, d.display_order = s.display_order, d.status = s.status, d.resource_ref = s.resource_ref, d.description = s.description, d.updated_at = systimestamp
 when not matched then insert (node_code, node_name, node_type, domain_name, system_name, layer_no, display_order, status, resource_ref, description)
   values (s.node_code, s.node_name, s.node_type, s.domain_name, s.system_name, s.layer_no, s.display_order, s.status, s.resource_ref, s.description);

merge into ggadmin.fabric_node d
using (select 'OGG_TRAIL_CW' node_code, 'Trail cw' node_name, 'TRAIL' node_type, 'GoldenGate Trail' domain_name, 'demo_ogg_23ai' system_name, 3 layer_no, '40' display_order, 'OFFLINE' status, 'cw' resource_ref, 'Discovered from CW01 parameter EXTTRAIL/RMTTRAIL cw.' description from dual) s
   on (d.node_code = s.node_code)
 when matched then update set d.node_name = s.node_name, d.node_type = s.node_type, d.domain_name = s.domain_name, d.system_name = s.system_name, d.layer_no = s.layer_no, d.display_order = s.display_order, d.status = s.status, d.resource_ref = s.resource_ref, d.description = s.description, d.updated_at = systimestamp
 when not matched then insert (node_code, node_name, node_type, domain_name, system_name, layer_no, display_order, status, resource_ref, description)
   values (s.node_code, s.node_name, s.node_type, s.domain_name, s.system_name, s.layer_no, s.display_order, s.status, s.resource_ref, s.description);

merge into ggadmin.fabric_node d
using (select 'OGG_TRAIL_K1' node_code, 'Trail k1' node_name, 'TRAIL' node_type, 'GoldenGate Trail' domain_name, 'demo_ogg_23ai' system_name, 3 layer_no, '50' display_order, 'ACTIVE' status, 'k1' resource_ref, 'Discovered from FC01 parameter EXTTRAIL/RMTTRAIL k1.' description from dual) s
   on (d.node_code = s.node_code)
 when matched then update set d.node_name = s.node_name, d.node_type = s.node_type, d.domain_name = s.domain_name, d.system_name = s.system_name, d.layer_no = s.layer_no, d.display_order = s.display_order, d.status = s.status, d.resource_ref = s.resource_ref, d.description = s.description, d.updated_at = systimestamp
 when not matched then insert (node_code, node_name, node_type, domain_name, system_name, layer_no, display_order, status, resource_ref, description)
   values (s.node_code, s.node_name, s.node_type, s.domain_name, s.system_name, s.layer_no, s.display_order, s.status, s.resource_ref, s.description);

merge into ggadmin.fabric_node d
using (select 'OGG_TRAIL_K2' node_code, 'Trail k2' node_name, 'TRAIL' node_type, 'GoldenGate Trail' domain_name, 'demo_ogg_23ai' system_name, 3 layer_no, '60' display_order, 'ACTIVE' status, 'k2' resource_ref, 'Discovered from FC02 parameter EXTTRAIL/RMTTRAIL k2.' description from dual) s
   on (d.node_code = s.node_code)
 when matched then update set d.node_name = s.node_name, d.node_type = s.node_type, d.domain_name = s.domain_name, d.system_name = s.system_name, d.layer_no = s.layer_no, d.display_order = s.display_order, d.status = s.status, d.resource_ref = s.resource_ref, d.description = s.description, d.updated_at = systimestamp
 when not matched then insert (node_code, node_name, node_type, domain_name, system_name, layer_no, display_order, status, resource_ref, description)
   values (s.node_code, s.node_name, s.node_type, s.domain_name, s.system_name, s.layer_no, s.display_order, s.status, s.resource_ref, s.description);

merge into ggadmin.fabric_node d
using (select 'OGG_REPLICAT_D01' node_code, 'Replicat D01' node_name, 'OGG_REPLICAT' node_type, 'GoldenGate' domain_name, 'demo_ogg_23ai' system_name, 4 layer_no, '10' display_order, 'OFFLINE' status, 'D01' resource_ref, 'Discovered from GoldenGate parameter file /u02/Deployment/etc/conf/ogg/d01.prm. Runtime status: UNKNOWN. MAP count: 1.' description from dual) s
   on (d.node_code = s.node_code)
 when matched then update set d.node_name = s.node_name, d.node_type = s.node_type, d.domain_name = s.domain_name, d.system_name = s.system_name, d.layer_no = s.layer_no, d.display_order = s.display_order, d.status = s.status, d.resource_ref = s.resource_ref, d.description = s.description, d.updated_at = systimestamp
 when not matched then insert (node_code, node_name, node_type, domain_name, system_name, layer_no, display_order, status, resource_ref, description)
   values (s.node_code, s.node_name, s.node_type, s.domain_name, s.system_name, s.layer_no, s.display_order, s.status, s.resource_ref, s.description);

merge into ggadmin.fabric_node d
using (select 'OGG_REPLICAT_D02' node_code, 'Replicat D02' node_name, 'OGG_REPLICAT' node_type, 'GoldenGate' domain_name, 'demo_ogg_23ai' system_name, 4 layer_no, '20' display_order, 'OFFLINE' status, 'D02' resource_ref, 'Discovered from GoldenGate parameter file /u02/Deployment/etc/conf/ogg/d02.prm. Runtime status: UNKNOWN. MAP count: 1.' description from dual) s
   on (d.node_code = s.node_code)
 when matched then update set d.node_name = s.node_name, d.node_type = s.node_type, d.domain_name = s.domain_name, d.system_name = s.system_name, d.layer_no = s.layer_no, d.display_order = s.display_order, d.status = s.status, d.resource_ref = s.resource_ref, d.description = s.description, d.updated_at = systimestamp
 when not matched then insert (node_code, node_name, node_type, domain_name, system_name, layer_no, display_order, status, resource_ref, description)
   values (s.node_code, s.node_name, s.node_type, s.domain_name, s.system_name, s.layer_no, s.display_order, s.status, s.resource_ref, s.description);

merge into ggadmin.fabric_node d
using (select 'OGG_REPLICAT_DR01' node_code, 'Replicat DR01' node_name, 'OGG_REPLICAT' node_type, 'GoldenGate' domain_name, 'demo_ogg_23ai' system_name, 4 layer_no, '30' display_order, 'OFFLINE' status, 'DR01' resource_ref, 'Discovered from GoldenGate parameter file /u02/Deployment/etc/conf/ogg/DR01.prm. Runtime status: STOPPED. MAP count: 1.' description from dual) s
   on (d.node_code = s.node_code)
 when matched then update set d.node_name = s.node_name, d.node_type = s.node_type, d.domain_name = s.domain_name, d.system_name = s.system_name, d.layer_no = s.layer_no, d.display_order = s.display_order, d.status = s.status, d.resource_ref = s.resource_ref, d.description = s.description, d.updated_at = systimestamp
 when not matched then insert (node_code, node_name, node_type, domain_name, system_name, layer_no, display_order, status, resource_ref, description)
   values (s.node_code, s.node_name, s.node_type, s.domain_name, s.system_name, s.layer_no, s.display_order, s.status, s.resource_ref, s.description);

merge into ggadmin.fabric_node d
using (select 'OGG_REPLICAT_DW01' node_code, 'Replicat DW01' node_name, 'OGG_REPLICAT' node_type, 'GoldenGate' domain_name, 'demo_ogg_23ai' system_name, 4 layer_no, '40' display_order, 'OFFLINE' status, 'DW01' resource_ref, 'Discovered from GoldenGate parameter file /u02/Deployment/etc/conf/ogg/DW01.prm. Runtime status: STOPPED. MAP count: 1.' description from dual) s
   on (d.node_code = s.node_code)
 when matched then update set d.node_name = s.node_name, d.node_type = s.node_type, d.domain_name = s.domain_name, d.system_name = s.system_name, d.layer_no = s.layer_no, d.display_order = s.display_order, d.status = s.status, d.resource_ref = s.resource_ref, d.description = s.description, d.updated_at = systimestamp
 when not matched then insert (node_code, node_name, node_type, domain_name, system_name, layer_no, display_order, status, resource_ref, description)
   values (s.node_code, s.node_name, s.node_type, s.domain_name, s.system_name, s.layer_no, s.display_order, s.status, s.resource_ref, s.description);

merge into ggadmin.fabric_node d
using (select 'OGG_REPLICAT_F01' node_code, 'Replicat F01' node_name, 'OGG_REPLICAT' node_type, 'GoldenGate' domain_name, 'demo_ogg_23ai' system_name, 4 layer_no, '50' display_order, 'OFFLINE' status, 'F01' resource_ref, 'Discovered from GoldenGate parameter file /u02/Deployment/etc/conf/ogg/f01.prm. Runtime status: UNKNOWN. MAP count: 3.' description from dual) s
   on (d.node_code = s.node_code)
 when matched then update set d.node_name = s.node_name, d.node_type = s.node_type, d.domain_name = s.domain_name, d.system_name = s.system_name, d.layer_no = s.layer_no, d.display_order = s.display_order, d.status = s.status, d.resource_ref = s.resource_ref, d.description = s.description, d.updated_at = systimestamp
 when not matched then insert (node_code, node_name, node_type, domain_name, system_name, layer_no, display_order, status, resource_ref, description)
   values (s.node_code, s.node_name, s.node_type, s.domain_name, s.system_name, s.layer_no, s.display_order, s.status, s.resource_ref, s.description);

merge into ggadmin.fabric_node d
using (select 'OGG_REPLICAT_F02' node_code, 'Replicat F02' node_name, 'OGG_REPLICAT' node_type, 'GoldenGate' domain_name, 'demo_ogg_23ai' system_name, 4 layer_no, '60' display_order, 'OFFLINE' status, 'F02' resource_ref, 'Discovered from GoldenGate parameter file /u02/Deployment/etc/conf/ogg/f02.prm. Runtime status: UNKNOWN. MAP count: 28.' description from dual) s
   on (d.node_code = s.node_code)
 when matched then update set d.node_name = s.node_name, d.node_type = s.node_type, d.domain_name = s.domain_name, d.system_name = s.system_name, d.layer_no = s.layer_no, d.display_order = s.display_order, d.status = s.status, d.resource_ref = s.resource_ref, d.description = s.description, d.updated_at = systimestamp
 when not matched then insert (node_code, node_name, node_type, domain_name, system_name, layer_no, display_order, status, resource_ref, description)
   values (s.node_code, s.node_name, s.node_type, s.domain_name, s.system_name, s.layer_no, s.display_order, s.status, s.resource_ref, s.description);

merge into ggadmin.fabric_node d
using (select 'OGG_REPLICAT_FD01' node_code, 'Replicat FD01' node_name, 'OGG_REPLICAT' node_type, 'GoldenGate' domain_name, 'demo_ogg_23ai' system_name, 4 layer_no, '70' display_order, 'ACTIVE' status, 'FD01' resource_ref, 'Discovered from GoldenGate parameter file /u02/Deployment/etc/conf/ogg/fd01.prm. Runtime status: RUNNING. MAP count: 27.' description from dual) s
   on (d.node_code = s.node_code)
 when matched then update set d.node_name = s.node_name, d.node_type = s.node_type, d.domain_name = s.domain_name, d.system_name = s.system_name, d.layer_no = s.layer_no, d.display_order = s.display_order, d.status = s.status, d.resource_ref = s.resource_ref, d.description = s.description, d.updated_at = systimestamp
 when not matched then insert (node_code, node_name, node_type, domain_name, system_name, layer_no, display_order, status, resource_ref, description)
   values (s.node_code, s.node_name, s.node_type, s.domain_name, s.system_name, s.layer_no, s.display_order, s.status, s.resource_ref, s.description);

merge into ggadmin.fabric_node d
using (select 'OGG_REPLICAT_FD02' node_code, 'Replicat FD02' node_name, 'OGG_REPLICAT' node_type, 'GoldenGate' domain_name, 'demo_ogg_23ai' system_name, 4 layer_no, '80' display_order, 'ACTIVE' status, 'FD02' resource_ref, 'Discovered from GoldenGate parameter file /u02/Deployment/etc/conf/ogg/fd02.prm. Runtime status: RUNNING. MAP count: 2.' description from dual) s
   on (d.node_code = s.node_code)
 when matched then update set d.node_name = s.node_name, d.node_type = s.node_type, d.domain_name = s.domain_name, d.system_name = s.system_name, d.layer_no = s.layer_no, d.display_order = s.display_order, d.status = s.status, d.resource_ref = s.resource_ref, d.description = s.description, d.updated_at = systimestamp
 when not matched then insert (node_code, node_name, node_type, domain_name, system_name, layer_no, display_order, status, resource_ref, description)
   values (s.node_code, s.node_name, s.node_type, s.domain_name, s.system_name, s.layer_no, s.display_order, s.status, s.resource_ref, s.description);

merge into ggadmin.fabric_node d
using (select 'OGG_REPLICAT_FD03' node_code, 'Replicat FD03' node_name, 'OGG_REPLICAT' node_type, 'GoldenGate' domain_name, 'demo_ogg_23ai' system_name, 4 layer_no, '90' display_order, 'ACTIVE' status, 'FD03' resource_ref, 'Discovered from GoldenGate parameter file /u02/Deployment/etc/conf/ogg/fd03.prm. Runtime status: RUNNING. MAP count: 2.' description from dual) s
   on (d.node_code = s.node_code)
 when matched then update set d.node_name = s.node_name, d.node_type = s.node_type, d.domain_name = s.domain_name, d.system_name = s.system_name, d.layer_no = s.layer_no, d.display_order = s.display_order, d.status = s.status, d.resource_ref = s.resource_ref, d.description = s.description, d.updated_at = systimestamp
 when not matched then insert (node_code, node_name, node_type, domain_name, system_name, layer_no, display_order, status, resource_ref, description)
   values (s.node_code, s.node_name, s.node_type, s.domain_name, s.system_name, s.layer_no, s.display_order, s.status, s.resource_ref, s.description);

merge into ggadmin.fabric_node_property d
using (select 'OGG_EXTRACT_C01' node_code, 'parameter_file' property_name, '/u02/Deployment/etc/conf/ogg/c01.prm' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_EXTRACT_C01' node_code, 'runtime_status' property_name, 'RUNNING' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_EXTRACT_C01' node_code, 'useridalias' property_name, 'src_ogg DOMAIN OracleGoldenGate' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_EXTRACT_C01' node_code, 'trail' property_name, 'ca' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_EXTRACT_C01' node_code, 'table_count' property_name, '1' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_EXTRACT_C01' node_code, 'tables' property_name, 'SOE.*' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_EXTRACT_C02' node_code, 'parameter_file' property_name, '/u02/Deployment/etc/conf/ogg/c02.prm' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_EXTRACT_C02' node_code, 'runtime_status' property_name, 'UNKNOWN' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_EXTRACT_C02' node_code, 'useridalias' property_name, 'src_ogg DOMAIN OracleGoldenGate' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_EXTRACT_C02' node_code, 'trail' property_name, 'k2' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_EXTRACT_C02' node_code, 'table_count' property_name, '3' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_EXTRACT_C02' node_code, 'tables' property_name, 'SOE.CFUND_DT, SOE.OPSTATUS, SOE.TOT_AMT' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_EXTRACT_CR01' node_code, 'parameter_file' property_name, '/u02/Deployment/etc/conf/ogg/CR01.prm' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_EXTRACT_CR01' node_code, 'runtime_status' property_name, 'STOPPED' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_EXTRACT_CR01' node_code, 'useridalias' property_name, 'src_ogg DOMAIN OracleGoldenGate' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_EXTRACT_CR01' node_code, 'trail' property_name, 'cr' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_EXTRACT_CR01' node_code, 'table_count' property_name, '1' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_EXTRACT_CR01' node_code, 'tables' property_name, 'SOE.*' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_EXTRACT_CW01' node_code, 'parameter_file' property_name, '/u02/Deployment/etc/conf/ogg/CW01.prm' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_EXTRACT_CW01' node_code, 'runtime_status' property_name, 'STOPPED' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_EXTRACT_CW01' node_code, 'useridalias' property_name, 'src_ogg DOMAIN OracleGoldenGate' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_EXTRACT_CW01' node_code, 'trail' property_name, 'cw' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_EXTRACT_CW01' node_code, 'table_count' property_name, '1' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_EXTRACT_CW01' node_code, 'tables' property_name, 'SOE.*' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_REPLICAT_D01' node_code, 'parameter_file' property_name, '/u02/Deployment/etc/conf/ogg/d01.prm' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_REPLICAT_D01' node_code, 'runtime_status' property_name, 'UNKNOWN' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_REPLICAT_D01' node_code, 'useridalias' property_name, 'trg_ogg DOMAIN OracleGoldenGate' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_REPLICAT_D01' node_code, 'map_count' property_name, '1' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_REPLICAT_D01' node_code, 'maps' property_name, 'SOE.*' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_REPLICAT_D02' node_code, 'parameter_file' property_name, '/u02/Deployment/etc/conf/ogg/d02.prm' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_REPLICAT_D02' node_code, 'runtime_status' property_name, 'UNKNOWN' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_REPLICAT_D02' node_code, 'useridalias' property_name, 'trg_ogg domain OracleGoldenGate' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_REPLICAT_D02' node_code, 'map_count' property_name, '1' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_REPLICAT_D02' node_code, 'maps' property_name, 'SOE.EMPLOYEE' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_REPLICAT_DR01' node_code, 'parameter_file' property_name, '/u02/Deployment/etc/conf/ogg/DR01.prm' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_REPLICAT_DR01' node_code, 'runtime_status' property_name, 'STOPPED' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_REPLICAT_DR01' node_code, 'useridalias' property_name, 'trg_ogg DOMAIN OracleGoldenGate' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_REPLICAT_DR01' node_code, 'map_count' property_name, '1' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_REPLICAT_DR01' node_code, 'maps' property_name, 'SOE.*' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_REPLICAT_DW01' node_code, 'parameter_file' property_name, '/u02/Deployment/etc/conf/ogg/DW01.prm' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_REPLICAT_DW01' node_code, 'runtime_status' property_name, 'STOPPED' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_REPLICAT_DW01' node_code, 'useridalias' property_name, 'trg_ogg DOMAIN OracleGoldenGate' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_REPLICAT_DW01' node_code, 'map_count' property_name, '1' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_REPLICAT_DW01' node_code, 'maps' property_name, 'SOE.*' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_REPLICAT_F01' node_code, 'parameter_file' property_name, '/u02/Deployment/etc/conf/ogg/f01.prm' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_REPLICAT_F01' node_code, 'runtime_status' property_name, 'UNKNOWN' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_REPLICAT_F01' node_code, 'useridalias' property_name, 'trg_ogg DOMAIN OracleGoldenGate' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_REPLICAT_F01' node_code, 'map_count' property_name, '3' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_REPLICAT_F01' node_code, 'maps' property_name, 'SOE.CFUND_DT, SOE.OPSTATUS, SOE.TOT_AMT' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_REPLICAT_F02' node_code, 'parameter_file' property_name, '/u02/Deployment/etc/conf/ogg/f02.prm' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_REPLICAT_F02' node_code, 'runtime_status' property_name, 'UNKNOWN' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_REPLICAT_F02' node_code, 'useridalias' property_name, 'trg_ogg DOMAIN OracleGoldenGate' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_REPLICAT_F02' node_code, 'map_count' property_name, '27' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_REPLICAT_F02' node_code, 'maps' property_name, 'SOE.ADDRESS, SOE.ADDRESS_BAK_BEFORE_ENRICH, SOE.ADDRESS_BAK_SEOUL_20261008_125131, SOE.CALL_CENTER_LOG, SOE.CANCELAMT, SOE.CANCELFP, SOE.CFUND_DEPOSIT, SOE.CFUND_RAT, SOE.CFUND_RATIO, SOE.CFUND_RAT_TMP, SOE.CUST_DEP_DT, SOE.CUST_GEN_AMT, SOE.CUST_INFO, SOE.CUST_PR, SOE.EMPLOYEE, SOE.FUNDM, SOE.FUND_PRICE, SOE.HEARTBP, SOE.MSG, SOE.OGG_SYNC_UNIT_TEST, SOE.OPM, SOE.OSA_CANCEL_PREDICTION, SOE.OSA_CANCEL_PREDICTION_GEN, SOE.PRODUCT, SOE.RESERVES_AMT, SOE.SUCCESS_CASE_KNOWLEDGE, SOE.TMP_TRIGGER' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_EXTRACT_FC01' node_code, 'parameter_file' property_name, '/u02/Deployment/etc/conf/ogg/fc01.prm' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_EXTRACT_FC01' node_code, 'runtime_status' property_name, 'RUNNING' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_EXTRACT_FC01' node_code, 'useridalias' property_name, 'src_ogg DOMAIN OracleGoldenGate' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_EXTRACT_FC01' node_code, 'trail' property_name, 'k1' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_EXTRACT_FC01' node_code, 'table_count' property_name, '27' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_EXTRACT_FC01' node_code, 'tables' property_name, 'SOE.ADDRESS, SOE.ADDRESS_BAK_BEFORE_ENRICH, SOE.ADDRESS_BAK_SEOUL_20261008_125131, SOE.CALL_CENTER_LOG, SOE.CANCELFP, SOE.CFUND_DEPOSIT, SOE.CFUND_RAT, SOE.CFUND_RATIO, SOE.CFUND_RAT_TMP, SOE.CUST_DEP_DT, SOE.CUST_GEN_AMT, SOE.CUST_INFO, SOE.CUST_PR, SOE.EMPLOYEE, SOE.FUNDM, SOE.FUND_PRICE, SOE.HEARTBP, SOE.MSG, SOE.OGG_SYNC_UNIT_TEST, SOE.OSA_CANCEL_PREDICTION, SOE.OSA_CANCEL_PREDICTION_GEN, SOE.PRODUCT, SOE.RESERVES_AMT, SOE.SUCCESS_CASE_KNOWLEDGE, SOE.TMP_TRIGGER, SOE.TOT_AMT, SOE.CANCELAMT' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_EXTRACT_FC02' node_code, 'parameter_file' property_name, '/u02/Deployment/etc/conf/ogg/fc02.prm' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_EXTRACT_FC02' node_code, 'runtime_status' property_name, 'RUNNING' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_EXTRACT_FC02' node_code, 'useridalias' property_name, 'src_ogg DOMAIN OracleGoldenGate' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_EXTRACT_FC02' node_code, 'trail' property_name, 'k2' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_EXTRACT_FC02' node_code, 'table_count' property_name, '3' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_EXTRACT_FC02' node_code, 'tables' property_name, 'SOE.CFUND_DT, SOE.OPSTATUS, SOE.OPM' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_REPLICAT_FD01' node_code, 'parameter_file' property_name, '/u02/Deployment/etc/conf/ogg/fd01.prm' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_REPLICAT_FD01' node_code, 'runtime_status' property_name, 'RUNNING' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_REPLICAT_FD01' node_code, 'useridalias' property_name, 'trg_ogg DOMAIN OracleGoldenGate' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_REPLICAT_FD01' node_code, 'map_count' property_name, '26' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_REPLICAT_FD01' node_code, 'maps' property_name, 'SOE.ADDRESS, SOE.ADDRESS_BAK_BEFORE_ENRICH, SOE.ADDRESS_BAK_SEOUL_20261008_125131, SOE.CALL_CENTER_LOG, SOE.CANCELFP, SOE.CFUND_DEPOSIT, SOE.CFUND_RAT, SOE.CFUND_RATIO, SOE.CFUND_RAT_TMP, SOE.CUST_DEP_DT, SOE.CUST_GEN_AMT, SOE.CUST_INFO, SOE.CUST_PR, SOE.EMPLOYEE, SOE.FUNDM, SOE.FUND_PRICE, SOE.HEARTBP, SOE.MSG, SOE.OGG_SYNC_UNIT_TEST, SOE.OSA_CANCEL_PREDICTION, SOE.OSA_CANCEL_PREDICTION_GEN, SOE.PRODUCT, SOE.RESERVES_AMT, SOE.SUCCESS_CASE_KNOWLEDGE, SOE.TMP_TRIGGER, SOE.CANCELAMT' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_REPLICAT_FD02' node_code, 'parameter_file' property_name, '/u02/Deployment/etc/conf/ogg/fd02.prm' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_REPLICAT_FD02' node_code, 'runtime_status' property_name, 'RUNNING' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_REPLICAT_FD02' node_code, 'useridalias' property_name, 'trg_ogg DOMAIN OracleGoldenGate' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_REPLICAT_FD02' node_code, 'map_count' property_name, '2' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_REPLICAT_FD02' node_code, 'maps' property_name, 'SOE.CFUND_DT, SOE.OPM' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_REPLICAT_FD03' node_code, 'parameter_file' property_name, '/u02/Deployment/etc/conf/ogg/fd03.prm' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_REPLICAT_FD03' node_code, 'runtime_status' property_name, 'RUNNING' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_REPLICAT_FD03' node_code, 'useridalias' property_name, 'trg_ogg DOMAIN OracleGoldenGate' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_REPLICAT_FD03' node_code, 'map_count' property_name, '2' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_REPLICAT_FD03' node_code, 'maps' property_name, 'SOE.OPSTATUS, SOE.TOT_AMT' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_EXTRACT_T01' node_code, 'parameter_file' property_name, '/u02/Deployment/etc/conf/ogg/t01.prm' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_EXTRACT_T01' node_code, 'runtime_status' property_name, 'UNKNOWN' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_EXTRACT_T01' node_code, 'table_count' property_name, '1' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_EXTRACT_T01' node_code, 'tables' property_name, 'SOE.EMPLOYEE' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_REPLICAT_DR01' node_code, 'read_trail' property_name, 'cr' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_REPLICAT_DW01' node_code, 'read_trail' property_name, 'cw' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_REPLICAT_FD01' node_code, 'read_trail' property_name, 'k1' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_REPLICAT_FD02' node_code, 'read_trail' property_name, 'k2' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_node_property d
using (select 'OGG_REPLICAT_FD03' node_code, 'read_trail' property_name, 'k2' property_value from dual) s
   on (d.node_code = s.node_code and d.property_name = s.property_name)
 when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp
 when not matched then insert (node_code, property_name, property_value)
   values (s.node_code, s.property_name, s.property_value);

merge into ggadmin.fabric_edge d
using (select 'DISC_OGG_EXTRACT_C01_TO_OGG_TRAIL_CA' edge_code, 'OGG_EXTRACT_C01' from_node_code, 'OGG_TRAIL_CA' to_node_code, 'WRITE_TRAIL' edge_type, 'confidence=HIGH; source=parameter; trail=ca' mapping_ref, 'ACTIVE' status, 'C01 writes trail ca based on parameter file.' description from dual) s
   on (d.edge_code = s.edge_code)
 when matched then update set d.from_node_code = s.from_node_code, d.to_node_code = s.to_node_code, d.edge_type = s.edge_type, d.mapping_ref = s.mapping_ref, d.status = s.status, d.description = s.description, d.updated_at = systimestamp
 when not matched then insert (edge_code, from_node_code, to_node_code, edge_type, mapping_ref, status, description)
   values (s.edge_code, s.from_node_code, s.to_node_code, s.edge_type, s.mapping_ref, s.status, s.description);

merge into ggadmin.fabric_edge d
using (select 'DISC_OGG_EXTRACT_C02_TO_OGG_TRAIL_K2' edge_code, 'OGG_EXTRACT_C02' from_node_code, 'OGG_TRAIL_K2' to_node_code, 'WRITE_TRAIL' edge_type, 'confidence=HIGH; source=parameter; trail=k2' mapping_ref, 'OFFLINE' status, 'C02 writes trail k2 based on parameter file.' description from dual) s
   on (d.edge_code = s.edge_code)
 when matched then update set d.from_node_code = s.from_node_code, d.to_node_code = s.to_node_code, d.edge_type = s.edge_type, d.mapping_ref = s.mapping_ref, d.status = s.status, d.description = s.description, d.updated_at = systimestamp
 when not matched then insert (edge_code, from_node_code, to_node_code, edge_type, mapping_ref, status, description)
   values (s.edge_code, s.from_node_code, s.to_node_code, s.edge_type, s.mapping_ref, s.status, s.description);

merge into ggadmin.fabric_edge d
using (select 'DISC_OGG_EXTRACT_CR01_TO_OGG_TRAIL_CR' edge_code, 'OGG_EXTRACT_CR01' from_node_code, 'OGG_TRAIL_CR' to_node_code, 'WRITE_TRAIL' edge_type, 'confidence=HIGH; source=parameter; trail=cr' mapping_ref, 'OFFLINE' status, 'CR01 writes trail cr based on parameter file.' description from dual) s
   on (d.edge_code = s.edge_code)
 when matched then update set d.from_node_code = s.from_node_code, d.to_node_code = s.to_node_code, d.edge_type = s.edge_type, d.mapping_ref = s.mapping_ref, d.status = s.status, d.description = s.description, d.updated_at = systimestamp
 when not matched then insert (edge_code, from_node_code, to_node_code, edge_type, mapping_ref, status, description)
   values (s.edge_code, s.from_node_code, s.to_node_code, s.edge_type, s.mapping_ref, s.status, s.description);

merge into ggadmin.fabric_edge d
using (select 'DISC_OGG_EXTRACT_CW01_TO_OGG_TRAIL_CW' edge_code, 'OGG_EXTRACT_CW01' from_node_code, 'OGG_TRAIL_CW' to_node_code, 'WRITE_TRAIL' edge_type, 'confidence=HIGH; source=parameter; trail=cw' mapping_ref, 'OFFLINE' status, 'CW01 writes trail cw based on parameter file.' description from dual) s
   on (d.edge_code = s.edge_code)
 when matched then update set d.from_node_code = s.from_node_code, d.to_node_code = s.to_node_code, d.edge_type = s.edge_type, d.mapping_ref = s.mapping_ref, d.status = s.status, d.description = s.description, d.updated_at = systimestamp
 when not matched then insert (edge_code, from_node_code, to_node_code, edge_type, mapping_ref, status, description)
   values (s.edge_code, s.from_node_code, s.to_node_code, s.edge_type, s.mapping_ref, s.status, s.description);

merge into ggadmin.fabric_edge d
using (select 'DISC_OGG_EXTRACT_FC01_TO_OGG_TRAIL_K1' edge_code, 'OGG_EXTRACT_FC01' from_node_code, 'OGG_TRAIL_K1' to_node_code, 'WRITE_TRAIL' edge_type, 'confidence=HIGH; source=parameter; trail=k1' mapping_ref, 'ACTIVE' status, 'FC01 writes trail k1 based on parameter file.' description from dual) s
   on (d.edge_code = s.edge_code)
 when matched then update set d.from_node_code = s.from_node_code, d.to_node_code = s.to_node_code, d.edge_type = s.edge_type, d.mapping_ref = s.mapping_ref, d.status = s.status, d.description = s.description, d.updated_at = systimestamp
 when not matched then insert (edge_code, from_node_code, to_node_code, edge_type, mapping_ref, status, description)
   values (s.edge_code, s.from_node_code, s.to_node_code, s.edge_type, s.mapping_ref, s.status, s.description);

merge into ggadmin.fabric_edge d
using (select 'DISC_OGG_EXTRACT_FC02_TO_OGG_TRAIL_K2' edge_code, 'OGG_EXTRACT_FC02' from_node_code, 'OGG_TRAIL_K2' to_node_code, 'WRITE_TRAIL' edge_type, 'confidence=HIGH; source=parameter; trail=k2' mapping_ref, 'ACTIVE' status, 'FC02 writes trail k2 based on parameter file.' description from dual) s
   on (d.edge_code = s.edge_code)
 when matched then update set d.from_node_code = s.from_node_code, d.to_node_code = s.to_node_code, d.edge_type = s.edge_type, d.mapping_ref = s.mapping_ref, d.status = s.status, d.description = s.description, d.updated_at = systimestamp
 when not matched then insert (edge_code, from_node_code, to_node_code, edge_type, mapping_ref, status, description)
   values (s.edge_code, s.from_node_code, s.to_node_code, s.edge_type, s.mapping_ref, s.status, s.description);

merge into ggadmin.fabric_edge d
using (select 'DISC_OGG_TRAIL_CR_TO_OGG_REPLICAT_DR01' edge_code, 'OGG_TRAIL_CR' from_node_code, 'OGG_REPLICAT_DR01' to_node_code, 'APPLY' edge_type, 'confidence=HIGH; source=runtime_checkpoint; trail=cr' mapping_ref, 'OFFLINE' status, 'DR01 reads trail cr according to AdminClient info detail.' description from dual) s
   on (d.edge_code = s.edge_code)
 when matched then update set d.from_node_code = s.from_node_code, d.to_node_code = s.to_node_code, d.edge_type = s.edge_type, d.mapping_ref = s.mapping_ref, d.status = s.status, d.description = s.description, d.updated_at = systimestamp
 when not matched then insert (edge_code, from_node_code, to_node_code, edge_type, mapping_ref, status, description)
   values (s.edge_code, s.from_node_code, s.to_node_code, s.edge_type, s.mapping_ref, s.status, s.description);

merge into ggadmin.fabric_edge d
using (select 'DISC_OGG_TRAIL_CW_TO_OGG_REPLICAT_DW01' edge_code, 'OGG_TRAIL_CW' from_node_code, 'OGG_REPLICAT_DW01' to_node_code, 'APPLY' edge_type, 'confidence=HIGH; source=runtime_checkpoint; trail=cw' mapping_ref, 'OFFLINE' status, 'DW01 reads trail cw according to AdminClient info detail.' description from dual) s
   on (d.edge_code = s.edge_code)
 when matched then update set d.from_node_code = s.from_node_code, d.to_node_code = s.to_node_code, d.edge_type = s.edge_type, d.mapping_ref = s.mapping_ref, d.status = s.status, d.description = s.description, d.updated_at = systimestamp
 when not matched then insert (edge_code, from_node_code, to_node_code, edge_type, mapping_ref, status, description)
   values (s.edge_code, s.from_node_code, s.to_node_code, s.edge_type, s.mapping_ref, s.status, s.description);

merge into ggadmin.fabric_edge d
using (select 'DISC_OGG_TRAIL_K1_TO_OGG_REPLICAT_D02' edge_code, 'OGG_TRAIL_K1' from_node_code, 'OGG_REPLICAT_D02' to_node_code, 'APPLY' edge_type, 'confidence=MEDIUM; source=table_map_intersection; matched=1' mapping_ref, 'OFFLINE' status, 'D02 is linked to FC01 trail by matching MAP entries to captured TABLE entries.' description from dual) s
   on (d.edge_code = s.edge_code)
 when matched then update set d.from_node_code = s.from_node_code, d.to_node_code = s.to_node_code, d.edge_type = s.edge_type, d.mapping_ref = s.mapping_ref, d.status = s.status, d.description = s.description, d.updated_at = systimestamp
 when not matched then insert (edge_code, from_node_code, to_node_code, edge_type, mapping_ref, status, description)
   values (s.edge_code, s.from_node_code, s.to_node_code, s.edge_type, s.mapping_ref, s.status, s.description);

merge into ggadmin.fabric_edge d
using (select 'DISC_OGG_TRAIL_K2_TO_OGG_REPLICAT_F01' edge_code, 'OGG_TRAIL_K2' from_node_code, 'OGG_REPLICAT_F01' to_node_code, 'APPLY' edge_type, 'confidence=MEDIUM; source=table_map_intersection; matched=3' mapping_ref, 'OFFLINE' status, 'F01 is linked to C02 trail by matching MAP entries to captured TABLE entries.' description from dual) s
   on (d.edge_code = s.edge_code)
 when matched then update set d.from_node_code = s.from_node_code, d.to_node_code = s.to_node_code, d.edge_type = s.edge_type, d.mapping_ref = s.mapping_ref, d.status = s.status, d.description = s.description, d.updated_at = systimestamp
 when not matched then insert (edge_code, from_node_code, to_node_code, edge_type, mapping_ref, status, description)
   values (s.edge_code, s.from_node_code, s.to_node_code, s.edge_type, s.mapping_ref, s.status, s.description);

merge into ggadmin.fabric_edge d
using (select 'DISC_OGG_TRAIL_K1_TO_OGG_REPLICAT_F02' edge_code, 'OGG_TRAIL_K1' from_node_code, 'OGG_REPLICAT_F02' to_node_code, 'APPLY' edge_type, 'confidence=MEDIUM; source=table_map_intersection; matched=27' mapping_ref, 'OFFLINE' status, 'F02 is linked to FC01 trail by matching MAP entries to captured TABLE entries.' description from dual) s
   on (d.edge_code = s.edge_code)
 when matched then update set d.from_node_code = s.from_node_code, d.to_node_code = s.to_node_code, d.edge_type = s.edge_type, d.mapping_ref = s.mapping_ref, d.status = s.status, d.description = s.description, d.updated_at = systimestamp
 when not matched then insert (edge_code, from_node_code, to_node_code, edge_type, mapping_ref, status, description)
   values (s.edge_code, s.from_node_code, s.to_node_code, s.edge_type, s.mapping_ref, s.status, s.description);

merge into ggadmin.fabric_edge d
using (select 'DISC_OGG_TRAIL_K1_TO_OGG_REPLICAT_FD01' edge_code, 'OGG_TRAIL_K1' from_node_code, 'OGG_REPLICAT_FD01' to_node_code, 'APPLY' edge_type, 'confidence=HIGH; source=runtime_checkpoint; trail=k1' mapping_ref, 'ACTIVE' status, 'FD01 reads trail k1 according to AdminClient info detail.' description from dual) s
   on (d.edge_code = s.edge_code)
 when matched then update set d.from_node_code = s.from_node_code, d.to_node_code = s.to_node_code, d.edge_type = s.edge_type, d.mapping_ref = s.mapping_ref, d.status = s.status, d.description = s.description, d.updated_at = systimestamp
 when not matched then insert (edge_code, from_node_code, to_node_code, edge_type, mapping_ref, status, description)
   values (s.edge_code, s.from_node_code, s.to_node_code, s.edge_type, s.mapping_ref, s.status, s.description);

merge into ggadmin.fabric_edge d
using (select 'DISC_OGG_TRAIL_K2_TO_OGG_REPLICAT_FD02' edge_code, 'OGG_TRAIL_K2' from_node_code, 'OGG_REPLICAT_FD02' to_node_code, 'APPLY' edge_type, 'confidence=HIGH; source=runtime_checkpoint; trail=k2' mapping_ref, 'ACTIVE' status, 'FD02 reads trail k2 according to AdminClient info detail.' description from dual) s
   on (d.edge_code = s.edge_code)
 when matched then update set d.from_node_code = s.from_node_code, d.to_node_code = s.to_node_code, d.edge_type = s.edge_type, d.mapping_ref = s.mapping_ref, d.status = s.status, d.description = s.description, d.updated_at = systimestamp
 when not matched then insert (edge_code, from_node_code, to_node_code, edge_type, mapping_ref, status, description)
   values (s.edge_code, s.from_node_code, s.to_node_code, s.edge_type, s.mapping_ref, s.status, s.description);

merge into ggadmin.fabric_edge d
using (select 'DISC_OGG_TRAIL_K2_TO_OGG_REPLICAT_FD03' edge_code, 'OGG_TRAIL_K2' from_node_code, 'OGG_REPLICAT_FD03' to_node_code, 'APPLY' edge_type, 'confidence=HIGH; source=runtime_checkpoint; trail=k2' mapping_ref, 'ACTIVE' status, 'FD03 reads trail k2 according to AdminClient info detail.' description from dual) s
   on (d.edge_code = s.edge_code)
 when matched then update set d.from_node_code = s.from_node_code, d.to_node_code = s.to_node_code, d.edge_type = s.edge_type, d.mapping_ref = s.mapping_ref, d.status = s.status, d.description = s.description, d.updated_at = systimestamp
 when not matched then insert (edge_code, from_node_code, to_node_code, edge_type, mapping_ref, status, description)
   values (s.edge_code, s.from_node_code, s.to_node_code, s.edge_type, s.mapping_ref, s.status, s.description);

commit;
prompt Fabric metadata refreshed from GoldenGate parameter files.
