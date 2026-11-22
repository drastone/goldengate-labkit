--## 23ai target 
--#docker exec -it demo_otrg_23ai bash

sqlplus / as sysdba

--alter user sys identified by welcome1 account unlock; 
alter user sys identified by WElcome1234## account unlock; 

alter system set enable_goldengate_replication=true; 
alter system set streams_pool_size=500m;

alter session set container=orclpdb1;
create tablespace SOE datafile '/opt/oracle/oradata/FREE/FREEPDB1/soe01.dbf' size 500M
extent management local uniform size 1M
segment space management auto;

create user soe identified by soe
default tablespace SOE temporary tablespace TEMP account unlock;
grant CONNECT, RESOURCE, CREATE VIEW, ALTER SESSION, ANALYZE ANY DICTIONARY, ANALYZE ANY, CREATE JOB, MANAGE SCHEDULER, MANAGE ANY QUEUE to SOE;
grant EXECUTE ON dbms_lock to SOE;
alter user soe quota unlimited on soe;

create table soe.employee (
	id number not null primary key,
	name varchar2(100),
	email varchar2(100),
	age number,
	PHONENUMBER VARCHAR2(20),
	job varchar2(100),
	created date
);

create table soe.test1 (keya number not null, step varchar2(20));

--by cys 20250109
create directory trails as '/home/oracle/script/msa/23aifree/trails';
grant read,write on directory trails to ggadmin;

alter session set container=CDB$ROOT;

create tablespace OGG datafile '/opt/oracle/oradata/FREE/ogg01.dbf' size 200M extent management local uniform size 1M segment space management auto;

alter session set container=orclpdb1;
create tablespace OGG datafile '/opt/oracle/oradata/FREE/FREEPDB1/ogg01.dbf' size 200M extent management local uniform size 1M segment space management auto;
create user ggadmin identified by ogg default tablespace ogg temporary tablespace temp account unlock;
grant OGG_CAPTURE to ggadmin;
grant OGG_APPLY to ggadmin;
grant OGG_APPLY_PROCREP to ggadmin;
grant connect, resource, dba to ggadmin ;

alter session set container=CDB$ROOT;
create user c##ogg identified by ogg container=all default tablespace ogg temporary tablespace temp account unlock;

grant OGG_CAPTURE to C##OGG;
grant OGG_APPLY to C##OGG;
grant OGG_APPLY_PROCREP to C##OGG;
grant connect, resource, dba to c##ogg container=all;


shutdown immediate
startup mount
alter database archivelog;
alter database open;
exit
