from flask import Flask, request, jsonify
import openai
import mysql.connector
from mysql.connector import Error
from dotenv import load_dotenv
import os

# Flask 애플리케이션 생성
app = Flask(__name__)

# 환경 변수 로드
load_dotenv()

# OpenAI API 키 설정
os.environ["OPENAI_API_KEY"] = os.getenv('OPENAI_API_KEY')

# MySQL 데이터베이스 연결 함수
def get_db_connection():
    try:
        connection = mysql.connector.connect(
            host=os.getenv('DB_HOST'),
            database=os.getenv('DB_DATABASE'),
            user=os.getenv('DB_USER'),
            password=os.getenv('DB_PASSWORD')
        )
        return connection
    except Error as e:
        print("MySQL 연결 오류:", e)
        return None
    
def counseling(user_no, measure_date):
    try:
        connection = get_db_connection()
        if connection is not None:
            cursor = connection.cursor(dictionary=True)

            # 사용자 정보 조회
            select_user_query = """
            SELECT * FROM user WHERE user_no = %s
            """
            cursor.execute(select_user_query, (user_no,))
            user_data = cursor.fetchone()

            if not user_data:
                return {'error': '사용자를 찾을 수 없습니다.'}, 404

            name = user_data['name']  # 사용자 이름 가져오기

            # 혈당 정보 조회
            select_bloodsugar_query = """
            SELECT * FROM bloodsugar WHERE user_no = %s AND measure_date = %s
            """
            cursor.execute(select_bloodsugar_query, (user_no, measure_date))
            bloodsugar_data = cursor.fetchone()

            if not bloodsugar_data:
                return {'error': '혈당 정보를 찾을 수 없습니다.'}, 404

            blood_sugar = bloodsugar_data['measure']

            # 운동 정보 조회
            select_exercise_query = """
            SELECT * FROM exercise WHERE user_no = %s AND measure_date = %s
            """
            cursor.execute(select_exercise_query, (user_no, measure_date))
            exercise_data = cursor.fetchone()

            if not exercise_data:
                return {'error': '운동 정보를 찾을 수 없습니다.'}, 404

            kcal = exercise_data['Kcal']

            client = openai.OpenAI()
            stream = client.chat.completions.create(
                model="gpt-4o",
                messages=[
                    {"role": "system", "content": "너는 고객의 혈당과 운동량을 통해서 건강 진단을 내려주는 건강관리사야."},
                    {"role": "user", "content": f"해당 날짜의 운동량과 혈당을 통해서 어떤 음식을 먹으면 좋을지, 어떤 운동을 하면 좋을지에 대해서 결과를 알려줘. 칼로리 소모: {kcal}, 혈당: {blood_sugar}"},
                    {"role": "user", "content": "상담사같은 친절한 말투를 사용해줘."},
                    {"role": "user", "content": "300자 이내로 대답해줘."},
                    {"role": "user", "content": "이모티콘 사용해줘."},
                    {"role": "user", "content": "출력 시에 마크다운 형식으로 출력하지마."},
                ],
                stream=True,
            )

            response = ""

            for chunk in stream:
                if chunk.choices[0].delta.content is not None:
                    response += chunk.choices[0].delta.content
            
            print(response)
            return {'response':response}
        else:
            return {'error': '데이터베이스 연결 실패'}, 500  # 데이터베이스 연결 실패 메시지 추가

    except Error as e:
        print("MySQL 쿼리 오류:", e)
        return {'error': str(e)}, 500