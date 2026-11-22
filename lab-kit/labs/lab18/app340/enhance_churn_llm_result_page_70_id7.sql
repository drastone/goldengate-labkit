set define off
set serveroutput on size unlimited
set feedback on
whenever sqlerror exit sql.sqlcode rollback

alter session set container=ORCLPDB1;

create or replace function soe.ins2_churn_llm_html return clob authid definer is
  l_html clob;
  l_count_all number := 0;
  l_count_generated number := 0;
  l_count_error number := 0;
  l_comment varchar2(4000);
  l_error varchar2(1000);
  l_rendered number := 0;
begin
  select count(*),
         sum(case when status = 'GENERATED' then 1 else 0 end),
         sum(case when status = 'ERROR' then 1 else 0 end)
    into l_count_all, l_count_generated, l_count_error
    from soe.ins2_churn_llm_result;

  l_html :=
    '<div class="llm-result-wrap" style="margin-top:22px;border-top:1px solid #e2e8f0;padding-top:18px">' ||
    '<div style="display:flex;align-items:flex-end;justify-content:space-between;gap:12px;margin-bottom:12px">' ||
    '<div>' ||
    '<div style="font-size:16px;font-weight:900;color:#0f172a">실제 외부 LLM 생성 코멘트</div>' ||
    '<div style="font-size:12px;color:#64748b;margin-top:2px">GoldenGate로 동기화된 해약 위험 데이터를 OpenAI-compatible API에 전달해 담당 FP 참고 코멘트를 생성합니다.</div>' ||
    '</div>' ||
    '<div style="display:flex;gap:6px;flex-wrap:wrap;justify-content:flex-end">' ||
    '<span style="font-size:12px;font-weight:800;color:#334155;background:#f1f5f9;border-radius:999px;padding:4px 10px;white-space:nowrap">전체 ' || to_char(l_count_all) || '건</span>' ||
    '<span style="font-size:12px;font-weight:800;color:#166534;background:#dcfce7;border-radius:999px;padding:4px 10px;white-space:nowrap">생성 ' || to_char(nvl(l_count_generated, 0)) || '건</span>' ||
    '<span style="font-size:12px;font-weight:800;color:#991b1b;background:#fee2e2;border-radius:999px;padding:4px 10px;white-space:nowrap">오류 ' || to_char(nvl(l_count_error, 0)) || '건</span>' ||
    '</div>' ||
    '</div>';

  l_html := l_html ||
    '<div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(360px,1fr));gap:12px">';

  for r in (
    select *
      from (
        select x.source_cust_id,
               x.log_id,
               x.status,
               x.model_name,
               x.error_message,
               x.generated_at,
               x.llm_comment,
               q.customer_name,
               q.assigned_fp_id,
               q.work_type,
               q.contact_priority,
               q.risk_band,
               q.churn_score,
               q.churn_reason,
               q.consult_text,
               row_number() over (
                 order by case x.status when 'GENERATED' then 1 when 'ERROR' then 2 else 3 end,
                          x.updated_at desc,
                          x.source_cust_id
               ) rn
          from soe.ins2_churn_llm_result x
          left join soe.ins2_churn_action_queue_v q
            on q.source_cust_id = x.source_cust_id
           and nvl(q.log_id, -1) = nvl(x.log_id, -1)
      )
     where rn <= 6
     order by rn
  ) loop
    l_rendered := l_rendered + 1;
    l_comment := replace(apex_escape.html(dbms_lob.substr(r.llm_comment, 3500, 1)), chr(10), '<br>');
    l_error := apex_escape.html(substr(r.error_message, 1, 1000));

    l_html := l_html ||
      '<div style="border:1px solid #d8dee9;border-radius:8px;background:#fff;padding:14px;box-shadow:0 1px 2px rgba(15,23,42,.05)">' ||
      '<div style="display:flex;align-items:center;justify-content:space-between;gap:8px;margin-bottom:8px">' ||
      '<div style="font-weight:900;color:#0f172a">' || apex_escape.html(coalesce(r.customer_name, '고객ID ' || r.source_cust_id)) || '</div>' ||
      '<div style="font-size:11px;font-weight:900;color:#fff;background:' ||
        case when r.status = 'GENERATED' then '#16a34a' when r.status = 'ERROR' then '#dc2626' else '#64748b' end ||
        ';border-radius:999px;padding:3px 8px;white-space:nowrap">' || apex_escape.html(r.status) || '</div>' ||
      '</div>' ||
      '<div style="font-size:12px;color:#475569;margin-bottom:8px">담당 FP ' || apex_escape.html(r.assigned_fp_id) ||
      ' · ' || apex_escape.html(r.risk_band) || ' · ' || to_char(round(r.churn_score,1)) || '점 · ' ||
      apex_escape.html(r.contact_priority) || '</div>' ||
      '<div style="font-size:12px;color:#64748b;margin-bottom:8px">모델 ' || apex_escape.html(r.model_name) ||
      ' · 생성시각 ' || to_char(r.generated_at, 'YYYY-MM-DD HH24:MI:SS') || '</div>' ||
      '<div style="font-size:12px;line-height:1.6;color:#1f2937;background:#f8fafc;border:1px solid #e5e7eb;border-radius:6px;padding:10px;min-height:96px;max-height:260px;overflow:auto">' ||
        case
          when r.status = 'GENERATED' then l_comment
          else '<span style="color:#991b1b;font-weight:800">오류</span><br>' || l_error
        end ||
      '</div>' ||
      '</div>';
  end loop;

  if l_rendered = 0 then
    l_html := l_html ||
      '<div style="border:1px dashed #cbd5e1;border-radius:8px;padding:16px;color:#64748b;background:#f8fafc">' ||
      '아직 실제 외부 LLM으로 생성된 코멘트가 없습니다. 선택 실습에서 LLM 설정 후 source 업무 이벤트가 GoldenGate로 target에 반영되면 Scheduler job이 코멘트를 생성합니다.' ||
      '</div>';
  end if;

  return l_html || '</div></div>';
end ins2_churn_llm_html;
/

show errors function soe.ins2_churn_llm_html

grant execute on soe.ins2_churn_llm_html to ggadmin;

declare
  l_sgid number;
begin
  select security_group_id
    into l_sgid
    from apex_260100.wwv_flows
   where id = 340;
  apex_260100.wwv_flow_api.set_security_group_id(l_sgid);

  update apex_260100.wwv_flow_page_plugs
     set plug_name = '위험등급 분포 / FP AI 대응 코멘트',
         title = '위험등급 분포 / FP AI 대응 코멘트',
         plug_source = 'begin sys.htp.prn(soe.ins2_churn_risk_band_html()); sys.htp.prn(soe.ins2_churn_fp_coach_html()); sys.htp.prn(soe.ins2_churn_llm_html()); end;',
         plug_source_type = 'NATIVE_PLSQL',
         last_updated_by = 'CODEX',
         last_updated_on = sysdate
   where flow_id = 340
     and page_id = 70
     and static_id = 'churn-risk-band-chart';
  if sql%rowcount <> 1 then
    raise_application_error(-20704, 'Expected one Page 70 LLM result region, updated ' || sql%rowcount);
  end if;
end;
/

commit;

begin
  apex_util.clear_app_cache(340);
exception
  when others then
    null;
end;
/

prompt Enhanced Page 70 with real external LLM result cards.
