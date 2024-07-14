import openai
import mysql.connector
from mysql.connector import Error
from dotenv import load_dotenv
import os

load_dotenv()

openai.api_key = os.getenv('OPENAI_API_KEY')

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

# 사용자 진단
def get_diagnosis(user_no):
    try:
        conn = get_db_connection()
        if conn is None:
            return "Database connection error."
        
        cursor = conn.cursor()

        cursor.execute("SELECT measure FROM bloodsugar WHERE user_no = %s ORDER BY date DESC LIMIT 1", (user_no,))
        blood_sugar_result = cursor.fetchone()
        if blood_sugar_result is None:
            return "No blood sugar data found."
        blood_sugar = blood_sugar_result[0]

        cursor.execute("SELECT kcal FROM exercise WHERE user_no = %s ORDER BY date DESC LIMIT 1", (user_no,))
        calories_burned_result = cursor.fetchone()
        if calories_burned_result is None:
            return "No exercise data found."
        calories_burned = calories_burned_result[0]

        cursor.close()
        conn.close()

        # OpenAI API 호출
        response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": "너는 고객의 혈당과 운동량을 통해서 건강 진단을 내려주는 건강관리사야."},
                {"role": "user", "content": f"해당 날짜의 운동량과 혈당을 통해서 어떤 음식을 먹으면 좋을지, 어떤 운동을 하면 좋을지에 대해서 결과를 알려줘. 칼로리 소모: {calories_burned}, 혈당: {blood_sugar}"},
                {"role": "user", "content": "상담사같은 친절한 말투를 사용해줘."}
            ]
        )

        output_text = response['choices'][0]['message']['content']
        return output_text
    except Exception as e:
        print("Error during process:", e)
        return "Error during diagnosis."
