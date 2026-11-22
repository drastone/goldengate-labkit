set serveroutput on size unlimited
set define off
whenever sqlerror exit sql.sqlcode rollback
alter session set container=ORCLPDB1;

declare
  l_sgid number;
  l_care_worksheet_id number;
  l_log_worksheet_id number;
  l_care_report_columns constant varchar2(4000) := '업무유형:접촉우선순위:고객ID:고객명:담당FP:위험등급:해약가능점수:주요사유:케어기한:조치상태';
  l_log_report_columns  constant varchar2(4000) := '로그ID:고객ID:상담시각:위험등급:해약가능점수:벡터매칭사유:벡터유사점수:벡터상태';

  procedure add_col(
    p_worksheet_id number,
    p_seq          number,
    p_db_col       varchar2,
    p_label        varchar2,
    p_type         varchar2 default 'STRING'
  ) is
  begin
    apex_260100.wwv_flow_imp_page.create_worksheet_column(
      p_id                     => apex_260100.wwv_flow_id.next_val,
      p_flow_id                => 340,
      p_page_id                => 70,
      p_worksheet_id           => p_worksheet_id,
      p_db_column_name         => p_db_col,
      p_display_order          => p_seq * 10,
      p_column_identifier      => chr(64 + p_seq),
      p_column_label           => p_label,
      p_report_label           => p_label,
      p_display_in_default_rpt => 'Y',
      p_column_type            => p_type,
      p_display_as             => 'TEXT',
      p_heading_alignment      => 'LEFT',
      p_column_alignment       => case when p_type='NUMBER' then 'RIGHT' else 'LEFT' end,
      p_allow_sorting          => 'Y',
      p_allow_filtering        => 'Y',
      p_allow_hide             => 'Y',
      p_static_id              => lower(rawtohex(utl_raw.cast_to_raw(p_db_col)))
    );
  end;

  procedure reset_cols(p_worksheet_id number) is
  begin
    delete from apex_260100.wwv_flow_worksheet_columns
     where flow_id = 340
       and page_id = 70
       and worksheet_id = p_worksheet_id;
  end;
begin
  select security_group_id into l_sgid from apex_260100.wwv_flows where id=340;
  apex_260100.wwv_flow_api.set_security_group_id(l_sgid);

  select w.id
    into l_care_worksheet_id
    from apex_260100.wwv_flow_worksheets w
    join apex_260100.wwv_flow_page_plugs p on p.id = w.region_id
   where p.flow_id = 340 and p.page_id = 70 and p.static_id = 'churn-care-queue';

  select w.id
    into l_log_worksheet_id
    from apex_260100.wwv_flow_worksheets w
    join apex_260100.wwv_flow_page_plugs p on p.id = w.region_id
   where p.flow_id = 340 and p.page_id = 70 and p.static_id = 'churn-log-vector-match';

  reset_cols(l_care_worksheet_id);
  add_col(l_care_worksheet_id,  1, '업무유형',       '업무유형');
  add_col(l_care_worksheet_id,  2, '접촉우선순위',   '접촉우선순위');
  add_col(l_care_worksheet_id,  3, '고객ID',         '고객ID', 'NUMBER');
  add_col(l_care_worksheet_id,  4, '고객명',         '고객명');
  add_col(l_care_worksheet_id,  5, '담당FP',         '담당FP', 'NUMBER');
  add_col(l_care_worksheet_id,  6, '위험등급',       '위험등급');
  add_col(l_care_worksheet_id,  7, '해약가능점수',   '해약가능점수', 'NUMBER');
  add_col(l_care_worksheet_id,  8, '주요사유',       '주요사유');
  add_col(l_care_worksheet_id,  9, '케어기한',       '케어기한');
  add_col(l_care_worksheet_id, 10, '조치상태',       '조치상태');
  add_col(l_care_worksheet_id, 11, '대표계약',       '대표계약');
  add_col(l_care_worksheet_id, 12, '계약수',         '계약수', 'NUMBER');
  add_col(l_care_worksheet_id, 13, '총계약금액',     '총계약금액', 'NUMBER');
  add_col(l_care_worksheet_id, 14, '최대연체',       '최대연체', 'NUMBER');
  add_col(l_care_worksheet_id, 15, '상담펀드',       '상담펀드');
  add_col(l_care_worksheet_id, 16, '3개월콜수',      '3개월콜수', 'NUMBER');
  add_col(l_care_worksheet_id, 17, '연체횟수',       '연체횟수', 'NUMBER');
  add_col(l_care_worksheet_id, 18, '최근상담',       '최근상담');
  add_col(l_care_worksheet_id, 19, 'FP대응코멘트',   'FP대응코멘트');
  add_col(l_care_worksheet_id, 20, '권장액션',       '권장액션');
  add_col(l_care_worksheet_id, 21, '벡터거리',       '벡터거리', 'NUMBER');

  reset_cols(l_log_worksheet_id);
  add_col(l_log_worksheet_id,  1, '로그ID',         '로그ID', 'NUMBER');
  add_col(l_log_worksheet_id,  2, '고객ID',         '고객ID', 'NUMBER');
  add_col(l_log_worksheet_id,  3, '상담시각',       '상담시각');
  add_col(l_log_worksheet_id,  4, '위험등급',       '위험등급');
  add_col(l_log_worksheet_id,  5, '해약가능점수',   '해약가능점수', 'NUMBER');
  add_col(l_log_worksheet_id,  6, '벡터매칭사유',   '벡터매칭사유');
  add_col(l_log_worksheet_id,  7, '벡터유사점수',   '벡터유사점수', 'NUMBER');
  add_col(l_log_worksheet_id,  8, '키워드점수',     '키워드점수', 'NUMBER');
  add_col(l_log_worksheet_id,  9, '벡터상태',       '벡터상태');
  add_col(l_log_worksheet_id, 10, '상품',           '상품');
  add_col(l_log_worksheet_id, 11, '상담내용',       '상담내용');

  update apex_260100.wwv_flow_worksheet_rpts
     set report_columns = l_care_report_columns,
         updated_by = 'CODEX',
         updated_on = sysdate
   where worksheet_id = l_care_worksheet_id;

  update apex_260100.wwv_flow_worksheet_rpts
     set report_columns = l_log_report_columns,
         updated_by = 'CODEX',
         updated_on = sysdate
   where worksheet_id = l_log_worksheet_id;

  commit;
  dbms_output.put_line('Page 70 IR columns repaired.');
end;
/

select worksheet_id, count(*) column_count
from apex_260100.wwv_flow_worksheet_columns
where flow_id=340 and page_id=70
group by worksheet_id
order by worksheet_id;
exit
