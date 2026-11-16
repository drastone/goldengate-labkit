set define off
set serveroutput on
whenever sqlerror exit sql.sqlcode rollback
alter session set container=ORCLPDB1;

-- Target-only DS Group Insurance Information System 2.0 objects (App 340).
-- Business objects belong to SOE; GGADMIN remains the APEX parsing schema.
create table if not exists soe.ins2_product (
  product_code varchar2(20) primary key, product_name varchar2(120), category varchar2(40),
  channel varchar2(30), monthly_premium number, coverage_amount number, status varchar2(20), launch_date date
);
create table if not exists soe.ins2_customer (
  customer_id varchar2(20) primary key, customer_name varchar2(80), gender varchar2(10), birth_date date,
  region varchar2(40), occupation varchar2(60), customer_grade varchar2(10), join_date date, consent_status varchar2(20)
);
create table if not exists soe.ins2_policy (
  policy_no varchar2(30) primary key, customer_id varchar2(20), product_code varchar2(20),
  policy_status varchar2(20), contract_date date, maturity_date date, monthly_premium number,
  coverage_amount number, payment_method varchar2(30), sales_channel varchar2(30), persistency_month number
);
create table if not exists soe.ins2_payment (
  payment_id number primary key, payment_time timestamp, policy_no varchar2(30), customer_id varchar2(20),
  payment_month varchar2(6), premium_amount number, payment_status varchar2(20), payment_method varchar2(30), delay_days number
);
create table if not exists soe.ins2_claim (
  claim_no varchar2(30) primary key, claim_time timestamp, policy_no varchar2(30), customer_id varchar2(20),
  claim_type varchar2(40), claimed_amount number, approved_amount number, claim_status varchar2(20),
  fraud_score number(5,2), hospital_name varchar2(100), adjuster_name varchar2(60)
);
create table if not exists soe.ins2_risk_signal (
  signal_id number primary key, detected_at timestamp, customer_id varchar2(20), policy_no varchar2(30),
  signal_type varchar2(50), risk_level varchar2(20), risk_score number(5,2), expected_loss number,
  action_status varchar2(20), description varchar2(200)
);

delete from soe.ins2_risk_signal;
delete from soe.ins2_claim;
delete from soe.ins2_payment;
delete from soe.ins2_policy;
delete from soe.ins2_customer;
delete from soe.ins2_product;

insert all
 into soe.ins2_product values ('LIFE-100','DS 평생안심 종신보험','종신보험','FC',128000,200000000,'판매중',sysdate-720)
 into soe.ins2_product values ('HEALTH-210','DS 100세 건강플러스','건강보험','GA',89000,100000000,'판매중',sysdate-540)
 into soe.ins2_product values ('CANCER-330','DS 스마트 암케어','암보험','다이렉트',63000,80000000,'판매중',sysdate-420)
 into soe.ins2_product values ('PENSION-410','DS 미래연금 플랜','연금보험','방카',250000,0,'판매중',sysdate-360)
 into soe.ins2_product values ('DRIVER-520','DS 안전운전 생활보험','운전자보험','다이렉트',27000,50000000,'판매중',sysdate-240)
 into soe.ins2_product values ('CHILD-610','DS 우리아이 성장보험','어린이보험','GA',74000,120000000,'판매중',sysdate-180)
select 1 from dual;

insert all
 into soe.ins2_customer values ('C-10001','김서준','남',date '1982-03-12','서울','IT 엔지니어','VIP',sysdate-1200,'동의')
 into soe.ins2_customer values ('C-10002','이서연','여',date '1988-07-21','경기','교사','A',sysdate-980,'동의')
 into soe.ins2_customer values ('C-10003','박도윤','남',date '1975-11-04','부산','자영업','B',sysdate-870,'동의')
 into soe.ins2_customer values ('C-10004','최지우','여',date '1993-01-18','인천','연구원','A',sysdate-650,'동의')
 into soe.ins2_customer values ('C-10005','정민준','남',date '1968-05-30','대전','회사원','VIP',sysdate-1420,'동의')
 into soe.ins2_customer values ('C-10006','한수빈','여',date '1990-09-09','광주','디자이너','B',sysdate-510,'동의')
 into soe.ins2_customer values ('C-10007','오현우','남',date '1985-12-14','대구','물류관리','A',sysdate-430,'동의')
 into soe.ins2_customer values ('C-10008','윤하은','여',date '1979-04-25','서울','의료인','VIP',sysdate-1100,'동의')
select 1 from dual;

insert all
 into soe.ins2_policy values ('P-260001','C-10001','LIFE-100','정상',sysdate-900,add_months(sysdate,240),128000,200000000,'자동이체','FC',30)
 into soe.ins2_policy values ('P-260002','C-10002','HEALTH-210','정상',sysdate-720,add_months(sysdate,180),89000,100000000,'카드','GA',24)
 into soe.ins2_policy values ('P-260003','C-10003','CANCER-330','납입유예',sysdate-560,add_months(sysdate,120),63000,80000000,'자동이체','다이렉트',18)
 into soe.ins2_policy values ('P-260004','C-10004','PENSION-410','정상',sysdate-420,add_months(sysdate,240),250000,0,'자동이체','방카',14)
 into soe.ins2_policy values ('P-260005','C-10005','HEALTH-210','정상',sysdate-1100,add_months(sysdate,120),94000,120000000,'자동이체','GA',36)
 into soe.ins2_policy values ('P-260006','C-10006','CHILD-610','정상',sysdate-330,add_months(sysdate,180),74000,120000000,'카드','GA',11)
 into soe.ins2_policy values ('P-260007','C-10007','DRIVER-520','실효위험',sysdate-250,add_months(sysdate,60),27000,50000000,'가상계좌','다이렉트',8)
 into soe.ins2_policy values ('P-260008','C-10008','LIFE-100','정상',sysdate-980,add_months(sysdate,240),138000,250000000,'자동이체','FC',32)
 into soe.ins2_policy values ('P-260009','C-10001','CANCER-330','정상',sysdate-300,add_months(sysdate,120),69000,100000000,'카드','다이렉트',10)
 into soe.ins2_policy values ('P-260010','C-10002','DRIVER-520','해지검토',sysdate-190,add_months(sysdate,60),29000,50000000,'자동이체','다이렉트',6)
select 1 from dual;

insert into soe.ins2_payment
select level, systimestamp-numtodsinterval(level*9,'MINUTE'), 'P-2600'||lpad(mod(level,10)+1,2,'0'),
       'C-1000'||to_char(mod(level,8)+1), to_char(add_months(sysdate,-mod(level,6)),'YYYYMM'),
       case mod(level,6) when 0 then 128000 when 1 then 89000 when 2 then 63000 when 3 then 250000 when 4 then 94000 else 74000 end,
       case when mod(level,9)=0 then '연체' when mod(level,13)=0 then '미납' else '납입완료' end,
       case mod(level,3) when 0 then '자동이체' when 1 then '카드' else '가상계좌' end,
       case when mod(level,9)=0 then mod(level,12)+1 else 0 end
from dual connect by level<=36;

insert all
 into soe.ins2_claim values ('CL-260701',systimestamp-numtodsinterval(18,'MINUTE'),'P-260002','C-10002','입원',3200000,2800000,'심사중',18.4,'DS서울병원','심사자A')
 into soe.ins2_claim values ('CL-260702',systimestamp-numtodsinterval(42,'MINUTE'),'P-260005','C-10005','수술',12500000,12000000,'지급승인',12.1,'DS대전병원','심사자B')
 into soe.ins2_claim values ('CL-260703',systimestamp-numtodsinterval(75,'MINUTE'),'P-260003','C-10003','암진단',50000000,0,'조사중',82.7,'부산메디컬','심사자C')
 into soe.ins2_claim values ('CL-260704',systimestamp-numtodsinterval(130,'MINUTE'),'P-260006','C-10006','통원',480000,420000,'지급완료',8.5,'광주아동병원','심사자A')
 into soe.ins2_claim values ('CL-260705',systimestamp-numtodsinterval(210,'MINUTE'),'P-260009','C-10001','검사',920000,750000,'지급완료',24.2,'DS서울병원','심사자D')
 into soe.ins2_claim values ('CL-260706',systimestamp-numtodsinterval(360,'MINUTE'),'P-260008','C-10008','입원',6800000,0,'서류보완',45.8,'서울중앙의료원','심사자B')
select 1 from dual;

insert all
 into soe.ins2_risk_signal values (1,systimestamp-numtodsinterval(12,'MINUTE'),'C-10007','P-260007','보험료 연체','HIGH',88.5,3200000,'상담배정','최근 3회 연체 및 자동이체 실패')
 into soe.ins2_risk_signal values (2,systimestamp-numtodsinterval(35,'MINUTE'),'C-10003','P-260003','이상 청구','HIGH',82.7,50000000,'조사중','단기간 고액 청구 패턴')
 into soe.ins2_risk_signal values (3,systimestamp-numtodsinterval(68,'MINUTE'),'C-10002','P-260010','해지 징후','MEDIUM',71.4,1800000,'콜백예정','콜센터 해지 문의 2회')
 into soe.ins2_risk_signal values (4,systimestamp-numtodsinterval(115,'MINUTE'),'C-10008','P-260008','청구 집중','MEDIUM',64.9,6800000,'모니터링','동일 병원 청구 빈도 증가')
 into soe.ins2_risk_signal values (5,systimestamp-numtodsinterval(190,'MINUTE'),'C-10006','P-260006','납입 수단 오류','LOW',42.5,740000,'완료','카드 만료 정보 갱신 완료')
 into soe.ins2_risk_signal values (6,systimestamp-numtodsinterval(280,'MINUTE'),'C-10001','P-260009','보장 중복','LOW',38.2,900000,'안내완료','유사 암보장 계약 중복 안내')
select 1 from dual;

commit;

grant select on soe.ins2_product to ggadmin;
grant select on soe.ins2_customer to ggadmin;
grant select on soe.ins2_policy to ggadmin;
grant select on soe.ins2_payment to ggadmin;
grant select on soe.ins2_claim to ggadmin;
grant select on soe.ins2_risk_signal to ggadmin;

declare
  procedure set_page(p_page number,p_name varchar2) is
  begin update apex_260100.wwv_flow_steps set name=p_name,step_title=p_name,last_updated_by='CODEX',last_updated_on=sysdate where flow_id=340 and id=p_page; end;
  procedure set_region(p_page number,p_seq number,p_type varchar2,p_name varchar2,p_source clob default null) is
  begin update apex_260100.wwv_flow_page_plugs set plug_name=p_name,title=p_name,plug_source=case when p_source is null then plug_source else p_source end,last_updated_by='CODEX',last_updated_on=sysdate where flow_id=340 and page_id=p_page and plug_display_sequence=p_seq and (p_type is null or plug_source_type=p_type); end;
  procedure set_menu(p_seq number,p_text varchar2,p_icon varchar2) is
  begin update apex_260100.wwv_flow_list_items set list_item_link_text=p_text,list_item_icon=p_icon,last_updated_by='CODEX',last_updated_on=sysdate where flow_id=340 and list_item_display_sequence=p_seq and list_id=(select navigation_list_id from apex_260100.wwv_flows where id=340); end;
  procedure set_chart(p_page number,p_seq number,p_name varchar2,p_sql clob) is
  begin update apex_260100.wwv_flow_jet_chart_series set name=p_name,data_source=p_sql,updated_by='CODEX',updated_on=sysdate where flow_id=340 and page_id=p_page and seq=p_seq; end;
  procedure repair_theme is
    l_offset number;
  begin
    select import_id_offset into l_offset from apex_260100.wwv_flows where id=340;
    update apex_260100.wwv_flows f set
      (theme_id,default_page_template,printer_friendly_template,default_region_template,default_label_template,
       default_report_template,default_list_template,default_menu_template,default_button_template,error_template,
       default_chart_template,default_reportr_template,default_form_template,default_wizard_template,
       default_menur_template,default_listr_template,default_irr_template,navigation_list_template_id,nav_bar_list_template_id)=
      (select theme_id,default_page_template,printer_friendly_template,default_region_template,default_label_template,
       default_report_template,default_list_template,default_menu_template,default_button_template,error_template,
       default_chart_template,default_reportr_template,default_form_template,default_wizard_template,
       default_menur_template,default_listr_template,default_irr_template,navigation_list_template_id,nav_bar_list_template_id
       from apex_260100.wwv_flows where id=300) where f.id=340;
    update apex_260100.wwv_flow_themes t set
      (default_page_template,default_dialog_template,error_template,printer_friendly_template,login_template,
       default_button_template,default_region_template,default_chart_template,default_form_template,
       default_reportr_template,default_wizard_template,default_menur_template,default_listr_template,
       default_irr_template,default_report_template,default_label_template,default_menu_template,
       default_list_template,default_top_nav_list_template,default_side_nav_list_template,
       default_dialogbtnr_template,default_dialogr_template,default_option_label,default_required_label,
       default_nav_bar_list_template)=
      (select default_page_template,default_dialog_template,error_template,printer_friendly_template,login_template,
       default_button_template,default_region_template,default_chart_template,default_form_template,
       default_reportr_template,default_wizard_template,default_menur_template,default_listr_template,
       default_irr_template,default_report_template,default_label_template,default_menu_template,
       default_list_template,default_top_nav_list_template,default_side_nav_list_template,
       default_dialogbtnr_template,default_dialogr_template,default_option_label,default_required_label,
       default_nav_bar_list_template from apex_260100.wwv_flow_themes where flow_id=300 and theme_id=42)
      where t.flow_id=340 and t.theme_id=42;
    update apex_260100.wwv_flow_steps s set step_template=step_template-l_offset where flow_id=340 and step_template is not null and exists(select 1 from apex_260100.wwv_flow_templates x where x.id=s.step_template-l_offset);
    update apex_260100.wwv_flow_page_plugs p set plug_template=plug_template-l_offset where flow_id=340 and plug_template is not null and exists(select 1 from apex_260100.wwv_flow_page_plug_templates x where x.id=p.plug_template-l_offset);
    update apex_260100.wwv_flow_page_plugs p set menu_template_id=menu_template_id-l_offset where flow_id=340 and menu_template_id is not null and exists(select 1 from apex_260100.wwv_flow_menu_templates x where x.id=p.menu_template_id-l_offset);
    update apex_260100.wwv_flow_step_buttons b set button_template_id=button_template_id-l_offset where flow_id=340 and button_template_id is not null and exists(select 1 from apex_260100.wwv_flow_button_templates x where x.id=b.button_template_id-l_offset);
    update apex_260100.wwv_flow_step_items i set field_template=field_template-l_offset where flow_id=340 and field_template is not null and exists(select 1 from apex_260100.wwv_flow_field_templates x where x.id=i.field_template-l_offset);
  end;
begin
  update apex_260100.wwv_flows set name='DS그룹 보험 정보계 2.0',alias='DS-INSURANCE-360',logo_text='DS Insurance Intelligence',last_updated_by='CODEX',last_updated_on=sysdate where id=340;
  set_page(1,'보험 경영 대시보드'); set_page(10,'계약·고객 360'); set_page(20,'보험료·납입 현황');
  set_page(30,'사고·보험금 청구'); set_page(40,'유지율·해지위험'); set_page(50,'상품 포트폴리오');
  set_menu(10,'경영 대시보드','fa-dashboard'); set_menu(20,'계약·고객 360','fa-users');
  set_menu(30,'보험료·납입','fa-credit-card'); set_menu(40,'보험금 청구','fa-medkit');
  set_menu(50,'유지율·해지위험','fa-warning'); set_menu(60,'상품 포트폴리오','fa-briefcase');

  set_region(1,10,'NATIVE_SQL_REPORT','보험 핵심 KPI',q'~select '보유 계약' label,to_char(count(*)) value,'fa-file-text-o' icon,'u-color-24' color from soe.ins2_policy where policy_status<>'해지' union all select '고객 수',to_char(count(*)),'fa-users','u-color-3' from soe.ins2_customer union all select '월 보험료',to_char(sum(monthly_premium),'FM999,999,999')||'원','fa-won','u-color-14' from soe.ins2_policy where policy_status in ('정상','납입유예','실효위험') union all select '심사중 청구',to_char(sum(case when claim_status in ('심사중','조사중','서류보완') then 1 else 0 end)),'fa-medkit','u-color-1' from soe.ins2_claim union all select '승인 보험금',to_char(sum(approved_amount),'FM999,999,999')||'원','fa-check-circle','u-color-21' from soe.ins2_claim union all select 'HIGH 리스크',to_char(sum(case when risk_level='HIGH' and action_status<>'완료' then 1 else 0 end)),'fa-warning','u-color-2' from soe.ins2_risk_signal~');
  set_region(1,20,'NATIVE_JET_CHART','최근 14일 납입·청구 추이');
  set_region(1,30,'NATIVE_SQL_REPORT','최근 실시간 보험 이벤트',q'~select to_char(claim_time,'YYYY-MM-DD') "날짜",claim_no "고객명",claim_type||' / '||claim_status "거래유형",to_char(claimed_amount,'FM999,999,999') "거래금액(원)",hospital_name "펀드명",to_char(claim_time,'HH24:MI:SS') "처리시각" from soe.ins2_claim order by claim_time desc fetch first 20 rows only~');
  set_chart(1,10,'보험료 납입',q'~select to_char(trunc(sysdate)-level+1,'MM-DD') dt,20+mod(level*7,18) cnt from dual connect by level<=14 order by dt~');
  set_chart(1,20,'보험금 청구',q'~select to_char(trunc(sysdate)-level+1,'MM-DD') dt,2+mod(level*3,8) cnt from dual connect by level<=14 order by dt~');

  set_region(10,10,'NATIVE_JET_CHART','성별·연령대 고객 분포');
  set_region(10,20,'NATIVE_IR','계약·고객 360 목록',q'~select p.policy_no "계약번호",c.customer_id "고객ID",c.customer_name "고객명",c.gender "성별",trunc(months_between(sysdate,c.birth_date)/12) "나이",c.region "지역",c.customer_grade "고객등급",pr.product_name "상품명",p.policy_status "계약상태",p.monthly_premium "월보험료",p.coverage_amount "보장금액",p.persistency_month "유지개월",p.contract_date "계약일" from soe.ins2_policy p join soe.ins2_customer c on c.customer_id=p.customer_id join soe.ins2_product pr on pr.product_code=p.product_code order by p.contract_date desc~');
  set_chart(10,10,'남성',q'~select case when age<30 then '20대' when age<40 then '30대' when age<50 then '40대' when age<60 then '50대' else '60대이상' end age_group,count(*) cnt from (select gender,trunc(months_between(sysdate,birth_date)/12) age from soe.ins2_customer) where gender='남' group by case when age<30 then '20대' when age<40 then '30대' when age<50 then '40대' when age<60 then '50대' else '60대이상' end~');
  set_chart(10,20,'여성',q'~select case when age<30 then '20대' when age<40 then '30대' when age<50 then '40대' when age<60 then '50대' else '60대이상' end age_group,count(*) cnt from (select gender,trunc(months_between(sysdate,birth_date)/12) age from soe.ins2_customer) where gender='여' group by case when age<30 then '20대' when age<40 then '30대' when age<50 then '40대' when age<60 then '50대' else '60대이상' end~');

  set_region(20,10,'NATIVE_JET_CHART','납입 상태 분포');
  set_region(20,20,'NATIVE_IR','보험료 납입 상세',q'~select payment_time "처리시각",payment_id "납입ID",policy_no "계약번호",customer_id "고객ID",payment_month "납입월",premium_amount "보험료(원)",payment_status "납입상태",payment_method "납입방법",delay_days "연체일수" from soe.ins2_payment order by payment_time desc~');
  set_chart(20,10,'납입 건수',q'~select payment_status op_name,count(*) cnt from soe.ins2_payment group by payment_status order by cnt desc~');

  set_region(30,10,'NATIVE_JET_CHART','청구 유형별 금액');
  set_region(30,20,'NATIVE_IR','보험금 청구 상세',q'~select claim_time "접수시각",claim_no "청구번호",policy_no "계약번호",customer_id "고객ID",claim_type "청구유형",claimed_amount "청구금액(원)",approved_amount "승인금액(원)",claim_status "처리상태",fraud_score "이상점수",hospital_name "병원",adjuster_name "담당심사자" from soe.ins2_claim order by claim_time desc~');
  set_chart(30,10,'청구금액',q'~select claim_type fund_name,sum(claimed_amount) tot_amt from soe.ins2_claim group by claim_type order by tot_amt desc~');

  set_region(40,10,'NATIVE_SQL_REPORT','유지·리스크 요약',q'~select '실효·해지위험 계약' label,to_char(sum(case when policy_status in ('실효위험','해지검토') then 1 else 0 end)) value,'fa-warning' icon,'u-color-1' color from soe.ins2_policy union all select '미조치 리스크',to_char(sum(case when action_status not in ('완료','안내완료') then 1 else 0 end)),'fa-exclamation-triangle','u-color-2' from soe.ins2_risk_signal union all select '예상 손실액',to_char(sum(expected_loss),'FM999,999,999')||'원','fa-won','u-color-3' from soe.ins2_risk_signal union all select '평균 위험점수',to_char(round(avg(risk_score),1),'FM990.0'),'fa-line-chart','u-color-4' from soe.ins2_risk_signal~');
  set_region(40,20,'NATIVE_JET_CHART','시간대별 리스크 신호');
  set_region(40,30,'NATIVE_IR','고객·계약 위험신호',q'~select detected_at "탐지시각",signal_id "신호ID",customer_id "고객ID",policy_no "계약번호",signal_type "신호유형",risk_level "위험등급",risk_score "위험점수",expected_loss "예상손실(원)",action_status "조치상태",description "내용" from soe.ins2_risk_signal order by detected_at desc~');
  set_chart(40,10,'위험 신호',q'~select to_char(detected_at,'MM-DD HH24') ym,count(*) cnt from soe.ins2_risk_signal group by to_char(detected_at,'MM-DD HH24') order by ym~');

  set_region(50,10,'NATIVE_JET_CHART','상품 카테고리 분포');
  set_region(50,20,'NATIVE_IR','보험 상품 포트폴리오',q'~select category "카테고리",product_code "상품코드",product_name "상품명",channel "주력채널",monthly_premium "기준보험료(원)",coverage_amount "기준보장금액(원)",status "상태",launch_date "출시일" from soe.ins2_product order by category,product_code~');
  set_chart(50,10,'상품 수',q'~select category,count(*) cnt from soe.ins2_product group by category order by cnt desc~');
  set_region(9999,10,'NATIVE_STATIC','DS그룹 보험 정보계 2.0');

  update apex_260100.wwv_flow_region_report_column c set column_heading=case column_alias when '날짜' then '이벤트일' when '고객명' then '청구번호' when '거래유형' then '청구유형/상태' when '거래금액(원)' then '청구금액(원)' when '펀드명' then '병원' when '처리시각' then '접수시각' else column_heading end,last_updated_by='CODEX',last_updated_on=sysdate where flow_id=340 and exists(select 1 from apex_260100.wwv_flow_page_plugs p where p.id=c.region_id and p.page_id=1);
  begin
    repair_theme;
  exception
    when others then
      dbms_output.put_line('WARN: repair_theme skipped: ' || sqlerrm);
  end;
  commit;
end;
/

prompt Insurance Information System 2.0 installed as App 340.
