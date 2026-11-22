#/*
# * example) sh gen_opstatus.sh 360 12 
# */

sqlplus -s soe/soe@orclpdb1 << EOF

set serveroutput on


delete from soe.heartbp ;
commit;

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
	    if mod(k,3) =0 then
		k := 1;
	    end if;
	    
	    insert into soe.heartbp 
            select to_char(sysdate,'YYYYMMDD') dt,
		   i keys,
		   'RJDBC' || k period_start,
		   to_char(sysdate,'YYYYMMDDHH24MISS') start_dt
            from dual
            ;
	    commit;

	    dbms_lock.sleep(5);
	    k := k + 1;

	end loop;
	commit;


end;
/
EOF


