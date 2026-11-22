import os

import oracledb
import google.generativeai as genai

# 1. 설정
gemini_api_key = os.environ.get("GEMINI_API_KEY")
if not gemini_api_key:
    raise RuntimeError("Set GEMINI_API_KEY before running this demo.")
genai.configure(api_key=gemini_api_key)
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
        
        if row:
            manual_context = row[0].read()
        else:
            manual_context = "관련 매뉴얼을 찾을 수 없습니다."
            
        print(f"\n[DB에서 찾은 관련 매뉴얼]:\n{manual_context[:100]}...")

        # Step 2: Gemini RAG 생성
        #model = genai.GenerativeModel('gemini-1.5-flash') # 빠른 응답 속도의 모델
        #model = genai.GenerativeModel('gemini-1.5-flash-latest')
        #model = genai.GenerativeModel('gemini-pro')
        #model = genai.GenerativeModel('gemini-1.5-flash')
		#model = genai.GenerativeModel('models/gemini-1.5-flash')
		
        # Step 2: Gemini RAG 생성 (사용 가능한 모델 자동 탐색)
        available_models = [m.name for m in genai.list_models() if 'generateContent' in m.supported_generation_methods]
        
        if not available_models:
            return "사용 가능한 Gemini 모델을 찾을 수 없습니다."
            
        # 가장 적합한 모델 선택 (1.5 flash가 있으면 쓰고, 없으면 첫 번째 모델 사용)
        target_model = next((m for m in available_models if 'gemini-1.5-flash' in m), available_models[0])
        print(f"[사용 모델]: {target_model}")
        
        model = genai.GenerativeModel(target_model)
        prompt = f"""
        당신은 베테랑 보험 상담사입니다. 아래 [매뉴얼]을 바탕으로 [고객 상황]에 맞는 
        부드럽고 전문적인 설득 스크립트를 한국어로 작성해 주세요.

        [매뉴얼]: {manual_context}
        [고객 상황]: {customer_complaint}
        """

        response = model.generate_content(prompt)
        return response.text
        prompt = f"""
        당신은 베테랑 보험 상담사입니다. 아래 [매뉴얼]을 바탕으로 [고객 상황]에 맞는 
        부드럽고 전문적인 설득 스크립트를 한국어로 작성해 주세요.

        [매뉴얼]: {manual_context}
        [고객 상황]: {customer_complaint}
        """

        response = model.generate_content(prompt)
        return response.text

    finally:
        cursor.close()
        conn.close()

if __name__ == "__main__":
    print("="*50)
    print("🛡️ 보험 해약 방어 실시간 RAG 데모 (Gemini Ver.)")
    print("="*50)
    
    while True:
        user_input = input("\n고객 상담 내용을 입력하세요 (종료하려면 'q' 입력): ")
        if user_input.lower() == 'q': break
            
        print("\nGemini AI가 최적의 대응 방안을 생성 중입니다...")
        ai_guide = get_ai_response(user_input)
        
        print("\n" + "*"*20 + " [AI 대응 가이드] " + "*"*20)
        print(ai_guide)
        print("*"*57)
