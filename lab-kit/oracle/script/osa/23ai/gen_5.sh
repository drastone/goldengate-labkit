#
# * 첫번째 인자는 바깥 loop, 두번째 인자는 두번째 loop 횟수를 의미하고, 내부적으로 10번씩 수행되는 loop가 추가로 있음
# * gen.sh 10 10000 이 의미하는 commit 단위는 10000 * 10 = 100000 임.
# * ex> 
# * sh gen.sh 10000 1 (OLTP workload)
# * sh gen.sh 10 10000 -> 100000건 insert, 70000건 update, 30000건 delete 를 10번 반복수행
# */
#
#sqlplus -s soe/soe@STBWEST <<  EOF2
#truncate table soe.cfund_dt reuse storage;
#EOF2

sqlplus -s soe/soe@orclpdb1 << EOF

whenever oserror exit failure
whenever sqlerror exit sql.sqlcode
set serveroutput on
begin
    execute immediate 'drop sequence soe.batch_key_seq5';
exception
    when others then
        if sqlcode != -2289 then
            raise;
        end if;
end;
/
create sequence soe.batch_key_seq5 
start with 1
increment by 1 
;


declare 
	ei number;
	ai number;
	k number;
	time_val number;
	id_val number;
	date_val date;
	id_str_val varchar2(60);
	id_chr_val char(10);
	loop1st number;
	loop2nd number;
begin

	loop1st := $1;
	loop2nd := $2;
	k := 1;

	for i in 1..loop1st loop
            -- 해약이 일어나는 경우 generation
            --update soe.cfund_rat a
            --set cancel_yn = 'P'
            --where cust_id in (select trunc(dbms_random.value(1,150)) from dual)
   	    --and cancel_yn <> 'Y'
            --;    


            -- by cys 20260111 특정 안정형 펀드, 채권형과 선진국형 펀드를 보유했거나, call center 문의 건수가 많거나, 연체 비율이 높은 고객이 확률적으로 해약할 확률이 높도록 함.
            -- 이미 해약 이력이 있는 고객은 제외하고, 이번 loop 에서 처리할 고객 1명만 선택한다.
            begin
                select cust_id
                into id_val
                from (
                    select cust_id
                    from (
                        select cand.cust_id
                        from (
                            select a.cust_id
                            from soe.cfund_rat a
                            where a.fund_code in (select fund_code from soe.fundm where fund_code in ('FUND2','FUND4'))
                            and nvl(a.cancel_yn, 'N') <> 'Y'
                            union all
                            select a.cust_id
                            from soe.cfund_rat a
                            where a.cust_id in (select cust_id from soe.call_center_log where call_cnt_3m > 13)
                            and nvl(a.cancel_yn, 'N') <> 'Y'
                            union all
                            select a.cust_id
                            from soe.cfund_rat a
                            where a.cust_id in (select cust_id from soe.call_center_log where late_pmt_cnt > 2)
                            and nvl(a.cancel_yn, 'N') <> 'Y'
                        ) cand
                        where not exists (
                            select 1
                            from soe.cfund_dt d
                            where d.cust_id = cand.cust_id
                            and d.op_gubun = '5'
                        )
                    )
                    order by dbms_random.value
                )
                where rownum = 1;
            exception
                when no_data_found then
                    exit;
            end;

            update soe.cfund_rat a
            set cancel_yn = 'P'
            where nvl(cancel_yn, 'N') <> 'Y'
            and cust_id = id_val;

	    -- 보유한 좌수 환매
            insert into soe.cfund_dt
	    select dt, soe.batch_key_seq5.nextval keys,cust_id,fund_code,fund_name,fund_price,fund_cnt,fund_amt,fund_description,op_gubun,'M' op_gubun2,1,to_char(sysdate,'YYYYMMDDHH24MISS') start_dt
            from
            (
                select dt,k keys,cust_id,fund_code,fund_name,fund_price,fund_cnt fund_cnt,
                        trunc(fund_cnt * fund_price) fund_amt,
                        fund_description,op_gubun,start_dt
                from
                (
                    select to_char(sysdate,'YYYYMMDD') dt,1 keys,cust_id,fund_code,
                            (select fund_name from soe.fundm where fund_code = a.fund_code ) fund_name,
                            (select price from soe.fund_price where fund_code = a.fund_code and dt = to_char(sysdate,'YYYYMMDD')) fund_price,
                            --sum(case when op_gubun in ('1','2') then fund_cnt
                                     --when op_gubun in ('3') then -fund_cnt end) fund_cnt,
                            sum(case when op_gubun in ('1','2','4') and start_dt >= max_5_start_dt then fund_cnt
                                         when op_gubun in ('3') and start_dt >= max_5_start_dt then -fund_cnt end) fund_cnt,
                            (select fund_description from soe.fundm where fund_code = a.fund_code ) fund_description     ,
                            '5' op_gubun,
                                (select max(start_dt) from soe.cfund_dt where cust_id = a.cust_id and op_gubun = '5') max_5_start_dt,
                                (select max(start_dt) from soe.cfund_dt where cust_id = a.cust_id ) max_all_start_dt, 
                            to_char(sysdate,'YYYYMMDDHH24MISS') start_dt
                            --start_dt
                    --from soe.cfund_dt a
                    from 
                    (
                        select dt, keys,cust_id,fund_code,fund_cnt,fund_name,fund_price,fund_description,op_gubun,
                                case when max_5_start_dt is null then '20220101' else max_5_start_dt end max_5_start_dt,
                                max_all_start_dt,
                                start_dt
                        from
                        (
                            select to_char(sysdate,'YYYYMMDD') dt,1 keys,cust_id,fund_code,fund_cnt,
                                (select fund_name from soe.fundm where fund_code = a.fund_code ) fund_name,
                                (select price from soe.fund_price where fund_code = a.fund_code and dt = to_char(sysdate,'YYYYMMDD')) fund_price,
                                (select fund_description from soe.fundm where fund_code = a.fund_code ) fund_description     ,
                                op_gubun,
                                    (select max(start_dt) from soe.cfund_dt where cust_id = a.cust_id and op_gubun = '4') max_5_start_dt,
                                    (select max(start_dt) from soe.cfund_dt where cust_id = a.cust_id ) max_all_start_dt, 
                                start_dt
                            from soe.cfund_dt a
                            --where cust_id = '50'
	                    where 
       		            a.cust_id = id_val and
               		    exists (select 1 from soe.cfund_dt where cust_id = a.cust_id and op_gubun <> '4')
                        ) a
                    ) a
                    --where 
		    --exists ( select 1 from soe.cfund_rat where cancel_yn = 'P' and cust_id = a.cust_id) and
                    --exists (select 1 from soe.cfund_dt where cust_id = a.cust_id and op_gubun <> '4')
                    --group by cust_id,fund_code,start_dt
                    group by cust_id,fund_code
                ) b
		where b.cust_id = id_val
/*
                union all
                select dt,1 keys,cust_id,fund_code,fund_name,fund_price,fund_cnt fund_cnt,
                        trunc(fund_cnt * fund_price) fund_amt,
                        fund_description,op_gubun,start_dt
                from
                (
                    select distinct to_char(sysdate,'YYYYMMDD') dt,1 keys,cust_id,fund_code,
                            (select fund_name from soe.fundm where fund_code = a.fund_code ) fund_name,
                            (select price from soe.fund_price where fund_code = a.fund_code and dt = to_char(sysdate,'YYYYMMDD')) fund_price,
                            sum(case when op_gubun in ('1','2','4') and start_dt >= max_5_start_dt then fund_cnt
                                     when op_gubun in ('3') and start_dt >= max_5_start_dt then -fund_cnt end) fund_cnt,
                            (select fund_description from soe.fundm where fund_code = a.fund_code ) fund_description     ,
                            '5' op_gubun,
                            to_char(sysdate,'YYYYMMDDHH24:MI:SS') start_dt
                    --from soe.cfund_dt a
		    from 
		    (
                        select dt, keys,cust_id,fund_code,fund_cnt,fund_name,fund_price,fund_description,op_gubun,
                                case when max_5_start_dt is null then '20220101' else max_5_start_dt end max_5_start_dt,
                                max_all_start_dt,
                                start_dt
                        from
                        (
                            select to_char(sysdate,'YYYYMMDD') dt,1 keys,cust_id,fund_code,fund_cnt,
                                (select fund_name from soe.fundm where fund_code = a.fund_code ) fund_name,
                                (select price from soe.fund_price where fund_code = a.fund_code and dt = to_char(sysdate,'YYYYMMDD')) fund_price,
                                (select fund_description from soe.fundm where fund_code = a.fund_code ) fund_description     ,
                                op_gubun,
                                    (select max(start_dt) from soe.cfund_dt where cust_id = a.cust_id and op_gubun = '4') max_5_start_dt,
                                    (select max(start_dt) from soe.cfund_dt where cust_id = a.cust_id ) max_all_start_dt, 
                                start_dt
                            from soe.cfund_dt a
                            --where cust_id = '50'
                        ) a
                    ) a
                    where exists ( select 1 from soe.cfund_rat where cancel_yn = 'P' and cust_id = a.cust_id)
                    and exists (select 1 from soe.cfund_dt where cust_id = a.cust_id and op_gubun = '4')
		    and fund_code in (select fund_code from soe.cfund_rat where cust_id = a.cust_id and chg_gubun = 'P')
                    --and cust_id = '66'
                    and dt >= (select max(dt) from soe.cfund_dt where cust_id = a.cust_id and op_gubun = '4')
                    group by cust_id,fund_code
                ) b      
*/
            );

            update soe.cfund_rat a
            set cancel_yn = 'Y'
	    where cancel_yn = 'P'
	    and cust_id = id_val
	    ;
	    commit;

            delete from soe.cancelamt 
            where dt = to_char(sysdate,'YYYYMMDD')
            ;
            
            --insert into soe.cancelamt
            --select dt,cust_id, op_gubun,sum(fund_amt),to_char(sysdate,'YYYYMMDDHH24MISS') start_dt
            --from soe.cfund_dt
            --where dt = to_char(sysdate,'YYYYMMDD')
            --and op_gubun = '5'
            --group by dt,cust_id,op_gubun
            --;

            insert into soe.cancelamt
            select a.dt,a.cust_id,a.op_gubun,a.total_amt,a.start_dt,a.cnt,b.work_dt call_dt,b.work_dt_ts call_dt_ts,b.log_id,b.fund_code,b.fund_name,b.call_cnt_3m,b.late_pmt_cnt,b.consult_text
            from
            (
                select dt,cust_id, op_gubun,sum(fund_amt) total_amt,to_char(sysdate,'YYYYMMDDHH24MISS') start_dt,
                    (select count(*) from soe.cfund_dt where cust_id = a.cust_id and op_gubun in (select op_gubun from soe.opm where op_name in ('신규계약','정기납입','추가납입'))) cnt
                from soe.cfund_dt a
                where dt = to_char(sysdate,'YYYYMMDD')
                and op_gubun = '5'
                group by dt,cust_id,op_gubun
            ) a,
            (
                select *
                from soe.call_center_log
            ) b
            where a.cust_id = b.cust_id
            order by 1,2;

            commit;


	    k := k + 1;
	    dbms_lock.sleep(20);

	end loop;
	commit;


end;
/
EOF
