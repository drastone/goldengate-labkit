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
	loop1st := $1*2;
	loop2nd := $2;
	ei := 1;
	ai := 1;
	k := 1;
	time_val := dbms_utility.get_time;
	date_val := sysdate;
	id_val := k*time_val;

	insert into soe.msg values ('T7',to_char(sysdate,'YYYYMMDDHH24:MI:SS'),null,'N');
	commit;
	for i in 1..loop1st loop
		id_str_val := to_char(id_val + i);
		id_str_val := rpad(id_str_val, 60, id_str_val);
		id_chr_val := substr(id_str_val,-10);

		for j in 1..loop2nd loop  

                        insert into soe.cfund_dt  
                        select a.dt, a.keys,a.cust_id,a.fund_code,a.fund_name,a.fund_price,a.fund_cnt,
                                        round((a.fund_price * a.fund_cnt)) fund_amt,
                                        (select fund_description from soe.fundm where fund_code = a.fund_code) fund_description,
                                        a.op_gubun,
                                        'M' op_gubun2,
					1 cnt,
                                        to_char(sysdate,'YYYYMMDDHH24MISS') start_dt
                        from
                        (
                                select distinct a.dt, k keys,a.cust_id,a.fund_code_base fund_code,
                                        (select fund_name from soe.fundm where fund_code = a.fund_code_base) fund_name,
                                        (select price from soe.fund_price where fund_code = a.fund_code_base and dt = to_char(sysdate,'YYYYMMDD')) fund_price,
                                        case when fund_code_base is not null then trunc(tot1 / (select price from soe.fund_price where fund_code = a.fund_code_base and dt = to_char(sysdate,'YYYYMMDD'))) 
                                                when fund_code_base is null then 0 
                                                end fund_cnt,
                                        3 op_gubun
                                from
                                (
                                    select a.*,
                                        (select sum(fund_amt) 
                                        from soe.cfund_dt 
                                        where cust_id = a.cust_id  
                                        and start_dt > a.max_5_start_dt
                                        ) * 0.05 as tot1
                                    from
                                    (
                                            select a.dt,1 keys,a.cust_id,a.fund_code_base,a.fund_name,a.fund_price,fund_cnt,start_dt,
                                                    case when max_5_start_dt is null then '20220101010101' else max_5_start_dt end max_5_start_dt
                                            from
                                            (
                                                select a.*, 
                                                        trunc(fund_price*fund_cnt),
                                                        (select fund_code from soe.cfund_dt sample(5) where cust_id = a.cust_id and rownum = 1) fund_code_base,
                                                        (select max(start_dt) from soe.cfund_dt where cust_id = a.cust_id and op_gubun = '5') max_5_start_dt,
                                                        (select max(start_dt) from soe.cfund_dt where cust_id = a.cust_id ) max_all_start_dt
                                                from soe.cfund_dt a
                                                where dt = to_char(sysdate,'YYYYMMDD')
                                                order by start_dt            
                                            )  a
/*
                                            select a.*, 
                                                    trunc(fund_price*fund_cnt),
                                                    (select fund_code from soe.cfund_dt sample(5) where cust_id = a.cust_id and rownum = 1) fund_code_base,
                                                    (select max(start_dt) from soe.cfund_dt where cust_id = a.cust_id and op_gubun = '5') max_5_start_dt,
                                                    (select max(start_dt) from soe.cfund_dt where cust_id = a.cust_id ) max_all_start_dt
                                            from soe.cfund_dt a
                                            where dt = to_char(sysdate,'YYYYMMDD')
                                            order by start_dt
*/
                                    ) a
                                    where start_dt > max_5_start_dt    
                                ) a
                                where fund_code_base is not null
                        ) a    
                        where cust_id in (select cust_id from soe.cfund_deposit sample(10))
			--and fund_cnt < (select tot_cnt from soe.reserves_amt where cust_id = a.cust_id and dt = to_char(sysdate-1,'YYYYMMDD') and fund_code = a.fund_code)
                        and fund_cnt <  (select sum(distinct b.tot_cnt)
                                        from
                                        (
                                            select b.dt,cust_id,fund_code,fund_name,op_gubun,
                                                (select sum(case when op_gubun in ('1','2') then fund_cnt when op_gubun = '3' then -fund_cnt end)
                                                 from soe.cfund_dt 
                                                 where cust_id = b.cust_id 
                                                 and fund_code = b.fund_code
                                                 and fund_name = b.fund_name
                                                 --and op_gubun = b.op_gubun
                                                 and dt <= b.dt
                                                 ) tot_cnt     
                                            from soe.cfund_dt b
                                            where 
                                            b.cust_id = a.cust_id and b.dt = to_char(sysdate,'YYYYMMDD')
					    and b.fund_code = a.fund_code
                                            group by b.dt,cust_id,fund_code,fund_name,op_gubun
                                        ) b)
			and exists ( select 1 from soe.cfund_rat where cust_id = a.cust_id and cancel_yn <> 'Y')
                        and fund_name is not null
                        ;

                        k := k + 1;
		end loop;
		if ( mod(ei,3)=0) then 
			rollback;
		else
			ai := ai + 1;
			commit;
		end if;
		
		commit;		
		
		if (ai > $1) then
			exit;
		end if;

		ei := ei + 1;
		dbms_lock.sleep(10);
	end loop;

	commit;

end;
/
EOF


