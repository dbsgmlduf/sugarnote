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
    
# METS 값을 하드코딩한 딕셔너리
METS_VALUES = {
    'running': 9.8,
    'swimming': 7.9,
    'cycling': 7.5,
    'walking': 3.8,
    # 추가할 운동과 그에 따른 METS 값을 여기에 추가하세요.
}
def add_exercise(user_no, exercise, exercise_time, measure_date):
    try:
        connection = get_db_connection()
        if connection is not None:
            cursor = connection.cursor(dictionary=True)

            # Retrieve the corresponding METS value from the mets table
            mets_query = "SELECT table_no, mets FROM mets WHERE exercise = %s"
            cursor.execute(mets_query, (exercise,))
            mets_result = cursor.fetchone()
            if not mets_result:
                return {"error": "Exercise not found"}, 404

            table_no = mets_result['table_no']
            mets = mets_result['mets']

            # Retrieve the user's weight
            user_query = "SELECT weight FROM User WHERE user_no = %s"
            cursor.execute(user_query, (user_no,))
            user_result = cursor.fetchone()
            if not user_result:
                return {"error": "User not found"}, 404

            weight = user_result['weight']
            kcal = mets * weight * (exercise_time / 60)

            # Insert the exercise record
            insert_query = """
            INSERT INTO Exercise (user_no, exercise, exercise_time, measure_date, kcal)
            VALUES (%s, %s, %s, %s, %s)
            """
            insert_data = (user_no, table_no, exercise_time, measure_date, kcal)
            cursor.execute(insert_query, insert_data)
            connection.commit()

            return {
                "user_no": user_no,
                "exercise": exercise,
                "exercise_time": exercise_time,
                "kcal": kcal,
                "measure_date": measure_date
            }, 201

    except Exception as e:
        print("MySQL 데이터 처리 오류:", e)
        return {"error": "Database error"}, 500
    finally:
        if 'cursor' in locals() and cursor is not None:
            cursor.close()
        if 'connection' in locals() and connection.is_connected():
            connection.close()

def get_sum_kcal(user_no, measure_date):
    try:
        connection = get_db_connection()
        if connection is not None:
            cursor = connection.cursor(dictionary=True)

            # Query to calculate sum of kcal for the given user_no
            sum_kcal_query = """
            SELECT user_no, SUM(kcal) AS sum_kcal
            FROM Exercise
            WHERE user_no = %s AND measure_date = %s
            GROUP BY user_no
            """
            cursor.execute(sum_kcal_query, (user_no, measure_date))
            sum_kcal_result = cursor.fetchone()

            if sum_kcal_result:
                return sum_kcal_result['sum_kcal']
            else:
                return 0  # If no records found, return 0 kcal

    except Exception as e:
        print("MySQL 데이터 처리 오류:", e)
        return None
    finally:
        if 'cursor' in locals() and cursor is not None:
            cursor.close()
        if 'connection' in locals() and connection.is_connected():
            connection.close()
            

# 유저 총 칼로리 합 계산
def get_sum_kcal(user_no, measure_date):
    try:
        connection = get_db_connection()
        if connection is not None:
            cursor = connection.cursor(dictionary=True)

            # Query to calculate sum of kcal for the given user_no
            sum_kcal_query = """
            SELECT user_no, SUM(kcal) AS sum_kcal
            FROM Exercise
            WHERE user_no = %s AND measure_date = %s
            GROUP BY user_no
            """
            cursor.execute(sum_kcal_query, (user_no, measure_date))
            sum_kcal_result = cursor.fetchone()

            if sum_kcal_result:
                return sum_kcal_result['sum_kcal']
            else:
                return 0  # If no records found, return 0 kcal

    except Exception as e:
        print("MySQL 데이터 처리 오류:", e)
        return None
    finally:
        if 'cursor' in locals() and cursor is not None:
            cursor.close()
        if 'connection' in locals() and connection.is_connected():
            connection.close()


def get_exercise(user_no, measure_date):
    try:
        connection = get_db_connection()
        if connection is not None:
            cursor = connection.cursor(dictionary=True)

            exercise_query = """
            SELECT user_no,
	        m.exercise AS exercise,
            e.exercise_time,
		    e.kcal
            FROM 
            exercise e
            JOIN 
            mets m ON e.exercise = m.table_no
            WHERE 
            e.user_no = %s
            AND e.measure_date = %s;
            """

            cursor.execute(exercise_query, (user_no, measure_date))
            exercise_results = cursor.fetchall()

            if not exercise_results:
                return {"error": "No exercise records found for the user on the specified date"}, None
            total_kcal = get_sum_kcal(user_no, measure_date)

            # Prepare response data
            exercise_details = []
            for result in exercise_results:
                exercise_details.append({
                    "exercise": result['exercise'],
                    "exercise_time": result['exercise_time'],
                    "kcal": result['kcal']
                })

            return {
                "user_no": user_no,
                "measure_date": measure_date,
                "exercise_details": exercise_details,
                "total_kcal": total_kcal
            }

    except Exception as e:
        print("MySQL 데이터 처리 오류:", e)
        return {"error": "Database error"}, None
    finally:
        if 'cursor' in locals() and cursor is not None:
            cursor.close()
        if 'connection' in locals() and connection.is_connected():
            connection.close()