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
	    
            update soe.heartbeat
            set source_commit = systimestamp
            where extract_name = 'C01'
            ;
	    commit;

	    dbms_lock.sleep(5);

	end loop;
	commit;


end;
/
EOF


