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


drop table ggadmin.monevnt purge;
create table ggadmin.monevnt (
"CALL_TIME" date DEFAULT sysdate            ,
INST           NUMBER                       ,
SID            NUMBER                       ,
SERIAL#        NUMBER                       ,
SPID           VARCHAR2(24)                 ,
STATUS         VARCHAR2(8)                  ,
EVENT          VARCHAR2(64)                 ,
CLI_SPID       VARCHAR2(24)                 ,
P              VARCHAR2(185)                ,
W              NUMBER                       ,
PROGRAM        VARCHAR2(72)                 ,
C              VARCHAR2(40)                 ,
SQL_ID         VARCHAR2(13)                 ,
OBJECT_NAME    VARCHAR2(80)                 ,
BLKSID         NUMBER                       ,
LATCH_NAME     VARCHAR2(40)                 ,
WAIT_CLASS     VARCHAR2(64)                
);	

alter table ggadmin.monevnt add constraints monevnt_pk primary key (call_time,inst,sid,serial#,spid,event);

exit;

/
EOF
