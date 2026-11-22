while true
do
sqlplus -s c##ogg/ogg@freepdb1 << EOF


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
    v_message clob;
    v_message_left clob;
    v_cnt number;
    vs_ogg_user varchar2(100);
    vs_ogg_pass varchar2(100);
    vs_api_base varchar2(100);
    l_dml_ins   number;
    l_dml_upd   number;
    l_dml_del   number;
    v_base_ts   date;
BEGIN

    select gubun1, gubun2 into vs_ogg_user, vs_ogg_pass
    from ggadmin.ogg_conf
    where keya = 'OGGUSER' and keyb = 'ADMIN';

    select ggadmin.oggseq.nextval into global_seq
    from dual;

    select to_char(sysdate,'YY/MM/DD HH24:MI:SS') into v_curr_time from dual;

    update ggadmin.restmon
    set call_time = v_curr_time
    where process_name = 'DUMMY_BASE_TIMESTAMP'
    ;

    IF (SQL%rowcount = 0) THEN
        INSERT into ggadmin.restmon (id,call_time,process_name)
        VALUES (0, v_curr_time, 'DUMMY_BASE_TIMESTAMP');
    END IF;

    select gubun1 || ':' ||gubun2 ||gubun3||'/' into vs_base_url
    from ggadmin.ogg_conf
    where keya = 'EXTRACTURL'
    and keyb = 'ADMIN'
    ;

    BEGIN
        select gubun1 || ':' ||gubun2 ||gubun3||'/' into vs_base_pms_url
        from ggadmin.ogg_conf
        where keya = 'EXTRACTURL'
        and keyb = 'PMS'
        ;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        vs_base_pms_url := vs_base_url;
    END;

    select count(gubun1) into l_proc_cnt
    from ggadmin.ogg_conf
    where keya = 'EXTRACT' ;

    for i in 1..l_proc_cnt loop

        BEGIN

        select gubun1, vs_base_url || gubun1 into l_proc_name, vs_url
        from ggadmin.ogg_conf
        where keya = 'EXTRACT'
        and keyb = i
        ;

        l_resp_body := apex_web_service.make_rest_request(
            p_url         => vs_base_url || '/extracts/'||l_proc_name ,
            p_http_method => 'GET',
            p_username  => vs_ogg_user,
            p_password => vs_ogg_pass
        );

        l_out_prefix := json_value(l_resp_body,'$.response.targets.name');
        l_out_seq := json_value(l_resp_body,'$.response.targets.sequence');
        l_out_rba := json_value(l_resp_body,'$.response.targets.offset');



        l_resp_body := apex_web_service.make_rest_request(
            p_url         => vs_base_url || '/extracts/'||l_proc_name || '/info/status',
            p_http_method => 'GET',
            p_username  => vs_ogg_user,
            p_password => vs_ogg_pass
        );

        l_status := json_value(l_resp_body,'$.response.status');
        l_lag := json_value(l_resp_body,'$.response.lag');
        l_sincelagreported := json_value(l_resp_body,'$.response.sinceLagReported');


        l_resp_body := apex_web_service.make_rest_request(
            p_url         => vs_base_pms_url || '/mpoints/'||l_proc_name || '/cacheStatistics',
            p_http_method => 'GET',
            p_username  => vs_ogg_user,
            p_password => vs_ogg_pass
        );

        l_bytestodisk := json_value(l_resp_body,'$.response.totalFileCacheBytesToDisk');


        l_resp_body := apex_web_service.make_rest_request(
            p_url         => vs_base_pms_url || '/mpoints/'||l_proc_name || '/superpoolStatistics',
            p_http_method => 'GET',
            p_username  => vs_ogg_user,
            p_password => vs_ogg_pass
        );

        l_cachesize := json_value(l_resp_body,'$.response.softPageoutSize');
        l_maxvmused := json_value(l_resp_body,'$.response.maxVmUsed');
        l_vmcurrentvmused := json_value(l_resp_body,'$.response.currentVmUsed');
        l_currentmmapanon := json_value(l_resp_body,'$.response.currentMmapAnon');
        l_currentmmaprecycles := json_value(l_resp_body,'$.response.currentMmapRecycles');

        l_resp_body := apex_web_service.make_rest_request(
            p_url         => vs_base_pms_url || '/mpoints/'||l_proc_name || '/brStatus',
            p_http_method => 'GET',
            p_username  => vs_ogg_user,
            p_password => vs_ogg_pass
        );

        l_brtotstatsize := json_value(l_resp_body,'$.response.totalStateSize');
        l_brtotdatasize := json_value(l_resp_body,'$.response.totalDataSize');


        insert into ggadmin.RESPONSE (REST_URL, HTTP_METHOD, STATUS_CODE, REQUEST_BODY, RESPONSE_BODY)
        values (vs_base_url || '/extracts/'||l_proc_name, 'GET', apex_web_service.g_status_code, '', l_resp_body)
        ;
        commit;


        insert into ggadmin.restmon (call_time,id,process_name,status,out_prefix,out_seq,out_rba,lag,sincelagreported,cachesize, maxvmused,currentvmused,currentmmapanon,currentmmaprecycles,bytestodisk,brTotStateSize,brTotDataSize)
        values (v_curr_time,global_seq,l_proc_name,l_status,l_out_prefix,l_out_seq,l_out_rba,l_lag,l_sincelagreported,l_cachesize,l_maxvmused,l_vmcurrentvmused,l_currentmmapanon,l_currentmmaprecycles,l_bytestodisk,l_brtotstatsize,l_brtotdatasize);
        commit;

        EXCEPTION WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('EXTRACT[' || i || '] ERR: ' || SQLERRM);
        END;

    end loop;


---
---

    select  gubun1 || ':' ||gubun2 ||gubun3||'/' into vs_base_url
    from ggadmin.ogg_conf
    where keya = 'DISTPATHURL'
    and keyb = 'ADMIN';

    select count(gubun1) into l_proc_cnt
    from ggadmin.ogg_conf
    where keya = 'DISTPATH' ;


    for i in 1..l_proc_cnt loop

        BEGIN

        select gubun1, vs_base_url || gubun1 into l_proc_name, vs_url
        from ggadmin.ogg_conf
        where keya = 'DISTPATH'
        and keyb = i
        ;


        l_resp_body := apex_web_service.make_rest_request(
            p_url         => vs_base_url || '/sources/'||l_proc_name ,
            p_http_method => 'GET',
            p_username  => vs_ogg_user,
            p_password => vs_ogg_pass
        );


        l_status := json_value(l_resp_body,'$.response.status');
        -- l_proc_name은 ogg_conf 값을 그대로 사용 (응답 name으로 덮어쓰지 않음)


        l_resp_body := apex_web_service.make_rest_request(
            p_url         => vs_base_url || '/sources/'||l_proc_name || '/checkpoints',
            p_http_method => 'GET',
            p_username  => vs_ogg_user,
            p_password => vs_ogg_pass
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
            p_username  => vs_ogg_user,
            p_password => vs_ogg_pass
        );

        l_lag := json_value(l_resp_body,'$.response.lag');
        l_sincelagreported := json_value(l_resp_body,'$.response.sinceLagReported');

        insert into ggadmin.RESPONSE (REST_URL, HTTP_METHOD, STATUS_CODE, REQUEST_BODY, RESPONSE_BODY)
        values (vs_base_url || '/sources/'||l_proc_name, 'GET', apex_web_service.g_status_code, '', l_resp_body)
        ;
        commit;

        insert into ggadmin.restmon (call_time,id,process_name,status,in_prefix,in_seq,in_rba,out_prefix,out_seq,out_rba,lag,sincelagreported)
        values (v_curr_time,global_seq,l_proc_name,l_status,l_in_prefix,l_in_seq,l_in_rba,l_out_prefix,l_out_seq,l_out_rba,l_lag,l_sincelagreported);
        commit;

        EXCEPTION WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('DISTPATH[' || i || '] ERR: ' || SQLERRM);
        END;

    end loop;


    select gubun1 || ':' ||gubun2 ||gubun3||'/'  into vs_base_url
    from ggadmin.ogg_conf
    where keya = 'REPLICATURL'
    and keyb = 'ADMIN'
    ;

    select count(gubun1) into l_proc_cnt
    from ggadmin.ogg_conf
    where keya = 'REPLICAT' ;


    for i in 1..l_proc_cnt loop

        BEGIN

        select gubun1, vs_base_url || gubun1 into l_proc_name, vs_url
        from ggadmin.ogg_conf
        where keya = 'REPLICAT'
        and keyb = i
        ;

        l_resp_body := apex_web_service.make_rest_request(
            p_url         => vs_base_url || '/replicats/'||l_proc_name ,
            p_http_method => 'GET',
            p_username  => vs_ogg_user,
            p_password => vs_ogg_pass
        );


        l_resp_body := apex_web_service.make_rest_request(
            p_url         => vs_base_url || '/replicats/'||l_proc_name || '/info/status',
            p_http_method => 'GET',
            p_username  => vs_ogg_user,
            p_password => vs_ogg_pass
        );

        l_status := json_value(l_resp_body,'$.response.status');
        l_lag := json_value(l_resp_body,'$.response.lag');
        l_sincelagreported := json_value(l_resp_body,'$.response.sinceLagReported');
        l_in_prefix := json_value(l_resp_body,'$.response.position.name');
        l_in_seq := json_value(l_resp_body,'$.response.position.sequence');
        l_in_rba := json_value(l_resp_body,'$.response.position.offset');

        insert into ggadmin.RESPONSE (REST_URL, HTTP_METHOD, STATUS_CODE, REQUEST_BODY, RESPONSE_BODY)
        values (vs_base_url || '/extracts/'||l_proc_name, 'GET', apex_web_service.g_status_code, '', l_resp_body)
        ;
        commit;
        insert into ggadmin.restmon (call_time, id,process_name,status,in_prefix,in_seq,in_rba,lag,sincelagreported)
        values (v_curr_time,global_seq,l_proc_name,l_status,l_in_prefix,l_in_seq,l_in_rba,l_lag,l_sincelagreported);
        commit;

        EXCEPTION WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('REPLICAT[' || i || '] ERR: ' || SQLERRM);
        END;

    end loop;

---
--- DML Stats (NONINTEGRATED replicat이라 GV$GOLDENGATE_TABLE_STATS 미사용 → ogg_api_server 경유)
---

    -- EXTRACTURL에서 host 부분 추출 → api server URL 구성 (port 8765)
    select regexp_substr(gubun1, 'https?://[^:]+') || ':8765'
    into vs_api_base
    from ggadmin.ogg_conf
    where keya = 'EXTRACTURL' and keyb = 'ADMIN';

    -- mond.sh의 BASE_TIMESTAMP call_time을 읽어 DML stats도 같은 call_time 사용
    BEGIN
        select call_time into v_base_ts
        from ggadmin.monres
        where keya = 'replicat' and keyb = 'BASE_TIMESTAMP';
    EXCEPTION WHEN NO_DATA_FOUND THEN
        v_base_ts := v_curr_time;
    END;

    for r in (select gubun1 proc_name, keyb seq from ggadmin.ogg_conf where keya = 'REPLICAT' order by keyb) loop
        BEGIN
            l_resp_body := apex_web_service.make_rest_request(
                p_url         => vs_api_base || '/api/dmlstats?proc=' || r.proc_name,
                p_http_method => 'GET'
            );
            l_dml_ins := nvl(json_value(l_resp_body, '$.inserts'), 0);
            l_dml_upd := nvl(json_value(l_resp_body, '$.updates'), 0);
            l_dml_del := nvl(json_value(l_resp_body, '$.deletes'), 0);

            update ggadmin.monres
            set call_time = v_base_ts,
                val1 = to_char(v_base_ts, 'YY/MM/DD HH24:MI:SS'),
                val3 = l_dml_ins || ':' || l_dml_upd || ':' || l_dml_del
            where keya = 'replicat'
            and keyb = 'Replicat Stats'
            and keyc = r.proc_name
            ;
            IF (SQL%rowcount = 0) THEN
                insert into ggadmin.monres (call_time, keya, keyb, keyc, val1, val3)
                values (v_base_ts, 'replicat', 'Replicat Stats', r.proc_name,
                        to_char(v_base_ts, 'YY/MM/DD HH24:MI:SS'),
                        l_dml_ins || ':' || l_dml_upd || ':' || l_dml_del);
            END IF;
            commit;
        EXCEPTION WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('DMLSTATS[' || r.proc_name || '] ERR: ' || SQLERRM);
        END;
    end loop;

EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('FATAL ERR: ' || SQLERRM);
END;
/
EOF
sleep 10
done

