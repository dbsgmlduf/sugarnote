from flask import Flask, request, jsonify
import mysql.connector
from mysql.connector import Error

app = Flask(__name__)

# MySQL 연결 설정
def get_db_connection():
    try:
        connection = mysql.connector.connect(
            host='localhost',
            database='sugar_note',
            user='root',
            password='010319'
        )
        return connection
    except Error as e:
        print("MySQL 연결 오류:", e)
        return None

# 사용자 정보 삽입 함수
def insert_into_userinfo(user_name, gender, age, weight):
    try:
        connection = get_db_connection()
        if connection is not None:
            cursor = connection.cursor()

            # userinfo 테이블에 데이터 삽입
            insert_query = """
            INSERT INTO userinfo (user_name, gender, age, weight)
            VALUES (%s, %s, %s, %s)
            """
            record = (user_name, gender, age, weight)

            cursor.execute(insert_query, record)
            connection.commit()

            return True
    except Error as e:
        print("MySQL 데이터 삽입 오류:", e)
        return False
    finally:
        if 'cursor' in locals() and cursor is not None:
            cursor.close()
        if 'connection' in locals() and connection.is_connected():
            connection.close()

@app.route('/')
def hello():
    return 'Hello World'

# Flask 라우트 정의 - 사용자 정보 삽입 엔드포인트
@app.route('/insert_userinfo', methods=['POST'])
def insert_userinfo():
    data = request.get_json()
    user_name = data['user_name']
    gender = data['gender']
    age = data['age']
    weight = data['weight']

    if insert_into_userinfo(user_name, gender, age, weight):
        response = {'message': '사용자 정보 삽입 성공'}
    else:
        response = {'message': '사용자 정보 삽입 실패'}

    return jsonify(response)

if __name__ == '__main__':
    app.run(debug=True)
