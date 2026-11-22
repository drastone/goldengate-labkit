#!/bin/bash

ORACLE_HOME=/opt/oracle/product/23ai/dbhomeFree
ORACLE_SID=FREE
LD_LIBRARY_PATH=/opt/oracle/product/23ai/dbhomeFree/lib:/usr/java/jdk-17/jre/lib/amd64/server:$/lib:/usr/lib:
#TNS_ADMIN=*path*

export ORACLE_HOME
export ORACLE_SID
export LD_LIBRARY_PATH

PATH=$PATH:$HOME/.local/bin:$ORACLE_HOME/bin:$HOME/bin

export PATH

rm -rf /home/oracle/oggmsa/ogg213/bin/a.txt
touch /home/oracle/oggmsa/ogg213/bin/a.txt
echo $1 >> /home/oracle/oggmsa/ogg213/bin/a.txt
echo $2 >> /home/oracle/oggmsa/ogg213/bin/a.txt
echo $3 >> /home/oracle/oggmsa/ogg213/bin/a.txt


arg2=`sqlplus -S ggadmin/ogg@FREEPDB1 << aa
set head off;
set feedback off;
set timing off;

select val from trail_arg where args = '2';
aa
`

arg3=`sqlplus -S ggadmin/ogg@FREEPDB1 << bb
set head off;
set feedback off;
set timing off;

select val from trail_arg where args = '3';
bb
`

#FILE="/home/oracle/script/msa/23aifree/trails/d1000000046"
FILE="/home/oracle/script/msa/23aifree/trails/$1"
echo 'FILE->'$FILE
#FILE=$1

#sleep 30

rm -rf /home/oracle/script/msa/23aifree/trails/lgd.dat
#touch /home/oracle/script/msa/23aifree/trails/lgd.dat

#sh /home/oracle/oggmsa/ogg213/bin/print-trail-summary.sh $FILE  | awk '{print $1 "|" $2 "|" $3 "|" $4 "|" $5 "|" $6 "|" $7 "|" $8 "|" $9 "|" $10 "|" $11 "|" $12 "|" $13}' >> /home/oracle/script/msa/23aifree/trails/lgd.dat

#for i in $(seq -w $arg2 $arg3); do
#rm -rf /home/oracle/script/msa/23aifree/trails/$i.dat 
#sleep 3
#done


#FILE="/home/oracle/script/msa/23aifree/trails/$1$(printf %09d $arg2)"
FILE=""
for i in $(seq -w $arg2 $arg3); do
FILE=$FILE" /home/oracle/script/msa/23aifree/trails/$1$(printf %09d $i)"
done
sh /home/oracle/oggmsa/ogg213/bin/print-trail-summary.sh $FILE  | awk '{print $1 "|" $2 "|" $3 "|" $4 "|" $5 "|" $6 "|" $7 "|" $8 "|" $9 "|" $10 "|" $11 "|" $12 "|" $13}' >> /home/oracle/script/msa/23aifree/trails/lgd.dat




#for i in $(seq -w $arg2 $arg3); do
#FILE="/home/oracle/script/msa/23aifree/trails/$1$(printf %09d $i)"
#sh /home/oracle/oggmsa/ogg213/bin/print-trail-summary.sh $FILE  | awk '{print $1 "|" $2 "|" $3 "|" $4 "|" $5 "|" $6 "|" $7 "|" $8 "|" $9 "|" $10 "|" $11 "|" $12 "|" $13}' >> /home/oracle/script/msa/23aifree/trails/$i.dat
#echo $FILE >> /home/oracle/oggmsa/ogg213/bin/a.txt
#echo 'i-> '$i >> /home/oracle/oggmsa/ogg213/bin/a.txt
#echo '2nd-> '$arg2 >> /home/oracle/oggmsa/ogg213/bin/a.txt
#echo '3rd-> '$arg3 >> /home/oracle/oggmsa/ogg213/bin/a.txt
#sleep 3
#done

#for i in $(seq -w $arg2 $arg3); do
#cat /home/oracle/script/msa/23aifree/trails/$i.dat >> /home/oracle/script/msa/23aifree/trails/lgd.dat
#sleep 3
#done

touch /home/oracle/oggmsa/ogg213/bin/b.txt


#sqlplus -s ggadmin/ogg@FREEPDB1 << EOF
sqlplus ggadmin/ogg@FREEPDB1 << EOF
#/opt/oracle/product/23ai/dbhomeFree/bin/sqlplus ggadmin/ogg@FREEPDB1 << EOF
#sqlplus -S soe/soe@FREEPDB1 << EOF

#spool $FILE
#select count(*) from score_tbl
#spool off

--truncate table tmp;


drop TABLE ggadmin.lgd purge;
CREATE TABLE ggadmin.lgd (
                resv1   char(10),
                resv2   char(10),
                resv3   char(10),
                resv4   char(15),
                resv5   char(30),
                resv6   char(50),
                resv7   char(20),
                resv8   char(20),
                resv9   char(20),
                resv10  char(20),
                resv11  char(50),
                resv12  char(20),
                resv13  char(20)
)
ORGANIZATION EXTERNAL (
  TYPE ORACLE_LOADER
  DEFAULT DIRECTORY trails
  ACCESS PARAMETERS (
    RECORDS DELIMITED BY NEWLINE
    FIELDS TERMINATED BY '|'
    MISSING FIELD VALUES ARE NULL
    (
                resv1   char(10),
                resv2   char(10),
                resv3   char(10),
                resv4   char(15),
                resv5   char(30),
                resv6   char(50),
                resv7   char(20),
                resv8   char(20),
                resv9   char(20),
                resv10  char(20),
                resv11  char(50),
                resv12  char(20),
                resv13  char(20)
    )
  )
  LOCATION ('lgd.dat')
)
PARALLEL 5
REJECT LIMIT UNLIMITED;

drop table ggadmin.lgd_tmp purge;
create table ggadmin.lgd_tmp as
select
resv1 ,
resv2 ,
resv3 ,
resv4 ,
resv5 ,
resv6 ,
resv7 ,
resv8 ,
resv9 ,
to_number(resv10) resv10,
resv11,
resv12,
resv13
from ggadmin.lgd
;

drop index ggadmin.lgd_tmp_idx01 ;
create index ggadmin.lgd_tmp_idx01 on ggadmin.lgd_tmp (resv10,resv1);


insert into tmp values ('success',sysdate);
commit;

exit;
EOF
