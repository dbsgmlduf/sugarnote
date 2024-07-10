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
