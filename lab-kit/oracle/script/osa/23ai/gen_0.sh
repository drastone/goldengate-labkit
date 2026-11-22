sqlplus -s soe/soe@orclpdb1 << EOF

truncate table soe.cfund_dt reuse storage;
truncate table soe.cust_dep_dt reuse storage;
truncate table soe.reserves_amt reuse storage;
truncate table soe.cfund_rat reuse storage;
truncate table soe.cust_gen_amt reuse storage;
insert into soe.cfund_rat 
select cust_id, fund_code1,fund_rat1,to_char(sysdate-1,'YYYYMMDDHH24MISS'),'N',0,'N'
from soe.cfund_ratio
where fund_code1 is not null
union all
select cust_id, fund_code2,fund_rat2,to_char(sysdate-1,'YYYYMMDDHH24MISS'),'N',0,'N'
from soe.cfund_ratio
where fund_code2 is not null
;
commit;

begin
  execute immediate 'drop sequence soe.batch_key_seq';
exception
  when others then
    if sqlcode != -2289 then
      raise;
    end if;
end;
/
create sequence soe.batch_key_seq 
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
	months number;


begin

	months := $1;
	
	for i in -months..-1 loop 
	
                                    
            insert into soe.cfund_dt
            select dt,
                    --keys,
                    batch_key_seq.nextval,
                    cust_id,
                    fund_code,
                    a.fund_name,
                    a.fund_price,
                    --trunc(tot_amt*fund_rat/10/fund_price) fund_cnt,
                    case when fund_price =0 then 0 else trunc(tot_amt*fund_rat/10/fund_price) end fund_cnt,
                    trunc(tot_amt*fund_rat/10) fund_amt,
                    a.fund_description,
                    op_gubun,
                    'P' go_gubun2,
                    1 cnt,
                    to_char(sysdate,'YYYYMMDDHH24MISS') start_dt
                    --,fund_rat,tot_amt,tot_amt*fund_rat/10
            from
            (
                    select a.payment_date dt,
                            cust_id,
                            fund_code,
                            (select price from soe.fund_price where fund_code = a.fund_code and dt = a.payment_date) fund_price,
                            (select fund_name from soe.fundm where fund_code = a.fund_code ) fund_name,
                            (select fund_description from soe.fundm where fund_code = a.fund_code ) fund_description,
                            fund_rat,
                            (select deposit_amt from soe.cfund_deposit where cust_id = a.cust_id) tot_amt,
                            case when substr(a.dt,1,8) = to_char(sysdate,'YYYYMMDD') and a.chg_gubun = 'Y' then '4' else '1' end op_gubun
                    --from soe.cfund_rat a, (select distinct dt from soe.fund_price where dt <= to_char(sysdate-1,'YYYYMMDD') ) b
                    --from soe.cfund_rat a, (select distinct dt from soe.fund_price where dt <= to_char(sysdate-1,'YYYYMMDD') and substr(dt,7,2)='15' ) b -- 정기납입일 매월 15일로 설정
                    from
                        (
                            select a.*, to_char(add_months(sysdate,i),'YYYYMM')||b.payment_date payment_date
                            from soe.cfund_rat a,
                                (
                                    select cust_id, payment_date from soe.cust_pr
                                    where product in (select product from soe.product where category = '변액보험')
                                ) b
                            where a.cust_id = b.cust_id
                        ) a
                    order by dt,cust_id
            ) a
            --where dt >= to_char(add_months(sysdate,-9),'YYYYMM')||'01'
            where dt >= to_char(add_months(sysdate,i),'YYYYMM')||'01'
            and dt <= to_char(add_months(sysdate,i),'YYYYMM')||'31'
            and cust_id not in (select cust_id from soe.cfund_deposit sample(10))
            ;
    
            commit;                                


	    --변액 상품 
            insert into soe.cust_dep_dt            
            select to_char(add_months(sysdate,i),'YYYYMM')||b.payment_date,b.cust_id,
                b.stock_no ,
                b.seq_no,
                b.product_code,
                b.product,
                sum(a.fund_amt),
                b.payment_date,
                b.status
            from (select * from soe.cfund_dt where substr(dt,1,6) = to_char(add_months(sysdate,i),'YYYYMM')) a, soe.cust_pr b, 
                (select cust_id,stock_no,max(seq_no) seq_no from soe.cust_pr group by cust_id,stock_no) c
            where a.cust_id(+) = b.cust_id   
            and b.cust_id = c.cust_id 
            and b.stock_no = c.stock_no 
            and b.seq_no = c.seq_no
            and b.product_code in (select product_code from soe.product where category = '변액보험')
            group by dt,b.cust_id,b.stock_no,b.seq_no,b.product_code,b.product,b.payment_date,b.status
            order by dt,b.cust_id
            ;
            commit;



	    --변액 상품 제외
            insert into soe.cust_dep_dt            
            select to_char(add_months(sysdate,i),'YYYYMM')||a.payment_date ,
                a.cust_id,a.stock_no,a.seq_no,a.product_code,a.product,b.amt,a.payment_date,a.status
            from soe.cust_pr a,
                (
                    select to_char(add_months(sysdate,i),'YYYYMM')||b.payment_date payment_date,b.cust_id,
                        b.stock_no ,
                        b.seq_no,
                        b.product_code,
                        b.product,
                        b.amt,
                        b.payment_date,
                        b.status
                    from soe.cust_pr b,
                        (select cust_id,stock_no,max(seq_no) seq_no from soe.cust_pr group by cust_id,stock_no) c
                    where b.cust_id = c.cust_id
                    and b.stock_no = c.stock_no
                    and b.seq_no = c.seq_no
                    and b.cust_id not in (select cust_id from soe.cfund_deposit sample(10))
                    and b.product_code in (select product_code from soe.product where category <> '변액보험')
                    order by to_char(add_months(sysdate,i),'YYYYMM')||b.payment_date,b.cust_id
                ) b
            where a.cust_id = b.cust_id(+)
            and a.stock_no = b.stock_no(+)
            and a.seq_no = b.seq_no(+)
            and a.product_code in (select product_code from soe.product where category <> '변액보험')
            ;

            commit;
            


	    -- 연체 회수
            update soe.cust_pr 
            set overdue = overdue + 1
            where (cust_id,stock_no,seq_no) in 
                (
                    select cust_id,stock_no,seq_no
                    from soe.cust_dep_dt 
                    where 
                    amt is null
                    and substr(dt,1,6) = to_char(add_months(sysdate,i),'YYYYMM')
                )
            ;
            commit;


	    -- 연속 2번 납입 연체시 실효
            update soe.cust_pr
            set overdue_resc = 2, status = '실효', silhyo_cnt = silhyo_cnt + 1
            where (cust_id,stock_no,seq_no) in
                (
                    select cust_id,stock_no,seq_no--,count(*)
                    from soe.cust_dep_dt 
                    where amt is null 
                    and substr(dt,1,6) in (to_char(add_months(sysdate,(i-1)),'YYYYMM'),to_char(add_months(sysdate,i),'YYYYMM'))
                    group by cust_id,stock_no,seq_no
                    having count(*)= 2
                )
            ;
            commit;



            update soe.cust_dep_dt
            set status = '실효'
            where (cust_id,stock_no,seq_no) in
                (
                    select cust_id,stock_no,seq_no--,count(*)
                    from soe.cust_dep_dt
                    where amt is null
                    and substr(dt,1,6) in (to_char(add_months(sysdate,(i-1)),'YYYYMM'),to_char(add_months(sysdate,i),'YYYYMM'))
                    group by cust_id,stock_no,seq_no
                    having count(*)= 2
                )
            and substr(dt,1,6) = to_char(add_months(sysdate,i),'YYYYMM')
            ;
            commit;



	    -- 해당월에 납입이 되면 자동 부활
            update soe.cust_pr
            set status = '정상'
            where (cust_id,stock_no,seq_no) in
                (
                    select cust_id,stock_no,seq_no from soe.cust_dep_dt
                    where amt is not null 
                    and substr(dt,1,6) = to_char(add_months(sysdate,i),'YYYYMM')
                )
            ;
            commit;



            update soe.cust_dep_dt
            set status = '정상'
            where (cust_id,stock_no,seq_no) in
                (
                    select cust_id,stock_no,seq_no from soe.cust_dep_dt
                    where amt is not null
                    and substr(dt,1,6) = to_char(add_months(sysdate,i),'YYYYMM')
                )
            and substr(dt,1,6) = to_char(add_months(sysdate,i),'YYYYMM')
            ;
            commit;








	end loop;



            --delete from soe.cust_gen_amt
            --where dt = to_char(sysdate,'YYYYMMDD')
            --and op_gubun = '1'
            --;



            insert into soe.cust_gen_amt
            select a.dt,a.cust_id,a.op_gubun,a.total_amt,a.start_dt,a.cnt,b.work_dt call_dt,b.work_dt_ts call_dt_ts,b.log_id,b.fund_code,b.fund_name,b.call_cnt_3m,b.late_pmt_cnt,b.consult_text
            from
            (
                select dt,cust_id, op_gubun,sum(fund_amt) total_amt,to_char(sysdate,'YYYYMMDDHH24MISS') start_dt,
                    (select count(*) from soe.cfund_dt where cust_id = a.cust_id and op_gubun in (select op_gubun from soe.opm where op_name in ('신규계약','정기납입','추가납입'))) cnt
                from soe.cfund_dt a
                --where dt = to_char(sysdate,'YYYYMMDD')
                --and op_gubun = '1'
                where op_gubun = '1'
                group by dt,cust_id,op_gubun
            ) a,
            (
                select *
                from soe.call_center_log
            ) b
            where a.cust_id = b.cust_id
            order by 1,2;

            commit;

	insert into soe.reserves_amt
        select a.dt,a.cust_id,a.fund_code,a.fund_name,a.op_gubun,a.deposit_fund_cnt,a.fund_price,a.tot_cnt,
                round(a.tot_cnt*a.fund_price) tot_amt
        from
        (
            select a.dt,cust_id,fund_code,fund_name,op_gubun,
                case when op_gubun in ( '1','2') then sum(fund_cnt) 
                     when op_gubun = '3' then -sum(fund_cnt) 
                     end deposit_fund_cnt,
                --0 withdraw_fund_cnt,
                (select price from soe.fund_price where fund_code = a.fund_code and dt = a.dt) fund_price,
                (select sum(case when op_gubun in ('1','2') then fund_cnt when op_gubun = '3' then -fund_cnt end)
                 from soe.cfund_dt 
                 where cust_id = a.cust_id 
                 and fund_code = a.fund_code
                 and fund_name = a.fund_name
                 --and op_gubun = a.op_gubun
                 and dt <= a.dt
                 ) tot_cnt     
            from soe.cfund_dt a,(select distinct dt from soe.fund_price where dt >= to_char(add_months(sysdate,-3),'YYYYMM')||'01') b
            where a.dt=b.dt
            --and op_gubun = '1'
            group by a.dt,cust_id,fund_code,fund_name,op_gubun
            order by a.dt,cust_id,fund_code,fund_name,op_gubun
        ) a
	;
	commit;




end;
/
EOF


