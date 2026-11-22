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
	    
            delete from soe.opstatus;
	    commit;

            insert into opstatus
            select op_gubun,
                    (select op_name from soe.opm where op_gubun = a.op_gubun) op_name,
                    count(*)
            from soe.cfund_dt a
            where dt = to_char(sysdate,'YYYYMMDD')
            group by op_gubun
            order by op_gubun
            ;
	    commit;

	    dbms_lock.sleep(5);

	end loop;
	commit;


end;
/
EOF


