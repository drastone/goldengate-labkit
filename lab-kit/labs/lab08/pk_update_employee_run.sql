set echo on
set timing on
set linesize 160
set pagesize 100

col id for 999
col name for a10
col email for a25
col age for 99
col phonenumber for a15
col designation for a25
col created for a20

update soe.employee
set id = 901,
    designation = 'After PK Update',
    created = sysdate
where id = 900;

commit;

select id,
       name,
       email,
       age,
       phonenumber,
       designation,
       to_char(created, 'YYYY-MM-DD HH24:MI:SS') as created
from soe.employee
where id in (900, 901)
order by id;

exit
