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
    execute immediate 'drop sequence soe.batch_key_seq4';
exception
    when others then
        if sqlcode != -2289 then
            raise;
        end if;
end;
/
create sequence soe.batch_key_seq4 
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

	for i in 1..loop1st loop
            -- 펀드변경이 일어나는 경우 generation
            insert into soe.cfund_rat
            select cust_id,fund_code,fund_rat,dt,chg_gubun,inum,cancel_yn
            from
            (
                select --a.inum,
                        distinct a.cust_id,a.fund_code1 fund_code,
			--a.fund_rat,
			case when inum = 2 then 11 else a.fund_rat end fund_rat,  -- temporary fund_rat to solve duplication issue
			to_char(sysdate,'YYYYMMDDHH24MISS') dt,'Y' chg_gubun,a.inum inum,'N' cancel_yn
                        --case when a.inum = 1 then a.fund_rat else 10 - a.fund_rat end fund_rat
                        --,case when a.inum = 1 then a.fund_rat else 10 - a.fund_rat end fund_rat
                from
                (
                    select rownum inum,cust_id,
                            'FUND'||trunc(dbms_random.value()*10) fund_code1,
                            trunc(dbms_random.value(1,10)) fund_rat
                    from soe.cfund_rat a
                    where cust_id in (select cust_id from (select rownum inum,cust_id from soe.cfund_deposit sample(10)) where inum = 7)
                    and chg_gubun <> 'P'
                )      a
            ) b
            where (cust_id,fund_code,fund_rat,dt) not in (select cust_id,fund_code,fund_rat,dt from soe.cfund_rat)
            ;
            commit;

            -- 펀드변경이 일어나는 경우 두 펀드의 합이 10이 되도록 로직 추가
            update soe.cfund_rat  a
            --set fund_rat =  (select 10 - fund_rat from soe.cfund_rat where cust_id = a.cust_id and inum = 1)
            set fund_rat =  (select 10 - fund_rat 
                            from soe.cfund_rat 
                            where cust_id = a.cust_id 
                            and dt = (select  max(dt) 
                                from  soe.cfund_rat 
                                where cust_id  = a.cust_id
                                group by cust_id)
                            and inum = 1)
            where chg_gubun = 'Y'
            --and 2 =  (select count(distinct fund_code) from soe.cfund_rat where cust_id = a.cust_id and chg_gubun = 'Y')
            and 2 =  (select count(distinct fund_code) 
                      from soe.cfund_rat 
                      where cust_id = a.cust_id 
                      and chg_gubun = 'Y'
                      and dt = (select  max(dt) 
                                from  soe.cfund_rat 
                                where cust_id  = a.cust_id
                                group by cust_id)
                      )
            and inum = 2
            ;
            commit;

		
            for j in 1..loop2nd loop    

                insert into soe.cfund_dt
                select dt,
                    --keys,
                    soe.batch_key_seq4.nextval,
                    cust_id,
                    fund_code,
                    a.fund_name,
                    a.fund_price,
                    --trunc(tot_amt*fund_rat/10/fund_price) fund_cnt,
                    total_cnt fund_cnt,
                    --trunc(tot_amt*fund_rat/10) fund_amt,
                    round(a.fund_price*total_cnt) fund_amt,
                    a.fund_description,
                    --op_gubun,
                    '4' op_gubun,
                    'N' op_gubun2,
                    1 cnt,
                    to_char(sysdate,'YYYYMMDDHH24MISS') start_dt
                    --,fund_rat,tot_amt,tot_amt*fund_rat/10    
                from
                (
                    select b.dt dt,
                        cust_id,
                        fund_code,
                        (select price from soe.fund_price where fund_code = a.fund_code and dt = b.dt) fund_price,
                        (select fund_name from soe.fundm where fund_code = a.fund_code ) fund_name,
                        (select fund_description from soe.fundm where fund_code = a.fund_code ) fund_description,
                        fund_rat,
                        (select deposit_amt from soe.cfund_deposit where cust_id = a.cust_id) tot_amt,                        
                        (select sum(fund_cnt) 
                         from soe.cfund_dt 
                         where cust_id = a.cust_id 
                         and max_5_start_dt <= max_all_start_dt
			 and op_gubun <> '5'
                         and fund_code = a.fund_code) total_cnt,
                        case when substr(a.dt,1,8) = to_char(sysdate,'YYYYMMDD') and a.chg_gubun = 'Y' then '4' else '2' end op_gubun
                    from (select cust_id,fund_code,fund_rat,dt,chg_gubun,inum,
                                --max_5_start_dt,
                                case when max_5_start_dt is null then '20201231' else max_5_start_dt end max_5_start_dt,
                                max_all_start_dt
                            from
                            (
                                select cust_id,fund_code,fund_rat,dt,chg_gubun,inum,
                                        (select max(start_dt) from soe.cfund_dt where cust_id = c.cust_id and op_gubun = '5') max_5_start_dt,
                                        (select max(start_dt) from soe.cfund_dt where cust_id = c.cust_id ) max_all_start_dt,
                                        (select max(dt) from soe.cfund_rat where cust_id = c.cust_id) max_dt
                                from soe.cfund_rat c
                                where cancel_yn <> 'Y'
				and not exists (select 1 from soe.cfund_rat where cust_id = c.cust_id and chg_gubun = 'P' )
				-- 펀드 변경은 하루에 한버만 일어나도록 제한을 두도록 로직 추가 
                            ) 
                            where dt <> max_dt
                         )  a, 
                        (select distinct dt from soe.fund_price where dt = to_char(sysdate,'YYYYMMDD')) b
                    where exists ( select 1 from soe.cfund_rat where chg_gubun = 'Y' and cust_id = a.cust_id)
                    --where cust_id in (select cust_id from soe.cfund_deposit sample(10))
                    order by dt,cust_id
                ) a
		;

/*
                insert into soe.cfund_dt
                select dt,
                    --keys,
                    soe.batch_key_seq4.nextval,
                    cust_id,
                    fund_code,
                    a.fund_name,
                    a.fund_price,
                    trunc(tot_amt*fund_rat/10/fund_price) fund_cnt,
                    trunc(tot_amt*fund_rat/10) fund_amt,
                    a.fund_description,
                    --op_gubun,
                    '4' op_gubun,
		    1 cnt,
                    to_char(sysdate,'YYYYMMDDHH24MISS') start_dt
                    --,fund_rat,tot_amt,tot_amt*fund_rat/10    
                from
                (
                    select b.dt dt,
                        cust_id,
                        fund_code,
                        (select price from soe.fund_price where fund_code = a.fund_code and dt = b.dt) fund_price,
                        (select fund_name from soe.fundm where fund_code = a.fund_code ) fund_name,
                        (select fund_description from soe.fundm where fund_code = a.fund_code ) fund_description,
                        fund_rat,
                        (select deposit_amt from soe.cfund_deposit where cust_id = a.cust_id) tot_amt,                        
                        case when substr(a.dt,1,8) = to_char(sysdate,'YYYYMMDD') and a.chg_gubun = 'Y' then '4' else '2' end op_gubun
                    from (select cust_id,fund_code,fund_rat,dt,chg_gubun,inum
                            from
                            (
                                select cust_id,fund_code,fund_rat,dt,chg_gubun,inum,
                                        (select max(dt) from soe.cfund_rat where cust_id = c.cust_id) max_dt
                                from soe.cfund_rat c
				where cancel_yn <> 'Y'
                            ) 
                            where dt = max_dt
                         )  a, 
                        (select distinct dt from soe.fund_price where dt = to_char(sysdate,'YYYYMMDD')) b
		    where exists ( select 1 from soe.cfund_rat where chg_gubun = 'Y' and cust_id = a.cust_id)
                    --where cust_id in (select cust_id from soe.cfund_deposit sample(10))
                    order by dt,cust_id
                ) a
                ;
*/
            end loop;
	    commit;

            -- 펀드변경이 요청이 있는 customer에 입금이 완료된 후 처리 flag 'P' update
            update soe.cfund_rat  a
            set chg_gubun = 'P'
            where chg_gubun = 'Y';
	    commit;

	    dbms_lock.sleep(10);

	end loop;
	commit;


end;
/
EOF

