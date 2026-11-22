import oracledb
import openai

# 1. 설정 (본인의 정보로 수정)
openai.api_key = "sk-proj-..." # 사용자의 OpenAI API Key
db_config = {
    "user": "soe",
    "password": "WElcome1234##",
    "dsn": "localhost:1521/FREEPDB1" # Docker 환경 포트 및 서비스명
}

def get_ai_response(customer_complaint):
    # Oracle DB 23ai 연결
    conn = oracledb.connect(**db_config)
    cursor = conn.cursor()

    try:
        # Step 1: Vector Search (DB에서 가장 유사한 매뉴얼 단락 1개 찾기)
        # 이전에 만든 CHURN_MODEL을 사용하여 입력 문장을 벡터로 변환 후 검색
        search_sql = """
            SELECT content 
            FROM soe.insurance_knowledge
            ORDER BY VECTOR_DISTANCE(
                embedding, 
                VECTOR_EMBEDDING(CHURN_MODEL USING :complaint as DATA)
            )
            FETCH FIRST 1 ROWS ONLY
        """
        cursor.execute(search_sql, complaint=customer_complaint)
        row = cursor.fetchone()
        manual_context = row[0] if row else "관련 매뉴얼을 찾을 수 없습니다."

        # Step 2: RAG (검색된 매뉴얼 + 고객 불만을 OpenAI에게 전달)
        prompt = f"""
        당신은 베테랑 보험 상담사입니다. 아래 [매뉴얼]을 바탕으로 [고객 상황]에 맞는 
        부드럽고 전문적인 설득 스크립트를 한국어로 작성해 주세요.

        [매뉴얼]: {manual_context}
        [고객 상황]: {customer_complaint}
        """

        response = openai.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[{"role": "user", "content": prompt}]
        )

        return response.choices[0].message.content

    finally:
        cursor.close()
        conn.close()

# 3. 데모 실행
complaint = "요즘 경기가 안 좋아서 보험료 내기가 너무 부담돼요. 그냥 해약해 주세요."
print(f"--- AI 대응 가이드 ---\n{get_ai_response(complaint)}")
