sqlplus -s / as sysdba << EOF
declare 
    k number;
begin 
    k:=1000;
    for i in 1..10 loop
	for j in 1..1000 loop
        	insert into soe.test1 values (k,'test','test');
        	k := k+1;
	end loop;
	--dbms_lock.sleep(3);
    end loop;

    update soe.test1 
    set step2 = 'update'
    where keya >= 1000 and keya <= 15000
    ;

    delete from soe.test1 
    where keya >= 1000 
    and step = 'test'
    ;
    commit;
end;
/
EOF
