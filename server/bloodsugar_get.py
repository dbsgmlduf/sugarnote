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

# 데이터베이스에서 데이터 조회
def get_bloodsugar(user_no, measure_date):
    try:
        connection = get_db_connection()
        if connection is not None:
            cursor = connection.cursor(dictionary=True)

            # bloodsugar 테이블에서 데이터 조회
            select_query = """
            SELECT * FROM bloodsugar 
            WHERE user_no = %s AND measure_date = %s
            """
            cursor.execute(select_query, (user_no, measure_date))
            result = cursor.fetchone()

            return result
    except Error as e:
        print("MySQL 데이터 조회 오류:", e)
        return None
    finally:
        if 'cursor' in locals() and cursor is not None:
            cursor.close()
        if 'connection' in locals() and connection.is_connected():
            connection.close()

@app.route('/')
def hello():
    return 'Hello, World!'

# Flask 라우트 정의
@app.route('/get_data', methods=['GET'])
def get_data():
    user_no = request.args.get('user_no')
    measure_date = request.args.get('measure_date')

    if not user_no or not measure_date:
        return jsonify({'message': 'user_no와 measure_date를 제공해야 합니다.'}), 400

    result = get_bloodsugar(user_no, measure_date)

    if result:
        return jsonify(result)
    else:
        return jsonify({'message': '데이터 조회 실패'}), 404

if __name__ == '__main__':
    app.run(debug=True)
