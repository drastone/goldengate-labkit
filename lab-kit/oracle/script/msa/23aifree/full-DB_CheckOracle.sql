-- This script spools the output to a file named schemaCheckOracle.out 
-- Example of running the script:
-- Oracle Support document ID 1298562.1
-- sqlplus <userid>/<pw> @full-DB_CheckOracle.sql

-- 9-17-07 SGEORGE - Added sequences 
-- 		   - added reverse key index check
--  3-24-08 SGEORGE - Added average archive log size
--  		    - Added number of archive log switches by hour and day
-- 3-35-08  SGEORGE - Added query for tables without PK/UK
--                  - and columns > 256k
-- 3-27-08 SGEORGE - added schema name and total size of schema
-- 		   - 
-- 5-09-08 SGEORGE - Added  exclude users list for all queries
--  not like ('SYS', 'SYSTEM', 'DBSNMP','SYSMAN','OUTLN','MDSYS','ORDSYS','EXFSYS','DMSYS','WMSYS','CTXSYS','ANONYMOUS','XDB','ORDPLUGINS','OLAPSYS')
-- 9-29-08 SGEORGE - Added set trimspool on per request.
-- 		     Also added a check for compressed tables.
-- 1-19-11 SGEORGE Update query for Tables with no PK or UI and rowsize > 256K to 1M
-- 		   Update query for Tables with rowsize > 512K to 2M
-- 		   Updated query for Tables With Columns of UNSUPPORTED Datatypes to include ORDDICOM data type
-- 		   Updated query for tables with compression enabled.
-- 2-23-11 SGEORGE - Added query to check for Compressed Tablespaces.
--                  Updated query to list Domain Indexes
--	            Updated comment on Add trandata issues.
-- 9-6-11 SGEORGE - Updated query for copression and removed "COMPRESS_FOR" to make query compatable for Oracle 10.
-- 9-7-11 SGEORGE - Added check for columns with Default values.  0 default values may cause replication problems
-- 9-27-11 SGEORGE - Removed check for default not null columns - issue has been resolved in latest release
-- 11-15-11 SGEORGE - Added check for deferred constraints.  Deferred constaints may cause ADD TRANDATA to select the 
--	            - wrong column for logging. Use KEYCOLS for tables with deferred constaints.
-- 12-07-11 SGEORGE - Added check for tables with NOLOGGING. Tables with the NOLOGGING option may cause problems  
--                  - downstream at the target.
--                 - fixed format on archive log summary to hh24
--		   - fixed various format issues
-- 05-06-14 SGEORGE - Updated comments added new view for IE.
--		    OGG database healthcheck for Integrated Extract and Integrated Replicat  (for 11.2.0.4 and 12.1 only ).
--                  These scripts have been updated recently and are available for download under MOS note 1448324.1 
-- 11-03-14 SGEORGE -  Limitation - this script will not pick up user defined datatypes (UDTs) based on varrays and LOB's.
--                     Please use the GoldenGate documentation for a complete listing of supported data types.
-- 04-29-15 SGEORGE - Added comment about deferred constraints
-- 07-08-15 SGEORGE - added query for IR and PK issue - Integrated Replicat does not support Transient Primary Key Updates 
--                    on primary key constraints that have a non-unique index under them.
--
set null "NULL VALUE"
set feedback off
set heading off
set linesize 132 
set pagesize 9999
set echo off
set verify off
set trimspool on

col table_name for a30
col column_name for a30
col data_type for a20
col object_type for a20
col constraint_type_desc for a30
col Owner format a15

spool AllSchemaCheckOracle.out

prompt - Most of the output relates to the Classic Capture configuration.  
prompt - If you are using Integrated Capture PLEASE see the new DBA view - DBA_GOLDENGATE_SUPPORT_MODE (listed below).
Prompt - IF using IE also please see health Check MOS Document ID 1448324.1
Prompt - Please be sure to read the Installing and Configuring Oracle GoldenGate for Oracle Database documentation for 
Prompt - a complete list of supported and non-supported data types.  

SELECT '------ System Info: '
FROM dual;
set heading on
select to_char(sysdate, 'MM-DD-YYYY HH24:MI:SS') "DateTime: " from dual
/
select banner from v$version
/

select name, log_mode "LogMode", 
supplemental_log_data_min "SupLog: Min", supplemental_log_data_pk "PK",
supplemental_log_data_ui "UI", force_logging "Forced",
supplemental_log_data_fk "FK", supplemental_log_data_all "All",
to_char(created, 'MM-DD-YYYY HH24:MI:SS') "Created"
from v$database
/

select  
platform_name
from v$database
/
set heading off
SELECT '------ Objects stored in Tablespaces with Compression are not supported in the current release of OGG ' 
FROM dual;
set heading on
select
	TABLESPACE_NAME,
	DEF_TAB_COMPRESSION
from DBA_TABLESPACES
where 
DEF_TAB_COMPRESSION <> 'DISABLED';


set heading off
SELECT '------ Distinct Object Types and their Count By Schema: '
FROM dual;
set heading on
SELECT owner, object_type, count(*) total
FROM all_objects
WHERE OWNER not in ('SYS', 'SYSTEM', 'DBSNMP','SYSMAN','OUTLN','MDSYS','ORDSYS','EXFSYS','DMSYS','WMSYS','CTXSYS','ANONYMOUS','XDB','ORDPLUGINS','OLAPSYS','PUBLIC')
GROUP BY object_type, owner
/

set heading off

SELECT '------ Distinct Column Data Types and their Count in the Schema: ' 
FROM dual;
set heading on
SELECT data_type, count(*) total
FROM all_tab_columns
WHERE OWNER not in ('SYS', 'SYSTEM', 'DBSNMP','SYSMAN','OUTLN','MDSYS','ORDSYS','EXFSYS','DMSYS','WMSYS','CTXSYS','ANONYMOUS','XDB','ORDPLUGINS','OLAPSYS','PUBLIC')
GROUP BY data_type
/

set heading off
SELECT '------ Tables that will Fail Add Trandata (Only an issue for Oracle versions below Oracle 10G) in the Database ' 
FROM dual;
set heading on
SELECT distinct(table_name)
FROM dba_tab_columns
WHERE owner not in ('SYS', 'SYSTEM', 'DBSNMP','SYSMAN','OUTLN','MDSYS','ORDSYS','EXFSYS','DMSYS','WMSYS','CTXSYS','ANONYMOUS','XDB','ORDPLUGINS','OLAPSYS','PUBLIC')  
AND column_id > 32
AND table_name in
(SELECT distinct(table_name)
  FROM all_tables
 WHERE owner not in ('SYS', 'SYSTEM', 'DBSNMP','SYSMAN','OUTLN','MDSYS','ORDSYS','EXFSYS','DMSYS','WMSYS','CTXSYS','ANONYMOUS','XDB','ORDPLUGINS','OLAPSYS','PUBLIC') 
MINUS
(SELECT obj1.name
  FROM SYS.user$ user1,
       SYS.user$ user2,
       SYS.cdef$ cdef,
       SYS.con$ con1,
       SYS.con$ con2,
       SYS.obj$ obj1,
       SYS.obj$ obj2
 WHERE user1.name not in ('SYS', 'SYSTEM', 'DBSNMP','SYSMAN','OUTLN','MDSYS','ORDSYS','EXFSYS','DMSYS','WMSYS','CTXSYS','ANONYMOUS','XDB','ORDPLUGINS','OLAPSYS','PUBLIC') 
   AND cdef.type# = 2
   AND con2.owner# = user2.user#(+)
   AND cdef.robj# = obj2.obj#(+)
   AND cdef.rcon# = con2.con#(+)
   AND obj1.owner# = user1.user#
   AND cdef.con# = con1.con#
   AND cdef.obj# = obj1.obj#
UNION
SELECT idx.table_name
  FROM all_indexes idx
 WHERE idx.owner not in ('SYS', 'SYSTEM', 'DBSNMP','SYSMAN','OUTLN','MDSYS','ORDSYS','EXFSYS','DMSYS','WMSYS','CTXSYS','ANONYMOUS','XDB','ORDPLUGINS','OLAPSYS','PUBLIC') 
   AND idx.uniqueness = 'UNIQUE'))
/

set heading off
SELECT '------ Tables With No Primary Key or Unique Index by Schema: ' 
FROM dual;
set heading on
SELECT owner, table_name
  FROM all_tables
 WHERE owner not in ('SYS', 'SYSTEM', 'DBSNMP','SYSMAN','OUTLN','MDSYS','ORDSYS','EXFSYS','DMSYS','WMSYS','CTXSYS','ANONYMOUS','XDB','ORDPLUGINS','OLAPSYS','PUBLIC') 
MINUS
(SELECT user1.name, obj1.name
  FROM SYS.user$ user1,
       SYS.user$ user2,
       SYS.cdef$ cdef,
       SYS.con$ con1,
       SYS.con$ con2,
       SYS.obj$ obj1,
       SYS.obj$ obj2
 WHERE user1.name not in ('SYS', 'SYSTEM', 'DBSNMP','SYSMAN','OUTLN','MDSYS','ORDSYS','EXFSYS','DMSYS','WMSYS','CTXSYS','ANONYMOUS','XDB','ORDPLUGINS','OLAPSYS','PUBLIC') 
   AND cdef.type# = 2 
   AND con2.owner# = user2.user#(+)
   AND cdef.robj# = obj2.obj#(+)
   AND cdef.rcon# = con2.con#(+)
   AND obj1.owner# = user1.user#
   AND cdef.con# = con1.con#
   AND cdef.obj# = obj1.obj#
UNION
SELECT distinct(owner), idx.table_name
  FROM all_indexes idx
 WHERE idx.owner not in ('SYS', 'SYSTEM', 'DBSNMP','SYSMAN','OUTLN','MDSYS','ORDSYS','EXFSYS','DMSYS','WMSYS','CTXSYS','ANONYMOUS','XDB','ORDPLUGINS','OLAPSYS','PUBLIC') 
   AND idx.uniqueness = 'UNIQUE')
/

set heading off
SELECT '------ Tables with NOLOGGING setting ' FROM dual;
SELECT '------ This may cause problems with missing data down stream. ' FROM dual;
set heading on
select owner, table_name, ' ', logging from DBA_TABLES
where logging <> 'YES'
and owner not in ('SYS', 'SYSTEM', 'DBSNMP','SYSMAN','OUTLN','MDSYS','ORDSYS','EXFSYS','DMSYS','WMSYS','CTXSYS','ANONYMOUS','XDB','ORDPLUGINS','OLAPSYS','PUBLIC')
UNION
select owner, table_name, partitioning_type, DEF_LOGGING "LOGGING" from DBA_part_tables
where DEF_LOGGING != 'YES' 
and owner not in ('SYS', 'SYSTEM', 'DBSNMP','SYSMAN','OUTLN','MDSYS','ORDSYS','EXFSYS','DMSYS','WMSYS','CTXSYS','ANONYMOUS','XDB','ORDPLUGINS','OLAPSYS','PUBLIC') 
UNION
select table_owner, table_name, PARTITION_NAME, logging from DBA_TAB_PARTITIONS
where logging <> 'YES' 
and table_owner not in ('SYS', 'SYSTEM', 'DBSNMP','SYSMAN','OUTLN','MDSYS','ORDSYS','EXFSYS','DMSYS','WMSYS','CTXSYS','ANONYMOUS','XDB','ORDPLUGINS','OLAPSYS','PUBLIC') 
UNION
select table_owner, table_name, PARTITION_NAME, logging from DBA_TAB_SUBPARTITIONS
where logging <> 'YES' 
and table_owner not in ('SYS', 'SYSTEM', 'DBSNMP','SYSMAN','OUTLN','MDSYS','ORDSYS','EXFSYS','DMSYS','WMSYS','CTXSYS','ANONYMOUS','XDB','ORDPLUGINS','OLAPSYS','PUBLIC') 
;

set heading off
SELECT '------ Tables with Deferred constraints.Deferred constraints may cause TRANDATA to chose an incorrect Key ' FROM dual;
SELECT '------ Any table with a deferred constraint will need more research to avoid any issues' FROM dual;
SELECT '------ Tables with Deferred PK constraints should be added using KEYCOLS in the trandata statement.'FROM dual;
set heading on
SELECT c.TABLE_NAME,
  c.CONSTRAINT_NAME,
  c.CONSTRAINT_TYPE,
  c.DEFERRABLE,
  c.DEFERRED,
  c.VALIDATED,
  c.STATUS,
  i.INDEX_TYPE,
  c.INDEX_NAME,
  c.INDEX_OWNER
FROM dba_constraints c,
  dba_indexes i
WHERE
    i.TABLE_NAME   = c.TABLE_NAME
AND i.OWNER        = c.OWNER
AND  c.DEFERRED = 'DEFERRED'
And i.owner not in ('SYS', 'SYSTEM', 'DBSNMP','SYSMAN','OUTLN','MDSYS','ORDSYS','EXFSYS','DMSYS','WMSYS','CTXSYS','ANONYMOUS','XDB','ORDPLUGINS','OLAPSYS','PUBLIC') 
;

set heading off
SELECT '------ Tables Defined with Rowsize > 2M in all Schemas '
FROM dual;
set heading on
SELECT table_name, sum(data_length) row_length_over_2M
FROM all_tab_columns
WHERE owner not in ('SYS', 'SYSTEM', 'DBSNMP','SYSMAN','OUTLN','MDSYS','ORDSYS','EXFSYS','DMSYS','WMSYS','CTXSYS','ANONYMOUS','XDB','ORDPLUGINS','OLAPSYS','PUBLIC') 
GROUP BY table_name
HAVING sum(data_length) > 2000000
/

set heading off
SELECT '------ Tables With No Primary Key or Unique Index and Column lenght > 1M '
FROM dual;
set heading on
SELECT owner, table_name
  FROM all_tab_columns
 WHERE owner not in ('SYS', 'SYSTEM', 'DBSNMP','SYSMAN','OUTLN','MDSYS','ORDSYS','EXFSYS','DMSYS','WMSYS','CTXSYS','ANONYMOUS','XDB','ORDPLUGINS','OLAPSYS','PUBLIC') 
 group by owner, table_name
 HAVING sum(data_length) > 1000000
MINUS
(SELECT user1.name, obj1.name
  FROM SYS.user$ user1,
       SYS.user$ user2,
       SYS.cdef$ cdef,
       SYS.con$ con1,
       SYS.con$ con2,
       SYS.obj$ obj1,
       SYS.obj$ obj2
 WHERE user1.name not in ('SYS', 'SYSTEM', 'DBSNMP','SYSMAN','OUTLN','MDSYS','ORDSYS','EXFSYS','DMSYS','WMSYS','CTXSYS','ANONYMOUS','XDB','ORDPLUGINS','OLAPSYS','PUBLIC') 
   AND cdef.type# = 2 
   AND con2.owner# = user2.user#(+)
   AND cdef.robj# = obj2.obj#(+)
   AND cdef.rcon# = con2.con#(+)
   AND obj1.owner# = user1.user#
   AND cdef.con# = con1.con#
   AND cdef.obj# = obj1.obj#
UNION
SELECT idx.owner, idx.table_name
  FROM all_indexes idx
 WHERE idx.owner not in ('SYS', 'SYSTEM', 'DBSNMP','SYSMAN','OUTLN','MDSYS','ORDSYS','EXFSYS','DMSYS','WMSYS','CTXSYS','ANONYMOUS','XDB','ORDPLUGINS','OLAPSYS','PUBLIC') 
   AND idx.uniqueness = 'UNIQUE')
/

SET Heading off
SELECT '------ Integrated Replicat does not support Transient Primary Key Updates: ' FROM dual;
SELECT '------ on primary key constraints that have a non-unique index under them. ' 
FROM dual;
SET Heading on
Select 
	i.OWNER,
	i.INDEX_NAME,
	i.TABLE_NAME,
	i.TABLE_OWNER,
	i.UNIQUENESS,
	c.CONSTRAINT_NAME,
	c.CONSTRAINT_TYPE 
from dba_indexes i, dba_constraints c
where i.TABLE_NAME=c.TABLE_NAME 
	and i.OWNER=c.INDEX_OWNER 
  	and i.INDEX_NAME=c.INDEX_NAME 
  	and i.UNIQUENESS='NONUNIQUE' 
  	AND c.CONSTRAINT_TYPE='P'
  	and i.OWNER not in ('SYS', 'SYSTEM', 'DBSNMP','SYSMAN','OUTLN','MDSYS','ORDSYS','EXFSYS','DMSYS','WMSYS','CTXSYS','ANONYMOUS','XDB','ORDPLUGINS','OLAPSYS','PUBLIC') ;


set heading off
SELECT '------ Tables With CLOB, BLOB, LONG, NCLOB or LONG RAW Columns in ALL Schemas ' 
FROM dual;
set heading on
SELECT OWNER, TABLE_NAME, COLUMN_NAME, DATA_TYPE
FROM all_tab_columns
WHERE OWNER not in ('SYS', 'SYSTEM', 'DBSNMP','SYSMAN','OUTLN','MDSYS','ORDSYS','EXFSYS','DMSYS','WMSYS','CTXSYS','ANONYMOUS','XDB','ORDPLUGINS','OLAPSYS','PUBLIC') 
AND data_type in ('CLOB', 'BLOB', 'LONG', 'LONG RAW', 'NCLOB')
/

set heading off
SELECT '------ Tables With Columns of UNSUPPORTED Datatypes in ALL Schemas ' 
FROM dual;
set heading on
SELECT OWNER, TABLE_NAME, COLUMN_NAME, DATA_TYPE
FROM all_tab_columns
WHERE OWNER not in ('SYS', 'SYSTEM', 'DBSNMP','SYSMAN','OUTLN','MDSYS','ORDSYS','EXFSYS','DMSYS','WMSYS','CTXSYS','ANONYMOUS','XDB','ORDPLUGINS','OLAPSYS','PUBLIC') 
AND (data_type in ('ORDDICOM', 'BFILE', 'TIMEZONE_REGION', 'BINARY_INTEGER', 'PLS_INTEGER', 'UROWID', 'URITYPE', 'MLSLABEL', 'TIMEZONE_ABBR', 'ANYDATA', 'ANYDATASET', 'ANYTYPE')
or data_type like 'INTERVAL%')
/

set heading off
SELECT '------ Cluster, or Object Tables - ALL UNSUPPORTED - in ALL Schemas '
FROM dual;
set heading on
SELECT OWNER, TABLE_NAME, CLUSTER_NAME, TABLE_TYPE 
FROM all_all_tables
WHERE OWNER not in ('SYS', 'SYSTEM', 'DBSNMP','SYSMAN','OUTLN','MDSYS','ORDSYS','EXFSYS','DMSYS','WMSYS','CTXSYS','ANONYMOUS','XDB','ORDPLUGINS','OLAPSYS','PUBLIC') 
AND (cluster_name is NOT NULL or TABLE_TYPE is NOT NULL)
/

set heading off 
Select '------ All tables that have compression enabled (need IE for support): '
from dual;
set heading on
select owner, table_name
from DBA_TABLES
where COMPRESSION = 'ENABLED'
/

SELECT TABLE_OWNER, TABLE_NAME, COMPRESSION
FROM ALL_TAB_PARTITIONS
WHERE (COMPRESSION = 'ENABLED')
/
set heading off
SELECT '------ IOT (Fully support for Oracle 10GR2 (with or without overflows) using GGS 10.4 and higher) - in All Schemas: ' 
FROM dual;
set heading on
SELECT OWNER, TABLE_NAME, IOT_TYPE, TABLE_TYPE 
FROM all_all_tables
WHERE OWNER not in ('SYS', 'SYSTEM', 'DBSNMP','SYSMAN','OUTLN','MDSYS','ORDSYS','EXFSYS','DMSYS','WMSYS','CTXSYS','ANONYMOUS','XDB','ORDPLUGINS','OLAPSYS','PUBLIC') 
AND (IOT_TYPE is not null or TABLE_TYPE is NOT NULL)
/
set heading off
SELECT '------ Tables with Domain or Context Indexes' 
FROM dual;
set heading on
SELECT OWNER, TABLE_NAME, index_name, index_type 
FROM dba_indexes 
WHERE OWNER not in ('SYS', 'SYSTEM', 'DBSNMP','SYSMAN','OUTLN','MDSYS','ORDSYS','EXFSYS','DMSYS','WMSYS','CTXSYS','ANONYMOUS','XDB','ORDPLUGINS','OLAPSYS','PUBLIC') 
and index_type = 'DOMAIN'
/

set heading off
SELECT '------ Types of Constraints on the Tables in ALL Schemas '
FROM dual;
set heading on
SELECT DECODE(constraint_type,'P','PRIMARY KEY','U','UNIQUE', 'C', 'CHECK', 'R', 
'REFERENTIAL') constraint_type_desc, count(*) total
FROM all_constraints
WHERE OWNER not in ('SYS', 'SYSTEM', 'DBSNMP','SYSMAN','OUTLN','MDSYS','ORDSYS','EXFSYS','DMSYS','WMSYS','CTXSYS','ANONYMOUS','XDB','ORDPLUGINS','OLAPSYS','PUBLIC')  
GROUP BY constraint_type
/
set heading off
SELECT '------ Cascading Deletes on the Tables in ALL Schemas ' 
FROM dual;
set heading on
SELECT owner, table_name, constraint_name
FROM all_constraints
WHERE OWNER not in ('SYS', 'SYSTEM', 'DBSNMP','SYSMAN','OUTLN','MDSYS','ORDSYS','EXFSYS','DMSYS','WMSYS','CTXSYS','ANONYMOUS','XDB','ORDPLUGINS','OLAPSYS','PUBLIC')  
	and constraint_type = 'R' and delete_rule = 'CASCADE'
/

set heading off
SELECT '------ Tables Defined with Triggers in ALL Schema: '
FROM dual;
set heading on
SELECT table_name, COUNT(*) trigger_count
FROM all_triggers
WHERE OWNER not in ('SYS', 'SYSTEM', 'DBSNMP','SYSMAN','OUTLN','MDSYS','ORDSYS','EXFSYS','DMSYS','WMSYS','CTXSYS','ANONYMOUS','XDB','ORDPLUGINS','OLAPSYS','PUBLIC')  
GROUP BY table_name
/
set heading off
SELECT '------ Performance issues - Reverse Key Indexes Defined in ALL Schema: '
FROM dual;

col TABLE_OWNER format a10
col INDEX_TYPE format a12
SET Heading on

select 
	OWNER,      
	INDEX_NAME,
	INDEX_TYPE, 
	TABLE_OWNER,
	TABLE_NAME, 
	TABLE_TYPE, 
	UNIQUENESS,
	CLUSTERING_FACTOR,
	NUM_ROWS,
	LAST_ANALYZED,
	BUFFER_POOL
from dba_indexes
where index_type = 'NORMAL/REV'
      And OWNER not in ('SYS', 'SYSTEM', 'DBSNMP','SYSMAN','OUTLN','MDSYS','ORDSYS','EXFSYS','DMSYS','WMSYS','CTXSYS','ANONYMOUS','XDB','ORDPLUGINS','OLAPSYS','PUBLIC')  
/

SET Heading off
PROMPT 'For Integrated Extract please see MOS doc -1448324.1 '
SELECT '------ Integrated Extract unsupported objects '
FROM dual;
Set heading on 
column object_name format a35
select owner, object_name, support_mode from DBA_GOLDENGATE_SUPPORT_MODE  WHERE support_mode = 'NONE';

SET Heading off
PROMPT 'For Integrated Extract please see MOS doc -1448324.1 '
PROMPT 'A capture process can capture changes made to the key columns and any other columns'
PROMPT 'in the table supported by the capture process, except for LOB, LONG, LONG RAW, and XMLType columns.'
SELECT '------ Integrated Extract - Key Columns only '
FROM dual;
Set heading on 
column object_name format a35
select owner, object_name, support_mode from DBA_GOLDENGATE_SUPPORT_MODE where support_mode not in ('FULL','NONE'); 


SET Heading off
SELECT '------ Sequence numbers - Sequences could be a issue for HA configurations '
FROM dual;

COLUMN SEQUENCE_OWNER FORMAT a15
COLUMN SEQUENCE_NAME FORMAT a30
COLUMN INCR FORMAT 999
COLUMN CYCLE FORMAT A5
COLUMN ORDER FORMAT A5
SET Heading on
SELECT SEQUENCE_OWNER,
 	 SEQUENCE_NAME,
 	 MIN_VALUE,
 	 MAX_VALUE,
 	 INCREMENT_BY INCR,
 	 CYCLE_FLAG CYCLE,
 	 ORDER_FLAG "ORDER",
 	 CACHE_SIZE,
 	 LAST_NUMBER
  FROM DBA_SEQUENCES
 WHERE SEQUENCE_OWNER not in ('SYS', 'SYSTEM', 'DBSNMP','SYSMAN','OUTLN','MDSYS','ORDSYS','EXFSYS','DMSYS','WMSYS','CTXSYS','ANONYMOUS','XDB','ORDPLUGINS','OLAPSYS','PUBLIC')  
 /
set linesize 132

col "Avg Log Size" format 999,999,999
select sum (BLOCKS) * max(BLOCK_SIZE)/ count(*)"Avg Log Size" From gV$ARCHIVED_LOG;

Prompt Table: Frequency of Log Switches by hour and day
SELECT SUBSTR(TO_CHAR(FIRST_TIME, 'MM-DD-YY HH24:MI:SS'),1,5) DAY, 
   	 TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(FIRST_TIME, 'MM-DD-YY HH24:MI:SS'),10,2),'00',1,0)),'99') "00", 
	 TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(FIRST_TIME, 'MM-DD-YY HH24:MI:SS'),10,2),'01',1,0)),'99') "01", 
 	 TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(FIRST_TIME, 'MM-DD-YY HH24:MI:SS'),10,2),'02',1,0)),'99') "02", 
   	 TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(FIRST_TIME, 'MM-DD-YY HH24:MI:SS'),10,2),'03',1,0)),'99') "03", 
   	 TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(FIRST_TIME, 'MM-DD-YY HH24:MI:SS'),10,2),'04',1,0)),'99') "04", 
   	 TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(FIRST_TIME, 'MM-DD-YY HH24:MI:SS'),10,2),'05',1,0)),'99') "05", 
   	 TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(FIRST_TIME, 'MM-DD-YY HH24:MI:SS'),10,2),'06',1,0)),'99') "06", 
  	 TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(FIRST_TIME, 'MM-DD-YY HH24:MI:SS'),10,2),'07',1,0)),'99') "07", 
	 TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(FIRST_TIME, 'MM-DD-YY HH24:MI:SS'),10,2),'08',1,0)),'99') "08", 
   	 TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(FIRST_TIME, 'MM-DD-YY HH24:MI:SS'),10,2),'09',1,0)),'99') "09", 
   	 TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(FIRST_TIME, 'MM-DD-YY HH24:MI:SS'),10,2),'10',1,0)),'99') "10", 
   	 TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(FIRST_TIME, 'MM-DD-YY HH24:MI:SS'),10,2),'11',1,0)),'99') "11", 
   	 TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(FIRST_TIME, 'MM-DD-YY HH24:MI:SS'),10,2),'12',1,0)),'99') "12", 
  	 TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(FIRST_TIME, 'MM-DD-YY HH24:MI:SS'),10,2),'13',1,0)),'99') "13", 
   	 TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(FIRST_TIME, 'MM-DD-YY HH24:MI:SS'),10,2),'14',1,0)),'99') "14", 
   	 TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(FIRST_TIME, 'MM-DD-YY HH24:MI:SS'),10,2),'15',1,0)),'99') "15", 
   	 TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(FIRST_TIME, 'MM-DD-YY HH24:MI:SS'),10,2),'16',1,0)),'99') "16", 
   	 TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(FIRST_TIME, 'MM-DD-YY HH24:MI:SS'),10,2),'17',1,0)),'99') "17", 
   	 TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(FIRST_TIME, 'MM-DD-YY HH24:MI:SS'),10,2),'18',1,0)),'99') "18", 
   	 TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(FIRST_TIME, 'MM-DD-YY HH24:MI:SS'),10,2),'19',1,0)),'99') "19", 
   	 TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(FIRST_TIME, 'MM-DD-YY HH24:MI:SS'),10,2),'20',1,0)),'99') "20", 
   	 TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(FIRST_TIME, 'MM-DD-YY HH24:MI:SS'),10,2),'21',1,0)),'99') "21", 
   	 TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(FIRST_TIME, 'MM-DD-YY HH24:MI:SS'),10,2),'22',1,0)),'99') "22", 
   	 TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(FIRST_TIME, 'MM-DD-YY HH24:MI:SS'),10,2),'23',1,0)),'99') "23" 
FROM 	 V$LOG_HISTORY 
GROUP  BY SUBSTR(TO_CHAR(FIRST_TIME, 'MM-DD-YY HH24:MI:SS'),1,5) 
order by 1;
set heading off
SELECT '------ Summary of log volume processed by day for last 7 days: '
FROM dual;
set heading on
select to_char(first_time, 'mm/dd') ArchiveDate,
       sum(BLOCKS*BLOCK_SIZE/1024/1024) LOGMB
from v$archived_log
where first_time > sysdate - 7
group by to_char(first_time, 'mm/dd')
order by to_char(first_time, 'mm/dd');
/
set heading off
SELECT '------ Summary of log volume processed per hour for last 7 days: ' 
FROM dual;
set heading on
select to_char(first_time, 'MM-DD-YYYY') ArchiveDate, 
       to_char(first_time, 'HH24') ArchiveHour,
       sum(BLOCKS*BLOCK_SIZE/1024/1024) LogMB
from v$archived_log
where first_time > sysdate - 7
group by to_char(first_time, 'MM-DD-YYYY'), to_char(first_time, 'HH24')
order by to_char(first_time, 'MM-DD-YYYY'), to_char(first_time, 'HH24');
/     

set heading off
select '* This output may be found in file: AllSchemsCheckOracle.out' from dual
/

spool off
undefine b0
-- exit

