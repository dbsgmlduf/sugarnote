from flask import Flask, request, jsonify
import mysql.connector
from mysql.connector import Error
# 환경변수 설정
from dotenv import load_dotenv
import os

app = Flask(__name__)
load_dotenv()

# MySQL 연결 설정
def get_db_connection():
    try:
        
        connection = mysql.connector.connect(
            host = os.environ.get('DB_HOST'),
            database = os.environ.get('DB_DATABASE'),
            user=os.environ.get('DB_USER'),
            password=os.environ.get('DB_PASSWORD')
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
