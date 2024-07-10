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


# 데이터베이스에 데이터 삽입
def insert_bloodsugar(user_no, measure_date,measure):
    try:
        connection = get_db_connection()
        if connection is not None:
            cursor = connection.cursor(dictionary=True)

            insert_query = """
            INSERT INTO bloodsugar (user_no, measure_date,measure)
            VALUES (%s, %s,%s)
            """
            record = (user_no, measure_date,-1,-1,-1,-1,-1,-1)

            cursor.execute(insert_query, record)
            connection.commit()

            return True, None
    except Exception as e:
        print("MySQL 데이터 삽입 오류:", e)
        return False, str(e)
    finally:
        if 'cursor' in locals() and cursor is not None:
            cursor.close()
        if 'connection' in locals() and connection.is_connected():
            connection.close()



# 일별 혈당 업데이트(-1,-1,-1,-1,-1,-1)부분
def update_bloodsugar_measure(user_no, new_measure, measure_date):
    try:
        connection = get_db_connection()
        if connection is not None:
            cursor = connection.cursor(dictionary=True)

            # 특정 measure_date의 기존 measure 값을 가져오기
            select_query = "SELECT measure FROM bloodsugar WHERE user_no = %s AND measure_date = %s"
            cursor.execute(select_query, (user_no, measure_date))
            result = cursor.fetchone()

            if result is None:
                return False, "No record found for the given user_no and measure_date"

            current_measures = result['measure'].split(',')
            if len(current_measures) != 6:
                return False

            # 새로운 measure 값 추가
            for i in range(6):
                if current_measures[i] == '-1':
                    current_measures[i] = str(new_measure)
                    break
            if '-1' not in current_measures:
                return False
        
            updated_measures = ','.join(current_measures)

            # measure 값 업데이트
            update_query = "UPDATE bloodsugar SET measure = %s WHERE user_no = %s AND measure_date = %s"
            cursor.execute(update_query, (updated_measures, user_no, measure_date))
            connection.commit()

            return True, None
    except Exception as e:
        print("MySQL 데이터 업데이트 오류:", e)
        return False, str(e)
    finally:
        if 'cursor' in locals() and cursor is not None:
            cursor.close()
        if 'connection' in locals() and connection.is_connected():
            connection.close()
