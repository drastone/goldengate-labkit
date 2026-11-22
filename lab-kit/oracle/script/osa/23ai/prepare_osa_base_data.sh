#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="${SCRIPT_DIR}/logs"
RUN_ID="$(date +%Y%m%d_%H%M%S)"
LOG_FILE="${LOG_DIR}/gen_init_${RUN_ID}.log"

mkdir -p "${LOG_DIR}"
cd "${SCRIPT_DIR}"

START_EPOCH="$(date +%s)"
START_TIME="$(date '+%Y-%m-%d %H:%M:%S')"

echo "Initializing OSA base data..."
echo "Start time: ${START_TIME}"
echo "Log file: ${LOG_FILE}"

sqlplus -s soe/soe@orclpdb1 > "${LOG_FILE}" <<'SQL'
set termout off;
set echo off;
set feedback off;
set heading off;
set serveroutput on;

whenever sqlerror continue;
@cust_info.sql
@seed_osa_address.sql
SQL

sqlplus -s soe/soe@orclpdb1 >> "${LOG_FILE}" <<'SQL'
set termout off;
set echo off;
set feedback off;
set heading off;
set serveroutput on;
whenever sqlerror exit failure rollback;

truncate table soe.opstatus;
truncate table soe.cfund_dt;
commit;

insert into soe.cfund_rat
select cust_id, fund_code1, fund_rat1, to_char(sysdate - 1, 'YYYYMMDDHH24MISS'), 'N', 0, 'N'
from soe.cfund_ratio
where fund_code1 is not null
union all
select cust_id, fund_code2, fund_rat2, to_char(sysdate - 1, 'YYYYMMDDHH24MISS'), 'N', 0, 'N'
from soe.cfund_ratio
where fund_code2 is not null;
commit;

begin
  execute immediate 'drop table soe.employee purge';
exception
  when others then
    if sqlcode != -942 then
      raise;
    end if;
end;
/

create table soe.employee (
  id number not null primary key,
  name varchar2(100),
  email varchar2(100),
  age number,
  phonenumber varchar2(20),
  designation varchar2(100),
  created date
);

insert into soe.employee values (1, 'Alicia', 'Alicia@gmail.com', 31, '010-1111-2222', 'FP', sysdate);
insert into soe.employee values (2, 'Sienna', 'Sienna@gmail.com', 32, '010-1111-2222', 'FP', sysdate);
insert into soe.employee values (3, 'Marcie', 'Marcie@gmail.com', 33, '010-1111-2222', 'FP', sysdate);
insert into soe.employee values (4, 'Hyobin', 'Hyobin@gmail.com', 34, '010-1111-2222', 'FP', sysdate);
insert into soe.employee values (5, 'Eileen', 'Eileen@gmail.com', 35, '010-1111-2222', 'FP', sysdate);
insert into soe.employee values (6, 'Lucien', 'Lucien@gmail.com', 36, '010-1111-2222', 'FP', sysdate);
insert into soe.employee values (7, 'Selena', 'Selena@gmail.com', 37, '010-1111-2222', 'FP', sysdate);
insert into soe.employee values (8, 'Hyejin', 'Hyejin@gmail.com', 38, '010-1111-2222', 'FP', sysdate);
insert into soe.employee values (9, 'Sandra', 'Sandra@gmail.com', 39, '010-1111-2222', 'FP', sysdate);
insert into soe.employee values (10, 'Yeonju', 'Yeonju@gmail.com', 31, '010-1111-2222', 'FP', sysdate);
insert into soe.employee values (11, 'Esther', 'Esther@gmail.com', 32, '010-1111-2222', 'FP', sysdate);
insert into soe.employee values (12, 'Margad', 'Margad@gmail.com', 33, '010-1111-2222', 'FP', sysdate);
insert into soe.employee values (13, 'Vivian', 'Vivian@gmail.com', 34, '010-1111-2222', 'FP', sysdate);
insert into soe.employee values (14, 'Selina', 'Selina@gmail.com', 35, '010-1111-2222', 'FP', sysdate);
insert into soe.employee values (15, 'Serena', 'Serena@gmail.com', 36, '010-1111-2222', 'FP', sysdate);
insert into soe.employee values (16, 'Ashley', 'Ashley@gmail.com', 37, '010-1111-2222', 'FP', sysdate);
insert into soe.employee values (17, 'Janice', 'Janice@gmail.com', 38, '010-1111-2222', 'FP', sysdate);
commit;

declare
  v_cust_id number;
  v_created varchar2(8);
  v_cnt number;
  v_payment1_date varchar2(8);
  v_payment2_date varchar2(8);
  v_payment3_date varchar2(8);
  v_payment4_date varchar2(8);
  v_payment5_date varchar2(8);

  cursor c1 is
    select cust_id,
           created,
           (select count(*) from soe.cust_pr where cust_id = a.cust_id) cnt
    from soe.cust_info a
    order by cust_id;
begin
  execute immediate 'truncate table soe.cust_pr';

  open c1;
  loop
    fetch c1 into v_cust_id, v_created, v_cnt;
    exit when c1%notfound;

    select lpad(trunc(dbms_random.value(1, 28)), 2, '0') into v_payment1_date from dual;
    select lpad(trunc(dbms_random.value(1, 28)), 2, '0') into v_payment2_date from dual;
    select lpad(trunc(dbms_random.value(1, 28)), 2, '0') into v_payment3_date from dual;
    select lpad(trunc(dbms_random.value(1, 28)), 2, '0') into v_payment4_date from dual;
    select lpad(trunc(dbms_random.value(1, 28)), 2, '0') into v_payment5_date from dual;

    insert into soe.cust_pr
    select v_cust_id,
           v_created || lpad(v_cnt + id, 3, '0') stock_no,
           1,
           product_code,
           product,
           amt,
           null,
           null,
           payment_date,
           0,
           0,
           0,
           '정상',
           created,
           null
    from (
      select 1 id, category, product_code, product, des, gubun,
             to_char(to_date(created, 'YYYYMMDD') + 700, 'YYYYMMDD') created,
             trunc(dbms_random.value(30, 300)) || '0000' amt,
             v_payment1_date payment_date
      from (select * from soe.product where category = '종신보험' order by dbms_random.random)
      where rownum <= 1
      union all
      select 2 id, category, product_code, product, des, gubun,
             to_char(to_date(created, 'YYYYMMDD') + 700, 'YYYYMMDD') created,
             trunc(dbms_random.value(30, 300)) || '0000' amt,
             v_payment2_date payment_date
      from (select * from soe.product where category = '건강·상해보험' order by dbms_random.random)
      where rownum <= 1
      union all
      select 3 id, category, product_code, product, des, gubun,
             to_char(to_date(created, 'YYYYMMDD') + 700, 'YYYYMMDD') created,
             trunc(dbms_random.value(30, 300)) || '0000' amt,
             v_payment3_date payment_date
      from (select * from soe.product where category = '다이렉트' order by dbms_random.random)
      where rownum <= 1
      union all
      select 4 id, category, product_code, product, des, gubun,
             to_char(to_date(created, 'YYYYMMDD') + 700, 'YYYYMMDD') created,
             trunc(dbms_random.value(30, 300)) || '0000' amt,
             v_payment4_date payment_date
      from (select * from soe.product where category = '변액보험' order by dbms_random.random)
      where rownum <= 1
      union all
      select 5 id, category, product_code, product, des, gubun,
             to_char(to_date(created, 'YYYYMMDD') + 700, 'YYYYMMDD') created,
             trunc(dbms_random.value(30, 300)) || '0000' amt,
             v_payment5_date payment_date
      from (select * from soe.product where category = '연금보험' order by dbms_random.random)
      where rownum <= 1
    );

    commit;
  end loop;
  close c1;

  update soe.cust_pr a
  set rat = round(amt / (select max(amt) from soe.cust_pr where product = a.product), 2),
      debenefit = round(amt / (select max(amt) from soe.cust_pr where product = a.product), 2) * 50000000;
  commit;

  update soe.cfund_deposit a
  set deposit_amt = (
    select amt
    from soe.cust_pr
    where product in (select product from soe.product where category = '변액보험')
      and cust_id = a.cust_id
  );
  commit;
end;
/

@comment_osa_business_metadata.sql

SQL

END_EPOCH="$(date +%s)"
END_TIME="$(date '+%Y-%m-%d %H:%M:%S')"
ELAPSED="$((END_EPOCH - START_EPOCH))"

echo "End time: ${END_TIME}"
echo "Elapsed time: ${ELAPSED} seconds"
echo "OSA base data initialized."
