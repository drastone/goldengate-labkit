set define off
set serveroutput on
whenever sqlerror exit sql.sqlcode rollback
alter session set container=ORCLPDB1;

grant select on soe.address to ggadmin;
grant select on soe.cust_pr to ggadmin;
grant select on soe.cancelamt to ggadmin;
grant select on soe.call_center_log to ggadmin;
grant select on soe.cust_info to ggadmin;

--------------------------------------------------------------------------------
-- Target SOE - FP care coaching extension for App 340 Page 70.
-- GGADMIN receives only the privileges required by the APEX parsing schema.
--------------------------------------------------------------------------------

create or replace function soe.ins2_churn_work_type(
  p_consult_text  varchar2,
  p_keyword_score number,
  p_churn_score   number,
  p_cancel_amt    varchar2
) return varchar2 deterministic authid definer is
  l_text varchar2(4000) := lower(nvl(p_consult_text, ''));
begin
  if p_cancel_amt is not null then
    return '해약고객 긴급접촉';
  elsif instr(l_text, '해지 절차') > 0
     or instr(l_text, '해약') > 0
     or instr(l_text, '해지환급금') > 0
     or instr(l_text, '해약 환급금') > 0
     or instr(l_text, '갈아타') > 0
     or instr(l_text, '계약 정리') > 0
     or nvl(p_keyword_score, 0) >= 75
     or nvl(p_churn_score, 0) >= 70 then
    return '해약가망 선제케어';
  else
    return '관찰고객 안부케어';
  end if;
end;
/

create or replace function soe.ins2_churn_contact_priority(
  p_work_type   varchar2,
  p_churn_score number
) return varchar2 deterministic authid definer is
begin
  if p_work_type = '해약고객 긴급접촉' then
    return case when nvl(p_churn_score, 0) >= 90 then '오늘 즉시' else '24시간 이내' end;
  elsif p_work_type = '해약가망 선제케어' then
    return '3영업일 이내';
  else
    return '7영업일 이내';
  end if;
end;
/

create or replace function soe.ins2_churn_response_strategy(
  p_churn_reason varchar2,
  p_work_type    varchar2
) return varchar2 deterministic authid definer is
begin
  return case p_churn_reason
    when '보험료·수익률 불만' then
      '환급 손실과 보장 공백을 먼저 설명하고, 감액완납·납입유예·펀드 변경안을 숫자로 비교 제시'
    when '타사 이동 검토' then
      '타사 전환 시 면책기간, 재가입 제한, 기존 계약 예정이율과 보장 차이를 비교해 유지 가치를 설명'
    when '경제적 어려움' then
      '보험료 출금일 변경, 납입유예, 특약 조정, 감액완납 순서로 부담 완화안을 제안'
    when '상담·서비스 불만' then
      '첫 문장에 사과와 재발 방지를 약속하고, 담당 FP가 단일 창구로 처리 경과를 직접 공유'
    when '보험금 청구 불만' then
      '청구 지연 사유, 보완 서류, 예상 처리일을 확인해 안내하고 추가 담보 가능성을 재검토'
    when '디지털 이용 불편' then
      '앱·인증·모바일 청구는 원격 지원 또는 방문 지원을 제안하고 다음 처리까지 동행'
    else
      case when p_work_type = '해약고객 긴급접촉'
           then '해지 의사 배경을 먼저 확인하고, 손실·대안·처리기한을 한 번에 정리'
           else '최근 문의 불편을 확인하고 계약 유지 가치와 보장 공백 리스크를 자연스럽게 리마인드'
      end
  end;
end;
/

create or replace function soe.ins2_churn_fp_comment(
  p_work_type        varchar2,
  p_contact_priority varchar2,
  p_customer_name    varchar2,
  p_source_cust_id   number,
  p_assigned_fp_id   number,
  p_churn_score      number,
  p_churn_reason     varchar2,
  p_customer_profile varchar2,
  p_contract_summary varchar2,
  p_cancel_summary   varchar2,
  p_consult_text     varchar2,
  p_action_memo      varchar2
) return varchar2 deterministic authid definer is
  l_name varchar2(120) := coalesce(p_customer_name, '고객ID ' || to_char(p_source_cust_id));
  l_strategy varchar2(1000) := soe.ins2_churn_response_strategy(p_churn_reason, p_work_type);
  l_intro varchar2(1000);
  l_next varchar2(1000);
begin
  if p_work_type = '해약고객 긴급접촉' then
    l_intro := '안녕하세요, ' || l_name || ' 고객님. 담당 FP ' || nvl(to_char(p_assigned_fp_id), '-') ||
               '입니다. 최근 해지/환급 관련 문의 내용을 확인하고 연락드렸습니다. 처리 전에 손실과 대안을 먼저 짧게 점검드리고 싶습니다.';
    l_next := '실행: 오늘 1차 전화 → 미응답 시 문자 → 다음 영업일 방문/화상 상담 제안. 통화 후 해지 보류 여부와 대안 선택지를 케어 상태에 기록.';
  elsif p_work_type = '해약가망 선제케어' then
    l_intro := '안녕하세요, ' || l_name || ' 고객님. 담당 FP ' || nvl(to_char(p_assigned_fp_id), '-') ||
               '입니다. 최근 문의 내용을 보고 불편이나 부담이 생기기 전에 점검 연락드렸습니다.';
    l_next := '실행: 3영업일 내 안부콜 → 보장/보험료/청구 불편 확인 → 필요 시 리밸런싱 또는 납입 조정 상담 예약.';
  else
    l_intro := '안녕하세요, ' || l_name || ' 고객님. 최근 문의하신 내용이 잘 처리됐는지 확인차 연락드렸습니다.';
    l_next := '실행: 7영업일 내 안부콜 후 불편사항이 있으면 담당 FP 후속 상담으로 전환.';
  end if;

  return substr(
    '[업무유형] ' || p_work_type || ' / 우선순위 ' || p_contact_priority || chr(10) ||
    '[고객요약] ' || nvl(p_customer_profile, '고객 기본정보 미확인') || chr(10) ||
    '[계약요약] ' || nvl(p_contract_summary, '계약 요약 미확인') || chr(10) ||
    case when p_cancel_summary is not null then '[해약정보] ' || p_cancel_summary || chr(10) end ||
    '[최근상담] ' || substr(nvl(p_consult_text, '-'), 1, 650) || chr(10) ||
    '[추천멘트] ' || l_intro || chr(10) ||
    '[대응포인트] 위험점수 ' || to_char(round(nvl(p_churn_score, 0), 1)) || '점, 주요 사유는 ' ||
      nvl(p_churn_reason, '일반 문의') || '입니다. ' || l_strategy || chr(10) ||
    '[권장액션] ' || nvl(p_action_memo, '-') || chr(10) ||
    '[다음단계] ' || l_next,
    1,
    3900
  );
end;
/

create or replace view soe.ins2_churn_fp_assignment_v as
select cust_id,
       max(fp_id) assigned_fp_id,
       'SOE.ADDRESS' assignment_source
  from soe.address
 group by cust_id;

create or replace view soe.ins2_churn_customer_profile_v as
with contract_ranked as (
  select p.*,
         row_number() over (partition by p.cust_id order by nvl(p.amt,0) desc, p.stock_no) rn
    from soe.cust_pr p
),
contract_summary as (
  select cust_id,
         count(*) policy_count,
         sum(nvl(amt,0)) total_amt,
         max(nvl(overdue,0)) max_overdue,
         max(case when rn = 1 then product end) main_product,
         listagg(case when rn <= 3 then product end, ' / ' on overflow truncate '...') within group (order by rn) product_list
    from contract_ranked
   group by cust_id
),
cancel_summary as (
  select cust_id,
         max(tot_amt) keep (dense_rank last order by dt, start_dt) cancel_amt,
         max(start_dt) cancel_start_dt,
         max(cnt) cancel_count
    from soe.cancelamt
   group by cust_id
)
select l.cust_id source_cust_id,
       c.cust_nm customer_name,
       c.gender,
       c.age,
       c.job,
       c.child,
       c.hp_no,
       c.juso,
       coalesce(f.assigned_fp_id, 1 + mod(l.cust_id, 10)) assigned_fp_id,
       case when f.assigned_fp_id is not null then f.assignment_source else 'RULE_FALLBACK' end assignment_source,
       cs.policy_count,
       cs.total_amt,
       cs.max_overdue,
       cs.main_product,
       cs.product_list,
       ca.cancel_amt,
       ca.cancel_start_dt,
       ca.cancel_count,
       trim(
         coalesce(c.cust_nm || ' 고객', '고객ID ' || to_char(l.cust_id)) ||
         case when c.age is not null then ', ' || c.age || '세' end ||
         case when c.job is not null then ', 직업 ' || c.job end ||
         case when c.child is not null then ', 자녀 ' || c.child || '명' end ||
         case when c.juso is not null then ', 거주지 ' || substr(c.juso, 1, 40) end
       ) customer_profile,
       trim(
         '계약 ' || nvl(to_char(cs.policy_count), '0') || '건' ||
         case when cs.main_product is not null then ', 대표상품 ' || cs.main_product end ||
         case when cs.total_amt is not null then ', 총 계약금액 ' || to_char(cs.total_amt, 'FM999,999,999,999') || '원' end ||
         case when nvl(cs.max_overdue,0) > 0 then ', 최대 연체 ' || cs.max_overdue || '회' else ', 연체 없음' end
       ) contract_summary,
       case when ca.cancel_amt is not null then
         '기존 해약/환급 테이블 기준 예상금액 ' || ca.cancel_amt || '원, 관련 이력 ' || nvl(to_char(ca.cancel_count), '0') || '건'
       end cancel_summary
  from (select distinct cust_id from soe.call_center_log) l
  left join soe.cust_info c on c.cust_id = l.cust_id
  left join soe.ins2_churn_fp_assignment_v f on f.cust_id = l.cust_id
  left join contract_summary cs on cs.cust_id = l.cust_id
  left join cancel_summary ca on ca.cust_id = l.cust_id;

create or replace view soe.ins2_churn_log_score_v as
select c.log_id,
       c.source_cust_id,
       c.event_time,
       c.work_dt,
       c.fund_code,
       c.fund_name,
       c.call_cnt_3m,
       c.late_pmt_cnt,
       c.consult_text,
       c.vector_status,
       m.seed_code,
       coalesce(m.churn_reason, soe.ins2_churn_vector_pkg.keyword_reason(c.consult_text)) churn_reason,
       m.vector_distance,
       case
         when m.vector_distance is not null then round(100 / (1 + m.vector_distance), 1)
       end vector_similarity_score,
       soe.ins2_churn_vector_pkg.keyword_score(c.consult_text, c.call_cnt_3m, c.late_pmt_cnt) keyword_score,
       least(
         100,
         round(
           greatest(
             soe.ins2_churn_vector_pkg.keyword_score(c.consult_text, c.call_cnt_3m, c.late_pmt_cnt),
             nvl(100 / (1 + m.vector_distance), 0) * 0.75
             + soe.ins2_churn_vector_pkg.keyword_score(c.consult_text, c.call_cnt_3m, c.late_pmt_cnt) * 0.25
           ),
           1
         )
       ) churn_score,
       soe.ins2_churn_vector_pkg.risk_band(
         least(
           100,
           round(
             greatest(
               soe.ins2_churn_vector_pkg.keyword_score(c.consult_text, c.call_cnt_3m, c.late_pmt_cnt),
               nvl(100 / (1 + m.vector_distance), 0) * 0.75
               + soe.ins2_churn_vector_pkg.keyword_score(c.consult_text, c.call_cnt_3m, c.late_pmt_cnt) * 0.25
             ),
             1
           )
         )
       ) risk_band,
       coalesce(m.recommended_action,
                soe.ins2_churn_vector_pkg.suggested_action(
                  soe.ins2_churn_vector_pkg.keyword_reason(c.consult_text)
                )) suggested_care_action,
       p.assigned_fp_id suggested_fp_id
  from soe.ins2_churn_call_vector c
  left join soe.ins2_churn_seed_match_v m
    on m.log_id = c.log_id
  left join soe.ins2_churn_customer_profile_v p
    on p.source_cust_id = c.source_cust_id;

create or replace view soe.ins2_churn_action_queue_v as
with latest_care as (
  select care_id,
         source_cust_id,
         log_id,
         assigned_fp_id,
         care_status,
         due_date,
         campaign_name,
         action_memo,
         row_number() over (
           partition by source_cust_id
           order by nvl(updated_at, created_at) desc, care_id desc
         ) rn
    from soe.ins2_churn_fp_care
),
base as (
  select c.source_cust_id,
         c.log_id,
         c.event_time,
         c.fund_name,
         c.churn_score,
         c.risk_band,
         c.churn_reason,
         c.vector_distance,
         c.keyword_score,
         c.call_cnt_3m,
         c.late_pmt_cnt,
         c.consult_text,
         coalesce(l.assigned_fp_id, c.suggested_fp_id, p.assigned_fp_id) assigned_fp_id,
         coalesce(l.care_status, '대상선정') care_status,
         coalesce(l.campaign_name, '해약 방어 케어') campaign_name,
         coalesce(l.action_memo, c.suggested_care_action) action_memo,
         p.customer_name,
         p.gender,
         p.age,
         p.job,
         p.child,
         p.hp_no,
         p.juso,
         p.assignment_source,
         p.policy_count,
         p.total_amt,
         p.max_overdue,
         p.main_product,
         p.product_list,
         p.cancel_amt,
         p.customer_profile,
         p.contract_summary,
         p.cancel_summary,
         soe.ins2_churn_work_type(c.consult_text, c.keyword_score, c.churn_score, p.cancel_amt) work_type
    from soe.ins2_churn_candidate_v c
    left join latest_care l
      on l.source_cust_id = c.source_cust_id
     and l.rn = 1
    left join soe.ins2_churn_customer_profile_v p
      on p.source_cust_id = c.source_cust_id
   where c.churn_score >= 55
)
select b.source_cust_id,
       b.log_id,
       b.event_time,
       b.customer_name,
       b.gender,
       b.age,
       b.job,
       b.child,
       b.hp_no,
       b.juso,
       b.assigned_fp_id,
       b.assignment_source,
       b.work_type,
       soe.ins2_churn_contact_priority(b.work_type, b.churn_score) contact_priority,
       case b.work_type
         when '해약고객 긴급접촉' then 1
         when '해약가망 선제케어' then 2
         else 3
       end contact_rank,
       coalesce(
         (select due_date from latest_care l where l.source_cust_id = b.source_cust_id and l.rn = 1),
         trunc(sysdate) + case
           when b.work_type = '해약고객 긴급접촉' and b.churn_score >= 90 then 0
           when b.work_type = '해약고객 긴급접촉' then 1
           when b.work_type = '해약가망 선제케어' then 3
           else 7
         end
       ) due_date,
       b.care_status,
       b.campaign_name,
       b.fund_name,
       b.policy_count,
       b.total_amt,
       b.max_overdue,
       b.main_product,
       b.product_list,
       b.cancel_amt,
       b.churn_score,
       b.risk_band,
       b.churn_reason,
       b.vector_distance,
       b.keyword_score,
       b.call_cnt_3m,
       b.late_pmt_cnt,
       b.consult_text,
       b.action_memo,
       b.customer_profile,
       b.contract_summary,
       b.cancel_summary,
       soe.ins2_churn_fp_comment(
         b.work_type,
         soe.ins2_churn_contact_priority(b.work_type, b.churn_score),
         b.customer_name,
         b.source_cust_id,
         b.assigned_fp_id,
         b.churn_score,
         b.churn_reason,
         b.customer_profile,
         b.contract_summary,
         b.cancel_summary,
         b.consult_text,
         b.action_memo
       ) fp_coach_comment
  from base b;

grant select on soe.ins2_churn_fp_assignment_v to ggadmin;
grant select on soe.ins2_churn_customer_profile_v to ggadmin;
grant execute on soe.ins2_churn_work_type to ggadmin;
grant execute on soe.ins2_churn_contact_priority to ggadmin;
grant execute on soe.ins2_churn_response_strategy to ggadmin;
grant execute on soe.ins2_churn_fp_comment to ggadmin;


create or replace function soe.ins2_churn_fp_coach_html return clob authid definer is
  l_html clob;
  l_comment varchar2(3900);
  l_count number;

  procedure append_section(
    p_work_type varchar2,
    p_title varchar2,
    p_subtitle varchar2,
    p_badge_bg varchar2,
    p_limit number
  ) is
    l_rendered number := 0;
  begin
    select count(*) into l_count
      from soe.ins2_churn_action_queue_v
     where work_type = p_work_type;

    l_html := l_html ||
      '<div style="margin-top:16px">' ||
      '<div style="display:flex;align-items:flex-end;justify-content:space-between;gap:12px;margin-bottom:10px">' ||
      '<div><div style="font-size:15px;font-weight:900;color:#0f172a">' || apex_escape.html(p_title) || '</div>' ||
      '<div style="font-size:12px;color:#64748b;margin-top:2px">' || apex_escape.html(p_subtitle) || '</div></div>' ||
      '<div style="font-size:12px;font-weight:800;color:#334155;background:#f1f5f9;border-radius:999px;padding:4px 10px;white-space:nowrap">대상 ' || to_char(l_count) || '명</div>' ||
      '</div><div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(320px,1fr));gap:12px">';

    for r in (
      select *
        from (
          select source_cust_id, customer_name, assigned_fp_id, work_type, contact_priority,
                 risk_band, churn_score, churn_reason, fp_coach_comment, due_date,
                 row_number() over (order by churn_score desc, due_date, source_cust_id) rn
            from soe.ins2_churn_action_queue_v
           where work_type = p_work_type
        )
       where rn <= p_limit
       order by rn
    ) loop
      l_rendered := l_rendered + 1;
      l_comment := replace(apex_escape.html(r.fp_coach_comment), chr(10), '<br>');
      l_html := l_html ||
        '<div style="border:1px solid #d8dee9;border-radius:8px;background:#fff;padding:14px;box-shadow:0 1px 2px rgba(15,23,42,.04)">' ||
        '<div style="display:flex;align-items:center;justify-content:space-between;gap:8px;margin-bottom:8px">' ||
        '<div style="font-weight:800;color:#0f172a">' || apex_escape.html(coalesce(r.customer_name, '고객ID ' || r.source_cust_id)) || '</div>' ||
        '<div style="font-size:11px;font-weight:800;color:#fff;background:' || p_badge_bg || ';border-radius:999px;padding:3px 8px;white-space:nowrap">' || apex_escape.html(r.contact_priority) || '</div>' ||
        '</div>' ||
        '<div style="font-size:12px;color:#475569;margin-bottom:8px">담당 FP ' || apex_escape.html(r.assigned_fp_id) ||
        ' · ' || apex_escape.html(r.risk_band) || ' · ' || to_char(round(r.churn_score,1)) || '점 · ' || apex_escape.html(r.churn_reason) || '</div>' ||
        '<div style="font-size:12px;line-height:1.55;color:#1f2937;max-height:240px;overflow:auto;background:#f8fafc;border:1px solid #e5e7eb;border-radius:6px;padding:10px">' || l_comment || '</div>' ||
        '</div>';
    end loop;

    if l_rendered = 0 then
      l_html := l_html || '<div style="border:1px dashed #cbd5e1;border-radius:8px;padding:16px;color:#64748b;background:#f8fafc">현재 대상이 없습니다.</div>';
    end if;

    l_html := l_html || '</div></div>';
  end;
begin
  l_html := '<div class="fp-coach-wrap" style="margin-top:16px;border-top:1px solid #e2e8f0;padding-top:16px">' ||
            '<div style="display:flex;align-items:center;justify-content:space-between;gap:12px;margin-bottom:8px">' ||
            '<div><div style="font-size:16px;font-weight:900;color:#0f172a">FP AI 대응 코멘트</div>' ||
            '<div style="font-size:12px;color:#64748b;margin-top:2px">긴급 해약고객과 해약가망고객을 분리해 담당 FP가 바로 연락할 수 있는 멘트를 제공합니다.</div></div>' ||
            '</div>';

  append_section('해약고객 긴급접촉', '1. 해약고객 긴급접촉', '이미 해지/환급 의사를 보인 고객입니다. 오늘 또는 24시간 이내 해지 보류를 유도합니다.', '#dc2626', 4);
  append_section('해약가망 선제케어', '2. 해약가망 선제케어', '해약 seed와 vector distance가 가까운 고객입니다. 불편이 커지기 전에 3영업일 내 선제 접촉합니다.', '#2563eb', 4);
  append_section('관찰고객 안부케어', '3. 관찰고객 안부케어', '낮은 강도의 신호가 있는 고객입니다. 안부콜과 처리 확인으로 이탈 신호를 조기에 낮춥니다.', '#64748b', 2);

  return l_html || '</div>';
end;
/

grant execute on soe.ins2_churn_fp_coach_html to ggadmin;

begin
  soe.ins2_churn_vector_pkg.sync_care_queue;
end;
/

declare
  l_source clob := q'~select work_type "업무유형",
       contact_priority "접촉우선순위",
       source_cust_id "고객ID",
       customer_name "고객명",
       assigned_fp_id "담당FP",
       risk_band "위험등급",
       churn_score "해약가능점수",
       churn_reason "주요사유",
       due_date "케어기한",
       care_status "조치상태",
       main_product "대표계약",
       policy_count "계약수",
       total_amt "총계약금액",
       max_overdue "최대연체",
       fund_name "상담펀드",
       call_cnt_3m "3개월콜수",
       late_pmt_cnt "연체횟수",
       consult_text "최근상담",
       fp_coach_comment "FP대응코멘트",
       action_memo "권장액션",
       vector_distance "벡터거리"
  from soe.ins2_churn_action_queue_v
 order by contact_rank, churn_score desc, due_date~';
  l_report_columns varchar2(4000) := '"업무유형":"접촉우선순위":"고객ID":"고객명":"담당FP":"위험등급":"해약가능점수":"주요사유":"케어기한":"조치상태":"대표계약":"계약수":"총계약금액":"최대연체":"상담펀드":"3개월콜수":"연체횟수":"최근상담":"FP대응코멘트":"권장액션":"벡터거리"';
begin

  update apex_260100.wwv_flow_page_plugs
     set plug_name = '위험등급 분포 / FP AI 대응 코멘트',
         title = '위험등급 분포 / FP AI 대응 코멘트',
         plug_source = 'begin sys.htp.prn(soe.ins2_churn_risk_band_html()); sys.htp.prn(soe.ins2_churn_fp_coach_html()); end;',
         plug_source_type = 'NATIVE_PLSQL',
         last_updated_by = 'CODEX',
         last_updated_on = sysdate
   where flow_id = 340
     and page_id = 70
     and static_id = 'churn-risk-band-chart';

  begin
    apex_util.clear_app_cache(340);
  exception
    when others then null;
  end;

  update apex_260100.wwv_flow_page_plugs
     set plug_source = l_source,
         last_updated_by = 'CODEX',
         last_updated_on = sysdate
   where flow_id = 340
     and page_id = 70
     and static_id = 'churn-care-queue';

  update apex_260100.wwv_flow_worksheet_rpts r
     set report_columns = l_report_columns,
         updated_by = 'CODEX',
         updated_on = sysdate
   where exists (
       select 1
         from apex_260100.wwv_flow_worksheets w
         join apex_260100.wwv_flow_page_plugs p
           on p.id = w.region_id
        where w.id = r.worksheet_id
          and p.flow_id = 340
          and p.page_id = 70
          and p.static_id = 'churn-care-queue'
     );
end;
/

commit;

prompt FP care coaching extension installed.

set lines 120 pages 80
col work_type format a24
col contact_priority format a18
col cnt format 999999

select work_type, contact_priority, count(*) cnt
  from soe.ins2_churn_action_queue_v
 group by work_type, contact_priority
 order by min(contact_rank), contact_priority;

select source_cust_id, customer_name, assigned_fp_id, work_type, contact_priority,
       substr(fp_coach_comment, 1, 900) sample_comment
  from soe.ins2_churn_action_queue_v
 order by contact_rank, churn_score desc, due_date
 fetch first 3 rows only;
exit
