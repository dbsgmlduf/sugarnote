import mysql.connector
from mysql.connector import Error
import datetime
# 환경변수 설정
from dotenv import load_dotenv
import os

# MySQL 연결 설정
def get_db_connection():
    try:
        connection = mysql.connector.connect(
            host=os.environ.get('DB_HOST'),
            database=os.environ.get('DB_DATABASE'),
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
        cursor = connection.cursor(dictionary=True)

        formatted_measure_date = datetime.datetime.strptime(measure_date, '%Y-%m-%d').date().strftime('%Y-%m')

        select_query = """
        SELECT * FROM injection 
        WHERE user_no = %s 
        AND DATE_FORMAT(measure_date, '%Y-%m') = %s
        """
        cursor.execute(select_query, (user_no, formatted_measure_date))

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
                cursor.execute(select_query, (user_no, formatted_measure_date))
                result = cursor.fetchone()

        return result
    
    except Error as e:
        print("MySQL 데이터 조회 또는 테이블 생성 오류:", e)
        return None
    finally:
        if cursor:
            cursor.close()
        if connection and connection.is_connected():
            connection.close()

def update_injection(user_no, new_measure, measure_date):
    try:
        connection = get_db_connection()
        if connection is not None:
            cursor = connection.cursor(dictionary=True)

            formatted_measure_date = datetime.datetime.strptime(measure_date, '%Y-%m-%d').date()
            
            update_query = """
            UPDATE INJECTION 
            SET measure = %s, measure_date = %s
            WHERE user_no = %s AND DATE_FORMAT(measure_date, '%Y-%m') = %s
            """
            cursor.execute(update_query, (new_measure, formatted_measure_date, user_no, formatted_measure_date.strftime('%Y-%m')))
            connection.commit()
            
            print(f'user_no {user_no}의 인슐린 투약 업데이트 완료')
            return True
        
    except Error as e:
        print("MySQL 데이터 삽입 오류:", e)
        return False
    finally:
        if cursor:
            cursor.close()
        if connection and connection.is_connected():
            connection.close()