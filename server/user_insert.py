import mysql.connector
from mysql.connector import Error
# 환경변수 설정
from dotenv import load_dotenv
import os

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

# 사용자 정보 삽입 함수
def insert_user(name,age,height, weight,ID,PW):
    try:
        connection = get_db_connection()
        if connection is not None:
            cursor = connection.cursor()

            # userinfo 테이블에 데이터 삽입
            insert_query = """
            INSERT INTO user (name,age,height, weight,ID,PW)
            VALUES (%s, %s, %s, %s, %s, %s)
            """
            record = (name,age,height, weight,ID,PW)

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

