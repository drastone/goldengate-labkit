sqlplus -s soe/soe@orclpdb1 << EOF
drop table soe.ogg_conf purge;

create table soe.ogg_conf(keya varchar2(20), keyb varchar2(20), keyc varchar2(20), gubun1 varchar2(100)
, gubun2 varchar2(100), gubun3 varchar2(100));

alter table soe.ogg_conf add constraints ogg_conf_pk primary key (keya , keyb);

insert into soe.ogg_conf values ('EXTRACTURL','ADMIN','','http://172.28.0.9','5565','/services/v2');

insert into soe.ogg_conf values ('EXTRACTURL','PMS','','http://172.28.0.9','5568','/services/v2');

insert into soe.ogg_conf values ('EXTRACT','1','','MC03','CACHEMONITOR','');

insert into soe.ogg_conf values ('DISTPATHURL','ADMIN','','http://172.28.0.9','5566','/services/v2');

insert into soe.ogg_conf values ('DISTPATH','1','','MP03','','');

insert into soe.ogg_conf values ('REPLICATURL','ADMIN','','http://172.28.0.2','5665','/services/v2');

insert into soe.ogg_conf values ('REPLICATURL','PMS','','http://172.28.0.2','5665','/services/v2');

insert into soe.ogg_conf values ('REPLICAT','1','','MD01','','');

insert into soe.ogg_conf values ('REPLICAT','2','','MD02','','');

insert into soe.ogg_conf values ('REPLICAT','3','','MD03','','');

commit;
EOF
