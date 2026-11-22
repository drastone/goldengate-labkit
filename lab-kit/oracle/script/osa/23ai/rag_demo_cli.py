import os

import oracledb
import openai

openai.api_key = os.environ.get("OPENAI_API_KEY")
if not openai.api_key:
    raise RuntimeError("OPENAI_API_KEY is not set")
db_config = {
    "user": "soe",
    "password": "soe",
    "dsn": "localhost:1521/FREEPDB1"
}

def get_ai_response(customer_complaint):
    conn = oracledb.connect(**db_config)
    cursor = conn.cursor()

    try:
        # Step 1: Oracle 23ai Vector Search (매뉴얼 찾기)
        # 로드하신 CHURN_MODEL을 사용하여 텍스트를 벡터로 변환하고 가장 유사한 단락 추출
        search_sql = """
            SELECT content 
            FROM soe.insurance_knowledge
            ORDER BY VECTOR_DISTANCE(
                embedding, 
                VECTOR_EMBEDDING(GGADMIN.CHURN_MODEL USING :complaint as DATA)
            )
            FETCH FIRST 1 ROWS ONLY
        """
        cursor.execute(search_sql, complaint=customer_complaint)
        row = cursor.fetchone()
        
        if not row:
            return "관련된 매뉴얼 내용을 찾을 수 없습니다."
        
        #manual_context = row[0]
        manual_context = row[0].read() if row else "관련 매뉴얼을 찾을 수 없습니다."
        print(f"\n[DB에서 찾은 관련 매뉴얼]:\n{manual_context[:100]}...")

        # Step 2: OpenAI RAG 생성
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

# 2. 터미널 기반 실시간 데모 실행 루프
if __name__ == "__main__":
    print("="*50)
    print("🛡️ 보험 해약 방어 실시간 RAG 데모 (Terminal Ver.)")
    print("="*50)
    
    while True:
        user_input = input("\n고객 상담 내용을 입력하세요 (종료하려면 'q' 입력): ")
        if user_input.lower() == 'q':
            break
            
        print("\nAI가 최적의 대응 방안을 생성 중입니다...")
        ai_guide = get_ai_response(user_input)
        
        print("\n" + "*"*20 + " [AI 대응 가이드] " + "*"*20)
        print(ai_guide)
        print("*"*57)
