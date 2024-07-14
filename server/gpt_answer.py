from flask import Flask, request, jsonify
from openai import OpenAI
import mysql.connector
from mysql.connector import Error
from dotenv import load_dotenv
import os
import time

# Flask 애플리케이션 생성
app = Flask(__name__)

# 환경 변수 로드
load_dotenv()

# OpenAI API 키 설정
OpenAI.api_key = os.getenv('OPENAI_API_KEY')

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
    
def counseling(user_no, measure_date, counsel):
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

            client = OpenAI()
            prompt = f"사용자{name}님의 {measure_date} 날짜의 혈당 상담: {counsel}\n"
            completion = client.chat.completions.create(
                model="gpt-3.5-turbo",
                messages=[
                    {"role": "system", "content": "너는 고객의 혈당과 운동량을 통해서 건강 진단을 내려주는 건강관리사야."},
                    {"role": "user", "content": f"해당 날짜의 운동량과 혈당을 통해서 어떤 음식을 먹으면 좋을지, 어떤 운동을 하면 좋을지에 대해서 결과를 알려줘. 칼로리 소모: {kcal}, 혈당: {blood_sugar}"},
                    {"role": "user", "content": "상담사같은 친절한 말투를 사용해줘."}
                ],
                max_tokens = 10000
            )

            answer = "Assistant: " + completion.choices[0].message['content']
            print(answer)
            return answer
    except mysql.connector.Error as e:
        print("MySQL 데이터 조회 오류:", e)
        return {'error': 'MySQL 데이터 조회 오류'}, 500

    except Exception as e:
        print("오류 발생:", e)
        return {'error': '서버 오류'}, 500

    finally:
        if 'cursor' in locals() and cursor is not None:
            cursor.close()
        if 'connection' in locals() and connection.is_connected():
            connection.close()