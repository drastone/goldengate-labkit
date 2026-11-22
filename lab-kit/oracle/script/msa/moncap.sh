while true
do
cap_log=`sqlplus -s c##ogg/ogg@west << aa
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

sqlplus -s soe/soe@orclpdb1 << EOF
set define off;


declare
	vs_cnt number;
begin

	select count(*) into vs_cnt 
	from soe.moncap
	where capture_name = 'DUMMY_BASE_TIMESTAMP'
	;

	IF (vs_cnt = 0) THEN
		INSERT into soe.moncap (call_time, capture_name)
		VALUES (to_date($vs_systimestamp,'YYYYMMDD HH24/MI/SS'), 'DUMMY_BASE_TIMESTAMP');
	END IF;

	insert into soe.moncap values (to_date($vs_systimestamp,'YYYYMMDD HH24/MI/SS'), '$vs_capture_name', '$vs_extract_name', '$vs_state', $vs_total_message_captured, $vs_sga_used, $vs_sga_allocated, $vs_last_sent_message_number
);
	commit;
end;
/
EOF
sleep 60
done