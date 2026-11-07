set define off
set serveroutput on size unlimited

whenever sqlerror exit failure rollback

delete from soe.address a
where rowid not in (
  select min(rowid)
  from soe.address
  group by cust_id
);

merge into soe.address dst
using (
  with base_addr as (
    select 1 id,  '서울특별시 광진구 능동로 120' juso, '광진구' jungdon, '건국대학교' gunmul, 37.54118 lat, 127.08086 lon from dual union all
    select 2,     '서울특별시 용산구 한강대로 405', '용산구', '서울역', 37.53362, 126.98744 from dual union all
    select 3,     '서울특별시 금천구 벚꽃로 298', '금천구', '가산디지털단지', 37.46124, 126.89550 from dual union all
    select 4,     '서울특별시 은평구 은평로 195', '은평구', '은평구청', 37.61610, 126.92828 from dual union all
    select 5,     '서울특별시 도봉구 마들로 656', '도봉구', '도봉구청', 37.67014, 127.04386 from dual union all
    select 6,     '서울특별시 노원구 노해로 437', '노원구', '노원구청', 37.65854, 127.05734 from dual union all
    select 7,     '서울특별시 강서구 마곡중앙로 161', '강서구', '마곡나루', 37.55042, 126.84464 from dual union all
    select 8,     '서울특별시 강동구 성내로 25', '강동구', '강동구청', 37.52678, 127.12776 from dual union all
    select 9,     '서울특별시 동작구 상도로 320', '동작구', '상도역', 37.51674, 126.93948 from dual union all
    select 10,    '서울특별시 중구 세종대로 110', '중구', '서울시청', 37.56210, 127.00318 from dual union all
    select 11,    '서울특별시 서대문구 연세로 50', '서대문구', '신촌', 37.58210, 126.93500 from dual union all
    select 12,    '서울특별시 영등포구 의사당대로 1', '영등포구', '국회의사당', 37.53260, 126.91400 from dual union all
    select 13,    '서울특별시 송파구 올림픽로 300', '송파구', '잠실역', 37.51320, 127.10020 from dual union all
    select 14,    '서울특별시 강남구 테헤란로 152', '강남구', '강남역', 37.50070, 127.03650 from dual union all
    select 15,    '서울특별시 마포구 월드컵로 212', '마포구', '상암월드컵경기장', 37.56830, 126.89720 from dual union all
    select 16,    '서울특별시 성동구 왕십리로 222', '성동구', '한양대학교', 37.55720, 127.04510 from dual union all
    select 17,    '서울특별시 관악구 관악로 1', '관악구', '서울대학교', 37.45990, 126.95190 from dual union all
    select 18,    '서울특별시 양천구 목동동로 105', '양천구', '양천구청', 37.51690, 126.86650 from dual union all
    select 19,    '서울특별시 종로구 종로 1', '종로구', '광화문', 37.57030, 126.97690 from dual union all
    select 20,    '경기도 광명시 철산로 13', '광명시', '철산역', 37.47610, 126.86820 from dual
  ),
  cust_addr as (
    select n.cust_id,
           mod(n.cust_id - 1, 17) + 1 fp_id,
           b.jungdon,
           b.gunmul || ' ' || to_char(mod(n.cust_id - 1, 9) + 1) || '동' gunmul,
           b.juso || ' ' || to_char(mod(n.cust_id - 1, 9) + 1) || '동' juso,
           50 + mod(n.cust_id * 37, 950) cnt,
           round(b.lat + ((mod(n.cust_id, 11) - 5) * 0.00075), 6) lat,
           round(b.lon + ((mod(n.cust_id, 13) - 6) * 0.00072), 6) lon
    from (
      select level cust_id
      from dual
      connect by level <= 1000
    ) n
    join base_addr b
      on b.id = mod(n.cust_id - 1, 20) + 1
  )
  select cust_id,
         fp_id,
         '아파트' category,
         gunmul,
         jungdon,
         juso,
         cnt,
         lat,
         lon
  from cust_addr
) src
on (dst.cust_id = src.cust_id)
when matched then update set
  dst.fp_id = src.fp_id,
  dst.category = src.category,
  dst.gunmul = src.gunmul,
  dst.jungdon = src.jungdon,
  dst.juso = src.juso,
  dst.cnt = src.cnt,
  dst.lat = src.lat,
  dst.lon = src.lon
when not matched then insert (
  cust_id,
  fp_id,
  category,
  gunmul,
  jungdon,
  juso,
  cnt,
  lat,
  lon
) values (
  src.cust_id,
  src.fp_id,
  src.category,
  src.gunmul,
  src.jungdon,
  src.juso,
  src.cnt,
  src.lat,
  src.lon
);

commit;

declare
  v_total number;
  v_dup number;
begin
  select count(*) into v_total from soe.address;
  select count(*)
  into v_dup
  from (
    select cust_id
    from soe.address
    group by cust_id
    having count(*) > 1
  );

  dbms_output.put_line('seed_osa_address.sql: address rows=' || v_total || ', duplicate cust_id=' || v_dup);

  if v_dup > 0 then
    raise_application_error(-20001, 'SOE.ADDRESS has duplicate CUST_ID rows after seed.');
  end if;
end;
/

exit;
