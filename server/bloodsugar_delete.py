from flask import request, jsonify
import mysql.connector
from mysql.connector import Error

def delete_bloodsugar(user_no, measure_date):
    try:
        connection = mysql.connector.connect(
            host='localhost',
            database = 'sugar_note',
            user='root',
            password='010319'
        )

        if connection.is_connected():
            cursor = connection.cursor()

            delete_query = """
            DELETE FROM bloodsugar
            WHERE user_no = %s AND measure_date = %s
            """
            delete_data = (user_no, measure_date)

            cursor.execute(delete_query, delete_data)
            connection.commit()

            print(f"user_no {user_no}, measure_date {measure_date}의 정보 삭제 완료")
            return True,None

    except Error as e:
        print("MySQL 연결 오류:", e)
        return False,str(e)

    finally:
        if 'cursor' in locals() and cursor is not None:
            cursor.close()
        if 'connection' in locals() and connection.is_connected():
            connection.close()

