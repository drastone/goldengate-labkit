set define off
set serveroutput on

declare
  procedure comment_table(p_table_name varchar2, p_comment varchar2) is
    l_count number;
  begin
    select count(*)
      into l_count
      from user_tables
     where table_name = upper(p_table_name);

    if l_count > 0 then
      execute immediate
        'comment on table ' || dbms_assert.simple_sql_name(p_table_name) || ' is ' ||
        dbms_assert.enquote_literal(p_comment);
    end if;
  end;

  procedure comment_column(p_table_name varchar2, p_column_name varchar2, p_comment varchar2) is
    l_count number;
  begin
    select count(*)
      into l_count
      from user_tab_columns
     where table_name = upper(p_table_name)
       and column_name = upper(p_column_name);

    if l_count > 0 then
      execute immediate
        'comment on column ' ||
        dbms_assert.simple_sql_name(p_table_name) || '.' ||
        dbms_assert.simple_sql_name(p_column_name) || ' is ' ||
        dbms_assert.enquote_literal(p_comment);
    end if;
  end;
begin
  comment_table('CUST_INFO', '보험 고객 마스터. 고객 식별, 연락처, 직업, 주소, 위치 정보를 보관한다.');
  comment_table('CUST_PR', '고객별 보유 보험 계약. 상품, 보험료, 납입일, 실효/해약 위험 상태를 관리한다.');
  comment_table('CFUND_DT', '고객 펀드 활동 CDC 핵심 테이블. 펀드 변경, 납입, 해약/환급 후보 이벤트를 기록한다.');
  comment_table('OPSTATUS', '업무 처리 상태별 발생 건수. 운영 상태 변화를 집계해 heavy lane으로 분리한다.');
  comment_table('TOT_AMT', '업무 구분별 금액 집계. 대량 집계성 변경이 발생할 수 있어 heavy lane으로 분리한다.');
  comment_table('CFUND_DEPOSIT', '고객별 펀드 납입 현황. 납입 금액, 납입 횟수, 미납 신호를 관리한다.');
  comment_table('CFUND_RAT', '고객별 펀드 편입 비율 이력. 리밸런싱 전후 변화를 추적한다.');
  comment_table('CFUND_RATIO', '고객별 기준 펀드 배분 비율. 시뮬레이션용 포트폴리오 구성을 보관한다.');
  comment_table('CFUND_RAT_TMP', '펀드 비율 변경 임시 작업 테이블. 변경 전후 값을 비교한다.');
  comment_table('CUST_DEP_DT', '고객 납입 상세 이벤트. 계약별 납입 상태와 금액 흐름을 기록한다.');
  comment_table('CUST_GEN_AMT', '고객별 일반 금액 이벤트. 상담, 납입, 해약 관련 금액 신호를 통합한다.');
  comment_table('CANCELAMT', '해약/환급 후보 금액 이벤트. 해약가망 선제케어와 AI comment 생성의 입력으로 사용한다.');
  comment_table('CANCELFP', '해약가망 고객과 담당 FP 연결 정보. 상담 연락 대상과 주소 정보를 제공한다.');
  comment_table('CALL_CENTER_LOG', '콜센터 상담 이력. 고객 문의, 연체, 펀드 관련 상담 문맥을 저장한다.');
  comment_table('PRODUCT', '보험 상품 마스터. 상품 카테고리, 상품 코드, 해약 환급 정보와 설명을 보관한다.');
  comment_table('FUNDM', '펀드 마스터. 펀드 코드, 펀드명, 설명을 보관한다.');
  comment_table('FUND_PRICE', '펀드 일자별 기준가. 펀드 평가와 금액 계산에 사용한다.');
  comment_table('EMPLOYEE', '담당 FP/직원 마스터. 고객 상담 담당자 정보를 보관한다.');
  comment_table('ADDRESS', '고객 주소와 위치 정보. 지도 기반 분석과 담당 FP 권역 확인에 사용한다.');
  comment_table('HEARTBP', 'CDC heartbeat 또는 실습 진행 상태 확인용 테이블.');
  comment_table('MSG', 'OSA 샘플 작업 시작/종료 메시지와 배치 실행 상태.');
  comment_table('OPM', '업무 구분 코드 마스터. OP_GUBUN 값을 업무명으로 해석한다.');
  comment_table('RESERVES_AMT', '고객 적립금/준비금 관련 금액 이벤트.');
  comment_table('OSA_CANCEL_PREDICTION', '해약 예측 입력/결과 후보. 상담 text와 vector feature를 포함한다.');
  comment_table('OSA_CANCEL_PREDICTION_GEN', '생성형 AI 또는 vector demo용 해약 예측 확장 데이터.');
  comment_table('SUCCESS_CASE_KNOWLEDGE', '성공 상담 사례 knowledge base. vector 검색과 상담 가이드에 사용한다.');
  comment_table('OGG_SYNC_UNIT_TEST', 'GoldenGate 동기화 확인을 위한 단위 테스트 테이블.');
  comment_table('TMP_TRIGGER', '실습용 trigger/event 확인 임시 테이블.');

  for t in (
    select table_name
      from user_tables
     where table_name in (
       'CUST_INFO','CUST_PR','CFUND_DT','OPSTATUS','TOT_AMT','CFUND_DEPOSIT',
       'CFUND_RAT','CFUND_RATIO','CFUND_RAT_TMP','CUST_DEP_DT','CUST_GEN_AMT',
       'CANCELAMT','CANCELFP','CALL_CENTER_LOG','PRODUCT','FUNDM','FUND_PRICE',
       'EMPLOYEE','ADDRESS','RESERVES_AMT','OSA_CANCEL_PREDICTION',
       'OSA_CANCEL_PREDICTION_GEN'
     )
  ) loop
    comment_column(t.table_name, 'CUST_ID', '고객 식별자. Source 업무 이벤트와 downstream data product를 연결하는 핵심 key.');
    comment_column(t.table_name, 'CUST_NM', '고객명.');
    comment_column(t.table_name, 'JUMIN_NO', '주민/고객 식별 번호. 실습 데이터이며 운영 환경에서는 masking 대상.');
    comment_column(t.table_name, 'GENDER', '성별 코드.');
    comment_column(t.table_name, 'AGE', '고객 또는 직원 나이.');
    comment_column(t.table_name, 'EMAIL', '이메일 연락처.');
    comment_column(t.table_name, 'HP_NO', '휴대전화 연락처.');
    comment_column(t.table_name, 'PHONENUMBER', '전화번호.');
    comment_column(t.table_name, 'FP_ID', '담당 FP 또는 직원 식별자.');
    comment_column(t.table_name, 'FP_NAME', '담당 FP 이름.');
    comment_column(t.table_name, 'FP_PHONE', '담당 FP 연락처.');
    comment_column(t.table_name, 'JUSO', '주소 문자열.');
    comment_column(t.table_name, 'LAT', '위도.');
    comment_column(t.table_name, 'LON', '경도.');
    comment_column(t.table_name, 'DT', '업무 기준 일자 또는 이벤트 발생 일자.');
    comment_column(t.table_name, 'EVENT_DT', '이벤트 발생 일시.');
    comment_column(t.table_name, 'WORK_DT', '상담 또는 업무 처리 기준 일자.');
    comment_column(t.table_name, 'WORK_DT_TS', '상담 또는 업무 처리 timestamp.');
    comment_column(t.table_name, 'START_DT', '업무 시작 일자 또는 집계 시작 기준.');
    comment_column(t.table_name, 'CREATED', '생성 일자.');
    comment_column(t.table_name, 'CREATED_AT', '생성 timestamp.');
    comment_column(t.table_name, 'UPDATED_AT', '수정 timestamp.');
    comment_column(t.table_name, 'STOCK_NO', '고객 계약 번호.');
    comment_column(t.table_name, 'SEQ_NO', '계약 또는 납입 상세 순번.');
    comment_column(t.table_name, 'PRODUCT_CODE', '보험 상품 코드.');
    comment_column(t.table_name, 'PRODUCT', '보험 상품명.');
    comment_column(t.table_name, 'CATEGORY', '상품 또는 고객 분류.');
    comment_column(t.table_name, 'AMT', '보험료 또는 기준 금액.');
    comment_column(t.table_name, 'TOT_AMT', '집계 금액 또는 총 금액.');
    comment_column(t.table_name, 'RESERVES_AMT', '준비금 또는 적립금 금액.');
    comment_column(t.table_name, 'PAYMENT_DATE', '납입 예정 또는 납입 기준일.');
    comment_column(t.table_name, 'STATUS', '계약 또는 업무 상태.');
    comment_column(t.table_name, 'OVERDUE', '연체 여부 또는 연체 건수.');
    comment_column(t.table_name, 'OVERDUE_RESC', '연체 해소 여부.');
    comment_column(t.table_name, 'SILHYO_CNT', '실효 발생 횟수.');
    comment_column(t.table_name, 'SILHYO_YN', '실효 여부.');
    comment_column(t.table_name, 'NON_DEPOSIT_CNT', '미납 횟수.');
    comment_column(t.table_name, 'DEPOSIT_DATE', '납입 일자.');
    comment_column(t.table_name, 'DEPOSIT_AMT', '납입 금액.');
    comment_column(t.table_name, 'DEPOSIT_CNT', '납입 횟수.');
    comment_column(t.table_name, 'FUND_CODE', '펀드 코드.');
    comment_column(t.table_name, 'FUND_CODE1', '첫 번째 기준 펀드 코드.');
    comment_column(t.table_name, 'FUND_CODE2', '두 번째 기준 펀드 코드.');
    comment_column(t.table_name, 'FUND_NAME', '펀드명.');
    comment_column(t.table_name, 'FUND_DESCRIPTION', '펀드 설명.');
    comment_column(t.table_name, 'FUND_PRICE', '펀드 기준가.');
    comment_column(t.table_name, 'PRICE', '펀드 가격.');
    comment_column(t.table_name, 'FUND_CNT', '펀드 수량.');
    comment_column(t.table_name, 'FUND_AMT', '펀드 평가 금액.');
    comment_column(t.table_name, 'FUND_RAT', '펀드 편입 비율.');
    comment_column(t.table_name, 'FUND_RAT1', '첫 번째 펀드 편입 비율.');
    comment_column(t.table_name, 'FUND_RAT2', '두 번째 펀드 편입 비율.');
    comment_column(t.table_name, 'OP_GUBUN', '업무 구분 코드.');
    comment_column(t.table_name, 'OP_GUBUN2', '보조 업무 구분 코드.');
    comment_column(t.table_name, 'OP_NAME', '업무 구분명.');
    comment_column(t.table_name, 'OP_CNT', '업무 구분별 발생 건수.');
    comment_column(t.table_name, 'GUBUN', '집계 또는 업무 세부 구분.');
    comment_column(t.table_name, 'CNT', '이벤트 건수 또는 집계 횟수.');
    comment_column(t.table_name, 'CALL_DT', '상담 일자.');
    comment_column(t.table_name, 'CALL_DT_TS', '상담 timestamp.');
    comment_column(t.table_name, 'LOG_ID', '상담 로그 식별자.');
    comment_column(t.table_name, 'CALL_CNT_3M', '최근 3개월 상담 횟수.');
    comment_column(t.table_name, 'LATE_PMT_CNT', '최근 연체 또는 지연 납입 횟수.');
    comment_column(t.table_name, 'CONSULT_TEXT', '상담 내용 text.');
    comment_column(t.table_name, 'CONSULT_VECTOR', '상담 text embedding vector.');
    comment_column(t.table_name, 'AI_COMMENT', 'AI가 생성한 담당 FP 참고 comment.');
    comment_column(t.table_name, 'AI_COMMENT_STATUS', 'AI comment 생성 상태.');
    comment_column(t.table_name, 'AI_ERROR_MESSAGE', 'AI comment 생성 실패 메시지.');
    comment_column(t.table_name, 'AI_GENERATED_AT', 'AI comment 생성 시각.');
  end loop;
end;
/
