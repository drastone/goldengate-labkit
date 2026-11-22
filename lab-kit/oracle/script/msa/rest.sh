while true
do
sqlplus -s c##ogg/ogg@orclpdb1 << EOF


set serveroutput on;
alter session set nls_date_format='YY/MM/DD HH24:MI:SS';
DECLARE
    l_resp_body CLOB;
    l_proc_cnt number;
    l_proc_name varchar2(200);
    l_status varchar2(20);
    l_lag number;
    l_sincelagreported number;
    l_in_prefix varchar2(20);
    l_in_seq number;
    l_in_rba number;
    l_out_prefix varchar2(20);
    l_out_seq number;
    l_out_rba number;    
    l_cachesize number;
    l_maxvmused number;
    l_vmcurrentvmused number;
    l_currentmmapanon number;
    l_currentmmaprecycles number;
    l_bytestodisk number;
    l_brtotstatsize number;
    l_brtotdatasize number;

    type proc_array is varray(20) of varchar2(20);
    process_names proc_array;
    vs_base_url varchar2(100);
    vs_base_pms_url varchar2(100);
    vs_url varchar2(100);
    global_seq number;
    v_curr_time date;

    l_response_message clob;

    v_call_time date;
    --v_message varchar2(4000);
    --v_message_left varchar2(4000);
    v_message clob;
    v_message_left clob;  
    v_cnt number;
BEGIN

    select soe.oggseq.nextval into global_seq
    from dual; 

    select to_char(sysdate,'YY/MM/DD HH24:MI:SS') into v_curr_time from dual;

    update soe.restmon 
    set call_time = v_curr_time
    where process_name = 'DUMMY_BASE_TIMESTAMP'
    ;

    IF (SQL%rowcount = 0) THEN
        INSERT into soe.restmon (id,call_time,process_name)
        VALUES (0, v_curr_time, 'DUMMY_BASE_TIMESTAMP');
    END IF;
    
    select gubun1 || ':' ||gubun2 ||gubun3||'/' into vs_base_url
    from soe.ogg_conf
    where keya = 'EXTRACTURL' 
    and keyb = 'ADMIN'
    ;

    select gubun1 || ':' ||gubun2 ||gubun3||'/' into vs_base_pms_url
    from soe.ogg_conf
    where keya = 'EXTRACTURL' 
    and keyb = 'PMS'
    ;
    
    select count(gubun1) into l_proc_cnt
    from soe.ogg_conf
    where keya = 'EXTRACT' ;
    
    for i in 1..l_proc_cnt loop
    
        
        select gubun1, vs_base_url || gubun1 into l_proc_name, vs_url
        --select vs_base_url || gubun1 into vs_url
        from soe.ogg_conf
        where keya = 'EXTRACT' 
        and keyb = i
        ;
    
        l_resp_body := apex_web_service.make_rest_request(
            p_url         => vs_base_url || '/extracts/'||l_proc_name ,
            p_http_method => 'GET',
            p_username  => 'admin',
            p_password => 'admin'
        );
    
        l_out_prefix := json_value(l_resp_body,'$.response.targets.name');
        l_out_seq := json_value(l_resp_body,'$.response.targets.sequence');
        l_out_rba := json_value(l_resp_body,'$.response.targets.offset');
        
        
        l_resp_body := apex_web_service.make_rest_request(
            p_url         => vs_base_url || '/extracts/'||l_proc_name || '/info/status',
            p_http_method => 'GET',
            p_username  => 'admin',
            p_password => 'admin'
        );
    
        --l_proc_name := json_value(l_resp_body,'$.response.config');        
        l_status := json_value(l_resp_body,'$.response.status');
        l_lag := json_value(l_resp_body,'$.response.lag');            
        l_sincelagreported := json_value(l_resp_body,'$.response.sinceLagReported');      


        l_resp_body := apex_web_service.make_rest_request(
            p_url         => vs_base_pms_url || '/mpoints/'||l_proc_name || '/cacheStatistics',
            p_http_method => 'GET',
            p_username  => 'admin',
            p_password => 'admin'
        );
    
        --l_proc_name := json_value(l_resp_body,'$.response.config');        
        l_bytestodisk := json_value(l_resp_body,'$.response.totalFileCacheBytesToDisk');
 
 
        l_resp_body := apex_web_service.make_rest_request(
            p_url         => vs_base_pms_url || '/mpoints/'||l_proc_name || '/superpoolStatistics',
            p_http_method => 'GET',
            p_username  => 'admin',
            p_password => 'admin'
        );
    
        --l_proc_name := json_value(l_resp_body,'$.response.config');        
        l_cachesize := json_value(l_resp_body,'$.response.softPageoutSize');
        l_maxvmused := json_value(l_resp_body,'$.response.maxVmUsed');
        l_vmcurrentvmused := json_value(l_resp_body,'$.response.currentVmUsed');
        l_currentmmapanon := json_value(l_resp_body,'$.response.currentMmapAnon');
        l_currentmmaprecycles := json_value(l_resp_body,'$.response.currentMmapRecycles');
 
        l_resp_body := apex_web_service.make_rest_request(
            p_url         => vs_base_pms_url || '/mpoints/'||l_proc_name || '/brStatus',
            p_http_method => 'GET',
            p_username  => 'admin',
            p_password => 'admin'
        );

        --l_proc_name := json_value(l_resp_body,'$.response.config');        
        l_brtotstatsize := json_value(l_resp_body,'$.response.totalStateSize');
        l_brtotdatasize := json_value(l_resp_body,'$.response.totalDataSize');	

        
        insert into soe.RESPONSE (REST_URL, HTTP_METHOD, STATUS_CODE, REQUEST_BODY, RESPONSE_BODY)
        values (vs_base_url || '/extracts/'||l_proc_name, 'GET', apex_web_service.g_status_code, '', l_resp_body)
        --RETURNING INVK_ID INTO l_response_id
        ;
        commit;

        
        insert into soe.restmon (call_time,id,process_name,status,out_prefix,out_seq,out_rba,lag,sincelagreported,cachesize, maxvmused,currentvmused,currentmmapanon,currentmmaprecycles,bytestodisk,brTotStateSize,brTotDataSize) 
        values (v_curr_time,global_seq,l_proc_name,l_status,l_out_prefix,l_out_seq,l_out_rba,l_lag,l_sincelagreported,l_cachesize,l_maxvmused,l_vmcurrentvmused,l_currentmmapanon,l_currentmmaprecycles,l_bytestodisk,l_brtotstatsize,l_brtotdatasize);
        commit;
        
        --open rc for SELECT r.RESPONSE_BODY.totalResults FROM REST_RESPONSE r where invk_id = l_response_id;
        --dbms_sql.return_result(rc);
    end loop;
    

---
--- 

    select  gubun1 || ':' ||gubun2 ||gubun3||'/' into vs_base_url
    from soe.ogg_conf
    where keya = 'DISTPATHURL' ;
    
    select count(gubun1) into l_proc_cnt
    from soe.ogg_conf
    where keya = 'DISTPATH' ;
    

    for i in 1..l_proc_cnt loop
    
        
        select gubun1, vs_base_url || gubun1 into l_proc_name, vs_url
        --select vs_base_url || gubun1 into vs_url
        from soe.ogg_conf
        where keya = 'DISTPATH' 
        and keyb = i
        ;
    
        l_resp_body := apex_web_service.make_rest_request(
            p_url         => vs_base_url || '/sources/'||l_proc_name ,
            p_http_method => 'GET',
            p_username  => 'admin',
            p_password => 'admin'
        );
    
    
        l_status := json_value(l_resp_body,'$.response.status');
        l_proc_name := json_value(l_resp_body,'$.response.name');        
        
        
        l_resp_body := apex_web_service.make_rest_request(
            p_url         => vs_base_url || '/sources/'||l_proc_name || '/checkpoints',
            p_http_method => 'GET',
            p_username  => 'admin',
            p_password => 'admin'
        );
    
   
        l_in_prefix := json_value(l_resp_body,'$.response.current.input.current.name');
        l_in_seq := json_value(l_resp_body,'$.response.current.input.current.sequence');
        l_in_rba := json_value(l_resp_body,'$.response.current.input.current.offset');
        l_out_prefix := json_value(l_resp_body,'$.response.current.output.current.name');
        l_out_seq := json_value(l_resp_body,'$.response.current.output.current.sequence');
        l_out_rba := json_value(l_resp_body,'$.response.current.output.current.offset');
        
        
        l_resp_body := apex_web_service.make_rest_request(
            p_url         => vs_base_url || '/sources/'||l_proc_name || '/info',
            p_http_method => 'GET',
            p_username  => 'admin',
            p_password => 'admin'
        );
        
        l_lag := json_value(l_resp_body,'$.response.lag');     
        l_sincelagreported := json_value(l_resp_body,'$.response.sinceLagReported');         
        
        
        insert into soe.RESPONSE (REST_URL, HTTP_METHOD, STATUS_CODE, REQUEST_BODY, RESPONSE_BODY)
        values (vs_base_url || '/sources/'||l_proc_name, 'GET', apex_web_service.g_status_code, '', l_resp_body)
        --RETURNING INVK_ID INTO l_response_id
        ;
        commit;
        
        insert into soe.restmon (call_time,id,process_name,status,in_prefix,in_seq,in_rba,out_prefix,out_seq,out_rba,lag,sincelagreported) 
        values (v_curr_time,global_seq,l_proc_name,l_status,l_in_prefix,l_in_seq,l_in_rba,l_out_prefix,l_out_seq,l_out_rba,l_lag,l_sincelagreported);
        commit;
        
        --open rc for SELECT r.RESPONSE_BODY.totalResults FROM REST_RESPONSE r where invk_id = l_response_id;
        --dbms_sql.return_result(rc);
    end loop;
    

    select gubun1 || ':' ||gubun2 ||gubun3||'/'  into vs_base_url
    from soe.ogg_conf
    where keya = 'REPLICATURL' 
    and keyb = 'ADMIN'
    ;
    
    select count(gubun1) into l_proc_cnt
    from soe.ogg_conf
    where keya = 'REPLICAT' ;
    

    for i in 1..l_proc_cnt loop
    
        

        select gubun1, vs_base_url || gubun1 into l_proc_name, vs_url
        --select vs_base_url || gubun1 into vs_url
        from soe.ogg_conf
        where keya = 'REPLICAT' 
        and keyb = i
        ;
    
        l_resp_body := apex_web_service.make_rest_request(
            p_url         => vs_base_url || '/replicats/'||l_proc_name ,
            p_http_method => 'GET',
            p_username  => 'admin',
            p_password => 'admin'
        );
    
        
        l_resp_body := apex_web_service.make_rest_request(
            p_url         => vs_base_url || '/replicats/'||l_proc_name || '/info/status',
            p_http_method => 'GET',
            p_username  => 'admin',
            p_password => 'admin'
        );
    
        --l_proc_name := json_value(l_resp_body,'$.response.config');        
        l_status := json_value(l_resp_body,'$.response.status');
        l_lag := json_value(l_resp_body,'$.response.lag');         
        l_sincelagreported := json_value(l_resp_body,'$.response.sinceLagReported');         
        l_in_prefix := json_value(l_resp_body,'$.response.position.name');
        l_in_seq := json_value(l_resp_body,'$.response.position.sequence');
        l_in_rba := json_value(l_resp_body,'$.response.position.offset');        
        
        insert into soe.RESPONSE (REST_URL, HTTP_METHOD, STATUS_CODE, REQUEST_BODY, RESPONSE_BODY)
        values (vs_base_url || '/extracts/'||l_proc_name, 'GET', apex_web_service.g_status_code, '', l_resp_body)
        --RETURNING INVK_ID INTO l_response_id
        ;
        commit;
        insert into soe.restmon (call_time, id,process_name,status,in_prefix,in_seq,in_rba,lag,sincelagreported) 
        values (v_curr_time,global_seq,l_proc_name,l_status,l_in_prefix,l_in_seq,l_in_rba,l_lag,l_sincelagreported);
        commit;
        
        --open rc for SELECT r.RESPONSE_BODY.totalResults FROM REST_RESPONSE r where invk_id = l_response_id;
        --dbms_sql.return_result(rc);
    end loop;
    
END;
/
EOF
sleep 10 
done

