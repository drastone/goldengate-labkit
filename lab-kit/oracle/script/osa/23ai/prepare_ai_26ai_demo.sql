set define on
set serveroutput on size unlimited
set feedback on

whenever sqlerror exit failure rollback

delete from soe.cancelamt
where log_id like 'AI26AI%';

insert into soe.cust_info (
  cust_id,
  cust_nm,
  jumin_no,
  gender,
  age,
  edu,
  job,
  child,
  created,
  email,
  hp_no,
  gunmul,
  jungdong,
  juso,
  lat,
  lon
)
select cust_id,
       cust_nm,
       '900101-1' || lpad(rn, 6, '0') jumin_no,
       case mod(rn, 2) when 0 then 'F' else 'M' end gender,
       35 + rn age,
       '대졸' edu,
       '직장인' job,
       mod(rn, 3) child,
       to_char(sysdate - 900, 'YYYYMMDD') created,
       'ai26ai.demo.' || cust_id || '@example.com' email,
       '010-9000-' || lpad(cust_id, 4, '0') hp_no,
       gunmul,
       jungdon,
       juso,
       lat,
       lon
from (
  select ad.cust_id,
         row_number() over (order by ad.cust_id) rn,
         'AI고객' || lpad(row_number() over (order by ad.cust_id), 2, '0') cust_nm,
         ad.gunmul,
         ad.jungdon,
         ad.juso,
         ad.lat,
         ad.lon
  from soe.address ad
  where rownum <= 8
) s
where not exists (
  select 1
  from soe.cust_info ci
  where ci.cust_id = s.cust_id
);

insert into soe.cancelamt (
  dt,
  cust_id,
  op_gubun,
  tot_amt,
  start_dt,
  cnt,
  call_dt,
  call_dt_ts,
  log_id,
  fund_code,
  fund_name,
  call_cnt_3m,
  late_pmt_cnt,
  consult_text
)
select to_char(sysdate, 'YYYYMMDD') dt,
       cust_id,
       '5' op_gubun,
       to_char(cancel_amt) tot_amt,
       to_char(sysdate, 'YYYYMMDDHH24MISS') start_dt,
       rn cnt,
       to_char(sysdate, 'YYYYMMDD') call_dt,
       to_char(systimestamp, 'YYYYMMDDHH24MISSFF3') call_dt_ts,
       'AI26AI' || lpad(rn, 5, '0') log_id,
       fund_code,
       fund_name,
       call_cnt_3m,
       late_pmt_cnt,
       consult_text
from (
  select ad.cust_id,
         row_number() over (order by ad.cust_id) rn,
         case mod(row_number() over (order by ad.cust_id), 4)
           when 0 then 315000000
           when 1 then 218000000
           when 2 then 146000000
           else 87000000
         end cancel_amt,
         case mod(row_number() over (order by ad.cust_id), 4)
           when 0 then 'FUNDA1'
           when 1 then 'FUNDA2'
           when 2 then 'FUNDA3'
           else 'FUNDA4'
         end fund_code,
         case mod(row_number() over (order by ad.cust_id), 4)
           when 0 then '혼합형펀드01'
           when 1 then '채권형펀드01'
           when 2 then '이머징펀드01'
           else '선진국펀드01'
         end fund_name,
         case mod(row_number() over (order by ad.cust_id), 4)
           when 0 then 12
           when 1 then 8
           when 2 then 5
           else 14
         end call_cnt_3m,
         case mod(row_number() over (order by ad.cust_id), 4)
           when 0 then 3
           when 1 then 2
           when 2 then 1
           else 4
         end late_pmt_cnt,
         case mod(row_number() over (order by ad.cust_id), 4)
           when 0 then '최근 시장 변동성이 커져서 해약을 고민하고 있습니다. 대체 방안이 있나요?'
           when 1 then '펀드 수익률이 낮아서 해약하고 싶습니다. 환급금과 손실 여부가 궁금합니다.'
           when 2 then '타사 상품으로 갈아타려고 합니다. 해약 시 불이익이 있나요?'
           else '일시적으로 자금이 필요해서 해약을 검토하고 있습니다. 중도인출도 가능한가요?'
         end consult_text
  from soe.address ad
  where rownum <= 8
);

commit;

declare
  v_cancel_rows number;
begin
  select count(*) into v_cancel_rows
  from soe.cancelamt
  where log_id like 'AI26AI%'
    and op_gubun = '5';

  dbms_output.put_line('AI demo cancel rows: ' || v_cancel_rows);

  if v_cancel_rows = 0 then
    raise_application_error(-20001, 'AI 26ai source event seed failed.');
  end if;
end;
/

commit;

exit
