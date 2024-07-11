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

# 일별 혈당 업데이트(-1,-1,-1,-1,-1,-1)부분
def update_bloodsugar_measure(user_no, new_measure, measure_date):
    try:
        connection = get_db_connection()
        if connection is not None:
            cursor = connection.cursor(dictionary=True)

            update_query = """
            UPDATE bloodsugar 
            SET measure = %s
            WHERE user_no = %s AND measure_date = %s
            """
            update_data = (new_measure,user_no,measure_date)

            cursor.execute(update_query,update_data)
            connection.commit()
            
            print(f'user_no{user_no}의 혈당 업데이트 완료')
            return True
        
    except Error as e:
        print("MySQL 데이터 삽입 오류:", e)
        return False
    finally:
        if 'cursor' in locals() and cursor is not None:
            cursor.close()
        if 'connection' in locals() and connection.is_connected():
            connection.close()
