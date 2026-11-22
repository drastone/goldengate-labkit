#/*
# * example) sh gen_opstatus.sh 360 12 
# */

sqlplus -s soe/soe@orclpdb1 << EOF

set serveroutput on

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
	    if mod(k,5) =0 then
		k := 1;
	    end if;
	    
            delete from soe.tot_amt;
	    commit;

	    insert into soe.tot_amt
            select 'P' op_gubun,
            --select op_gubun,
                   '적립금총액' gubun,'RJDBC'||k heartbt,sum(fund_amt) fund_amt,to_char(sysdate,'YYYYMMDDHH24MISS') start_dt
            from soe.cfund_dt
            where op_gubun in ('0','1','2')
	    --group by op_gubun
            union all 
            select 'M' op_gubun,'환급금총액' gubun,'RJDBC'||k heartbt,sum(fund_amt) fund_amt,to_char(sysdate,'YYYYMMDDHH24MISS')
            from soe.cfund_dt
            --where op_gubun in ('3','5','4')
            where op_gubun in ('3','5')
            --where op_gubun in ('3')
            --group by op_gubun
            ;
	    commit;

	    dbms_lock.sleep(5);
	    k := k + 1;

	end loop;
	commit;


end;
/
EOF


