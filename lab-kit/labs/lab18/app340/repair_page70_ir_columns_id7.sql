set serveroutput on size unlimited
set define off
whenever sqlerror exit sql.sqlcode rollback
alter session set container=ORCLPDB1;

declare
  l_sgid number;

  procedure add_col(
    p_worksheet_id number,
    p_seq          number,
    p_db_col       varchar2,
    p_label        varchar2,
    p_type         varchar2 default 'STRING'
  ) is
  begin
    apex_260100.wwv_flow_imp_page.create_worksheet_column(
      p_id                     => p_worksheet_id + case when p_worksheet_id = 3000000700000009 then 1000000 else 2000000 end + p_seq,
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

  reset_cols(3000000700000009);
  add_col(3000000700000009,  1, '업무유형',       '업무유형');
  add_col(3000000700000009,  2, '접촉우선순위',   '접촉우선순위');
  add_col(3000000700000009,  3, '고객ID',         '고객ID', 'NUMBER');
  add_col(3000000700000009,  4, '고객명',         '고객명');
  add_col(3000000700000009,  5, '담당FP',         '담당FP', 'NUMBER');
  add_col(3000000700000009,  6, '위험등급',       '위험등급');
  add_col(3000000700000009,  7, '해약가능점수',   '해약가능점수', 'NUMBER');
  add_col(3000000700000009,  8, '주요사유',       '주요사유');
  add_col(3000000700000009,  9, '케어기한',       '케어기한');
  add_col(3000000700000009, 10, '조치상태',       '조치상태');
  add_col(3000000700000009, 11, '대표계약',       '대표계약');
  add_col(3000000700000009, 12, '계약수',         '계약수', 'NUMBER');
  add_col(3000000700000009, 13, '총계약금액',     '총계약금액', 'NUMBER');
  add_col(3000000700000009, 14, '최대연체',       '최대연체', 'NUMBER');
  add_col(3000000700000009, 15, '상담펀드',       '상담펀드');
  add_col(3000000700000009, 16, '3개월콜수',      '3개월콜수', 'NUMBER');
  add_col(3000000700000009, 17, '연체횟수',       '연체횟수', 'NUMBER');
  add_col(3000000700000009, 18, '최근상담',       '최근상담');
  add_col(3000000700000009, 19, 'FP대응코멘트',   'FP대응코멘트');
  add_col(3000000700000009, 20, '권장액션',       '권장액션');
  add_col(3000000700000009, 21, '벡터거리',       '벡터거리', 'NUMBER');

  reset_cols(3000000700000012);
  add_col(3000000700000012,  1, '로그ID',         '로그ID', 'NUMBER');
  add_col(3000000700000012,  2, '고객ID',         '고객ID', 'NUMBER');
  add_col(3000000700000012,  3, '상담시각',       '상담시각');
  add_col(3000000700000012,  4, '위험등급',       '위험등급');
  add_col(3000000700000012,  5, '해약가능점수',   '해약가능점수', 'NUMBER');
  add_col(3000000700000012,  6, '벡터매칭사유',   '벡터매칭사유');
  add_col(3000000700000012,  7, '벡터유사점수',   '벡터유사점수', 'NUMBER');
  add_col(3000000700000012,  8, '키워드점수',     '키워드점수', 'NUMBER');
  add_col(3000000700000012,  9, '벡터상태',       '벡터상태');
  add_col(3000000700000012, 10, '상품',           '상품');
  add_col(3000000700000012, 11, '상담내용',       '상담내용');

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
