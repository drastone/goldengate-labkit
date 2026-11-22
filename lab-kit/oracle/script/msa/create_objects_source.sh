sqlplus -s / as sysdba << EOF1
drop public database link to_pdb;
create public database link to_pdb using 'ORCLPDB1';
EOF1

sqlplus soe/soe@orclpdb1 << EOF
drop table soe.moncap purge;

create table soe.moncap (
"CALL_TIME" date DEFAULT sysdate,
capture_name varchar2(30),
extract_name varchar2(30), 
state varchar2(60),
TOTAL_MESSAGES_CAPTURED number, 
sga_used number, 
sga_allocated number,
last_send_message_number number);

alter table soe.moncap add constraints moncap_pk primary key (call_time,capture_name);

exit;

/
EOF