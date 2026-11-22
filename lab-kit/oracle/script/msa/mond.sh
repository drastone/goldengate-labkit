while true
do
sqlplus -s c##ogg/ogg@orclpdb1 << EOF

alter session set nls_date_format='YY/MM/DD HH24:MI:SS';

declare
	v_curr_time date;
begin 

/*
	select to_char(sysdate,'YY/MM/DD HH24:MI:SS') into v_curr_time from dual;

	update soe.monres 
	set val1 = v_curr_time
	where keya = 'replicat' and keyb = 'BASE_TIMESTAMP'
	;

	IF (SQL%rowcount = 0) THEN
		INSERT into soe.monres (keya, keyb, val1)
		VALUES ('replicat', 'BASE_TIMESTAMP', to_char(sysdate,'YY/MM/DD HH24:MI:SS'));
	END IF;
*/

        select to_char(sysdate,'YY/MM/DD HH24:MI:SS') into v_curr_time from dual;

        update soe.monres 
        set call_time = v_curr_time
        where keya = 'replicat' and keyb = 'BASE_TIMESTAMP'
        ;

        IF (SQL%rowcount = 0) THEN
                INSERT into soe.monres (call_time, keya, keyb)
                VALUES (v_curr_time, 'replicat', 'BASE_TIMESTAMP');
        END IF;

	insert into soe.monres (call_time, keya, keyb, keyc, val1) 
	select v_curr_time, 'replicat','Lag',r.apply_name, 86400 * (r.dequeue_time - c.lwm_message_create_time) latency_in_seconds
	from gv\$gg_apply_reader r, gv\$gg_apply_coordinator c
	where r.apply# = c.apply#
	and r.apply_name = c.apply_name;


	insert into soe.monres (call_time, keya, keyb, keyc, keyd, val1, val2, val3, val4, val5, val6, val7)
	select  
			v_curr_time,	
			source_database_name, 
			'Apply Receiver',
			case when s.module = 'GoldenGate' then action else module end prog,
			apply_name, 
			s.username||'('||r.sid||','||r.serial#||'@'||r.inst_id||')' username,
			r.state, event,
			to_char(startup_time, 'YY/MM/DD HH24:MI:SS') startup_time,
			acknowledgement||':'||last_received_msg||':'||total_messages_received||':'||total_available_messages messages,
			last_received_msg_position||':'||acknowledgement_position||':'||current_position position,
			total_transactions_received||':'||total_commits||':'||total_errors Inform
	from gv\$gg_apply_receiver r, gv\$session s
	where r.inst_id = s.inst_id
	and r.sid = s.sid
	;

	insert into soe.monres (call_time, keya, keyb, keyc, keyd, keye, val1, val2, val3, val4, val5, val6, val7, val8, val9)
	select  
			v_curr_time,
			'replicat'      ,
			'Apply Reader',
			case when s.module = 'GoldenGate' then action else module end prog,
			apply_name||'('||apply#||')' apply_name, 
			p.pname pname,
			s.username||'('||r.sid||','||r.serial#||'@'||r.inst_id||')' username,
			r.state, event,
			total_messages_dequeued||':'||total_messages_spilled messages, 
			-- DEQUEUE_TIME, DEQUEUED_MESSAGE_CREATE_TIME, 
			round(100*elapsed_dequeue_time/(elapsed_dequeue_time+elapsed_schedule_time+elapsed_spill_time+1))||':'||
			round(100*ELApsed_schedule_time/(elapsed_dequeue_time+elapsed_schedule_time+elapsed_spill_time+1))||':'||
			round(100*elapsed_spill_time/(elapsed_dequeue_time+elapsed_schedule_time+elapsed_spill_time+1)) eLA_TIME,
			-- (select regexp_substr(program,'[^@]+')||'('||sid||','||serial#||')' from v\$session where proxy_sid = sid and proxy_serial= serial#) pname,
			bytes_received, 
			total_in_memory_lcrs||':'||total_lcrs_with_dep||':'||total_lcrs_with_wmdep lcrs,
			round(sga_allocated/1024/1024/1024,1)||'G : '||round(sga_used/1024/1024/1024,1)||'G' SGA_USAGE,
			OLDEST_TRANSACTION_ID
	from  GV\$GG_APPLY_READER r, GV\$SESSION s, GV\$PROCESS p
	where r.inst_id = s.inst_id
	and r.sid = s.sid
	and  s.inst_id = p.inst_id
	and  s.paddr = p.addr
	;

	insert into soe.monres (call_time, keya, keyb, keyc, keyd, keye, val1, val2, val3, val4, val5, val6, val7, val8, val9)
	select  
			v_curr_time,
			'replicat' ,
			'Apply Coordinator',
			case when s.module = 'GoldenGate' then action else module end prog,
			apply_name||'('||apply#||')' apply_name,  
			p.pname pname,
			s.username||'('||c.sid||','||c.serial#||'@'||c.inst_id||')' username,
			startup_time,
			c.state, event,
			processed_message_number tot_mesg,
			total_received||':'||total_assigned||':'||total_applied||':'||unassigned_complete_txns trans1,
			total_wait_deps||':'||total_wait_commits||':'||total_rollbacks||':'||total_errors trans2,
			-- total_admin, 
			elapsed_schedule_time*100||';'||elapsed_idle_time*100 ela_tim, 
			active_server_count
	from GV\$GG_APPLY_COORDINATOR C,  GV\$SESSION s, GV\$PROCESS p
	where c.inst_id = s.inst_id
	and c.sid = s.sid
	and  s.inst_id = p.inst_id
	and  s.paddr = p.addr
	;

	insert into soe.monres (call_time, keya, keyb, keyc, keyd, keye, val1, val2, val3, val4, val5, val6, val7, val8, val9, val10)
	select  
			v_curr_time,
			'replicat', 
			'Apply Server',
			case when s.module = 'GoldenGate' then action else module end prog,
			apply_name||'('||apply#||')' apply_name, 
			p.pname pname, 
			s.username||'('||a.sid||','||a.serial#||'@'||a.inst_id||')' username,
			server_id,
			a.state, event,
			TOTAL_MESSAGES_APPLIED||':'||TOTAL_ASSIGNED||':'||TOTAL_ROLLBACKS trans1,
			APPLY_TIME,
			ELAPSED_APPLY_TIME*100 ELA_TIME,
			TOTAL_LCRS_RETRIED||':'||TOTAL_TXNS_RETRIED retry,
			LCR_RETRY_ITERATION||':'||TXN_RETRY_ITERATION iter,
			TOTAL_TXNS_RECORDED errorq
				from GV\$GG_APPLY_SERVER a,  GV\$SESSION s, GV\$PROCESS p
					where a.inst_id = s.inst_id
						and a.sid = s.sid
							and  s.inst_id = p.inst_id
								and  s.paddr = p.addr
	order by  prog, p.pname 
	;	


	insert into soe.monres (call_time, keya, keyb, keyc, keyd, keye, val1, val2, val3, val4, val5, val6, val7, val8, val9)
	select  
			v_curr_time,
			'replicat',
			'Replicat Stats',
			SOURCE_TABLE_OWNER||'.'||SOURCE_TABLE_NAME              SOURCE_TABLE, 
			DESTINATION_TABLE_OWNER||'.'||DESTINATION_TABLE_NAME    DEST_TABLE, 
			APPLY_NAME||'('||SERVER_ID||'@'||CON_ID||')' APP_NAME,
			to_char(LAST_UPDATE,'YY/MM/DD HH24:MI:SS') LAST_UPDATE , WAIT_DEPENDENCIES,
			TOTAL_INSERTS||':'||TOTAL_UPDATES||':'||TOTAL_DELETES   DML_STATS, 
			INSERT_COLLISIONS||':'||UPDATE_COLLISIONS||':'||DELETE_COLLISIONS COLLISION_STATS, 
			REPERROR_RECORDS||':'||REPERROR_IGNORES                 REPERROR_STATS, 
			CDR_INSERT_ROW_EXISTS||':'||CDR_UPDATE_ROW_EXISTS||':'||CDR_DELETE_ROW_EXISTS CDR_EXISTS,
			CDR_UPDATE_ROW_MISSING||':'||CDR_DELETE_ROW_MISSING     CDR_MISSING,
			CDR_SUCCESSFUL_RESOLUTIONS||':'||CDR_FAILED_RESOLUTIONS CDR_STATS, 
			LOB_OPERATIONS
	from GV\$GOLDENGATE_TABLE_STATS
	where source_table_name <> 'GG_HEARTBEAT_SEED'
	--order by LAST_UPDATE
	order by APPLY_NAME
	;


	insert into soe.monres (call_time, keya, keyb, keyc, val1, val2, val3)
	select 
			v_curr_time,'replicat',inst_id, name, count, last_used, con_id
	from GV\$GOLDENGATE_CAPABILITIES
	order by NAME
	;

	commit;


end;
/
EOF
sleep 5
done

