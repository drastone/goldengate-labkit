sqlplus -s / as sysdba << EOF
alter session set container=orclpdb1;
drop table soe.restmon purge;
create table soe.restmon (
id number,
"CALL_TIME" date DEFAULT sysdate,
process_name varchar2(30),
status varchar2(20),
in_prefix varchar2(20),
in_seq number,
in_rba number,
out_prefix varchar2(20),
out_seq number,
out_rba number,        
lag number,
sincelagreported number,
cachesize number,
maxVmUsed number,
currentVmUsed number,
currentMmapAnon number,
currentMmapRecycles number,
bytesToDisk number,
brTotStateSize number,
brTotDataSize number,
resv1 varchar2(20),
resv2 varchar2(20),
resv3 varchar2(20),
resv4 varchar2(20),
resv5 varchar2(20)
);
alter table soe.restmon add constraints restmon_pk primary key (id,call_time,process_name);

drop table soe.monres purge;
create table soe.monres (
"CALL_TIME" date DEFAULT sysdate,
keya varchar2(30) default (' '),
keyb varchar2(30) default (' '),
keyc varchar2(30) default (' '),
keyd varchar2(30) default (' '),
keye varchar2(30) default (' '),
val1 varchar2(50),
val2 varchar2(50),
val3 varchar2(50),
val4 varchar2(50),
val5 varchar2(50),
val6 varchar2(50),
val7 varchar2(50),
val8 varchar2(50),
val9 varchar2(50),
val10 varchar2(50)
);
alter table soe.monres add constraints monres_pk primary key (call_time,keya,keyb,keyc,keyd,keye);


drop sequence soe.oggseq ;
create sequence soe.oggseq start with 1 increment by 1 maxvalue 9999999999999;

drop TABLE soe."RESPONSE" purge;
CREATE TABLE soe."RESPONSE" 
(    "ID" NUMBER GENERATED ALWAYS AS IDENTITY, 
"RUN_ID" NUMBER, 
"RUN_SEQ" NUMBER, 
"CALL_TTIME" TIMESTAMP (6) DEFAULT systimestamp, 
"REST_URL" VARCHAR2(1000 CHAR), 
"HTTP_METHOD" VARCHAR2(6 CHAR), 
"STATUS_CODE" NUMBER, 
"REQUEST_BODY" CLOB, 
"RESPONSE_BODY" CLOB, 
"JOIN_ID" NUMBER AS (NVL("RUN_ID","ID")), 
 CONSTRAINT "RESTREQ_ISJSON" CHECK (REQUEST_BODY is json) ENABLE, 
 CONSTRAINT "RESTRESP_ISJSON" CHECK (RESPONSE_BODY is json) ENABLE
);

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

drop VIEW gg_apply_reader;
CREATE VIEW gg_apply_reader AS SELECT * FROM gv\$gg_apply_reader  ;

grant select on gg_apply_reader to soe;

grant select any table to soe;

exit;
EOF