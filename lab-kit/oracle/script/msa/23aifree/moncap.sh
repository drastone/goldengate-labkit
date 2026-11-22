while true
do
cap_log=`sqlplus -s c##ogg/ogg@free << aa
set head off;
set feedback off;
set timing off;
set define off;

SELECT to_char(systimestamp, '''YYYYMMDD HH24/MI/SS''') systimestamp, --TO_CHAR(SYSTIMESTAMP, 'SSSSS.FF'),
	capture_name , LTRIM(c.EXTRACT_NAME)  EXTRACT_NAME, --c.STATE, 
        TO_CHAR(c.TOTAL_MESSAGES_CAPTURED) TOTAL_MESSAGES_CAPTURED, 
	TO_CHAR(c.SGA_USED /1024/ 1024,'99999D9' ) SGA_USED ,TO_CHAR(c.SGA_ALLOCATED /1024/1024,'99999D9' ) SGA_ALLOCATED, 
	TO_CHAR(c.LAST_SENT_MESSAGE_NUMBER) LAST_SENT_MESSAGE_NUMBER, c.STATE
FROM V\\$GOLDENGATE_CAPTURE c, V\\$SESSION s 
WHERE c.SID=s.SID AND c.SERIAL#=s.SERIAL# 
;

aa`

vs_systimestamp=`echo $cap_log | awk '{print $1 " " $2 }'`
vs_capture_name=`echo $cap_log | awk '{print $3 }'`
vs_extract_name=`echo $cap_log | awk '{print $4 }'`
vs_total_message_captured=`echo $cap_log | awk '{print $5 }'`
vs_sga_used=`echo $cap_log | awk '{print $6 }'`
vs_sga_allocated=`echo $cap_log | awk '{print $7 }'`
vs_last_sent_message_number=`echo $cap_log | awk '{print $8 }'`
vs_state=`echo $cap_log | awk '{print $9 " " $10 " " $11 " " $12 " " $13 " " $14 }'`

sqlplus -s ggadmin/WElcome1234##@freepdb1 << EOF
set define off;


declare
	vs_cnt number;
begin

	select count(*) into vs_cnt 
	from ggadmin.moncap
	where capture_name = 'DUMMY_BASE_TIMESTAMP'
	;

	IF (vs_cnt = 0) THEN
		INSERT into ggadmin.moncap (call_time, capture_name)
		VALUES (to_date($vs_systimestamp,'YYYYMMDD HH24/MI/SS'), 'DUMMY_BASE_TIMESTAMP');
	END IF;

	insert into ggadmin.moncap values (to_date($vs_systimestamp,'YYYYMMDD HH24/MI/SS'), '$vs_capture_name', '$vs_extract_name', '$vs_state', $vs_total_message_captured, $vs_sga_used, $vs_sga_allocated, $vs_last_sent_message_number
);
	commit;

	insert into ggadmin.monevnt 
	select sysdate,a.inst_id "INST",
		   a.sid, a.serial#,
		   (select p.spid from gv\$process p where (a.inst_id = p.inst_id) and (a.paddr = p.addr)) spid, a.status, a.event,
		   a.process as CLI_SPID,
		   decode(a.event,'enqueue',
				  decode(chr(bitand(a.p1,-16777216)/16777215)||chr(bitand(a.p1, 16711680)/65535),'TX',
				  chr(bitand(a.p1,-16777216)/16777215)||chr(bitand(a.p1, 16711680)/65535)||to_char( bitand(a.p1, 65535) )||','||
				  'usn.slot:'||bitand(a.p2, 4294901760)/65536||'.'||bitand(a.p2, 65535)||','||'wrap:'||a.p3,
				  a.p1||','||a.p2||','||a.p3),a.p1||','||a.p2||','||a.p3) P,
		   a.seconds_in_wait W,
		   substr(a.program,1,18) program,
		   decode(a.command,3,'S',2,'I',6,'U',7,'D',command) C,
		   a.sql_id,
		   substr((SELECT OBJECT_NAME FROM DBA_OBJECTS C WHERE C.OBJECT_ID = ROW_WAIT_OBJ# ),1,20) object_name,
		   a.blocking_session blksid, -- comment out for 10.2.0.2
		   substr((SELECT NAME FROM V\$LATCH WHERE LATCH# = p2 and event = 'latch free' ),1,10) LATCH_NAME,
		   a.wait_class
	from gv\$session a
	where a.event not like 'SQL*Net message from client%'
	   and a.event not like 'rdbms ipc%'
	   and a.event not like 'smon timer'
	   and a.event not like 'pmon timer'
	   and a.event not like '%slave wait%'
	   and a.event not like 'lock manager wait for remote message'
	   and a.event not like 'PX Deq%'
	   and a.event not like 'null event'
	   and a.event not like 'gcs remote message'
	   and a.event not like 'ges remote message'
	   and a.event not like 'wakeup time manager'
	   and a.event not like 'Queue Monitor%Wait'
	   and a.event not like 'DIAG idle wait'
	   and a.event not like 'Streams AQ:%'
	   and a.sid <> (select sid from v\$mystat where rownum = 1)
	   and a.wait_class <> 'Idle'
	order by a.inst_id, a.event, a.sid
	;
	commit;

end;
/
EOF
sleep 60
done
