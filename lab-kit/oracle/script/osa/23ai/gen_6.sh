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
--delete from soe.cfund_dt where dt = to_char(sysdate,'YYYYMMDD');
--commit;

begin
    execute immediate 'drop sequence soe.batch_key_seq6';
exception
    when others then
        if sqlcode != -2289 then
            raise;
        end if;
end;
/
create sequence soe.batch_key_seq6 
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
		
            for j in 1..loop2nd loop    
                insert into soe.cfund_dt
                select dt,
                    --keys,
                    soe.batch_key_seq6.nextval,
                    cust_id,
                    fund_code,
                    a.fund_name,
                    a.fund_price,
                    trunc(tot_amt*fund_rat/10/fund_price) fund_cnt,
                    trunc(tot_amt*fund_rat/10) fund_amt,
                    a.fund_description,
                    --op_gubun,
                    '0' op_gubun,
                    'P' op_gubun2,
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
                                where cancel_yn = 'Y'
                            ) 
                            where dt = max_dt
                         )  a, 
                        (select distinct dt from soe.fund_price where dt = to_char(sysdate,'YYYYMMDD')) b
                    where cust_id in (select cust_id from soe.cfund_deposit sample(10))
                    order by dt,cust_id
                ) a
                ;
		commit;

                update soe.cfund_rat  a
                set cancel_yn = 'N'
                where exists (
                    select 1 from soe.cfund_dt
                    where dt = to_char(sysdate,'YYYYMMDD')
                    and cust_id = a.cust_id
                    and op_gubun = '0'
                )
                ;
		commit;
            end loop;
	    commit;
            


            delete from soe.cust_gen_amt
            where dt = to_char(sysdate,'YYYYMMDD')
            and op_gubun = '0'
            ;


            insert into soe.cust_gen_amt
            select a.dt,a.cust_id,a.op_gubun,a.total_amt,a.start_dt,a.cnt,b.work_dt call_dt,b.work_dt_ts call_dt_ts,b.log_id,b.fund_code,b.fund_name,b.call_cnt_3m,b.late_pmt_cnt,b.consult_text
            from
            (
                select dt,cust_id, op_gubun,sum(fund_amt) total_amt,to_char(sysdate,'YYYYMMDDHH24MISS') start_dt,
                    (select count(*) from soe.cfund_dt where cust_id = a.cust_id and op_gubun in (select op_gubun from soe.opm where op_name in ('신규계약','정기납입','추가납입'))) cnt
                from soe.cfund_dt a
                where dt = to_char(sysdate,'YYYYMMDD')
                and op_gubun = '0'
                group by dt,cust_id,op_gubun
            ) a,
            (
                select *
                from soe.call_center_log
            ) b
            where a.cust_id = b.cust_id
            order by 1,2;

            commit;


	    dbms_lock.sleep(10);

	end loop;
	commit;


end;
/
EOF

