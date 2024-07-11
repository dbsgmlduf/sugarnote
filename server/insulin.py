import mysql.connector
from mysql.connector import Error
# 환경변수 설정
from dotenv import load_dotenv
import os


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

def get_injection(user_no, measure_date):
    try:
        connection = get_db_connection()
        if connection is not None:
            cursor = connection.cursor(dictionary=True)

            select_query = """
            SELECT * FROM INJECTION 
            WHERE user_no = %s AND measure_date = %s
            """
            cursor.execute(select_query, (user_no, measure_date))
            result = cursor.fetchone()

 
            if result is None:
                # 데이터가 없으면 테이블 생성 및 데이터 삽입
                insert_query = """
                INSERT INTO INJECTION (user_no, measure_date, measure)
                VALUES (%s, %s, %s)
                """
                cursor.execute(insert_query, (user_no, measure_date, "0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0"))
                connection.commit()

                # 생성된 데이터 다시 조회
                cursor.execute(select_query, (user_no, measure_date))
                result = cursor.fetchone()

            return result
    

    except Error as e:
        print("MySQL 데이터 조회 또는 테이블 생성 오류:", e)
        return None
    finally:
        if 'cursor' in locals() and cursor is not None:
            cursor.close()
        if 'connection' in locals() and connection.is_connected():
            connection.close()

#update insulin
def update_injection(user_no, new_measure, measure_date):
    try:
        connection = get_db_connection()
        if connection is not None:
            cursor = connection.cursor(dictionary=True)

            update_query = """
            UPDATE injection 
            SET measure = %s
            WHERE user_no = %s AND measure_date = %s
            """
            update_data = (new_measure,user_no,measure_date)

            cursor.execute(update_query,update_data)
            connection.commit()
            
            print(f'user_no{user_no}의 인슐린 투약 업데이트 완료')
            return True
        
    except Error as e:
        print("MySQL 데이터 삽입 오류:", e)
        return False
    finally:
        if 'cursor' in locals() and cursor is not None:
            cursor.close()
        if 'connection' in locals() and connection.is_connected():
            connection.close()