from flask import request, jsonify
import mysql.connector
from mysql.connector import Error

def delete_bloodsugar(user_no, measure_date, db_name):
    try:
        connection = mysql.connector.connect(
            host='localhost',
            database=db_name,
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
            return True

    except Error as e:
        print("MySQL 연결 오류:", e)
        return False

    finally:
        if 'cursor' in locals() and cursor is not None:
            cursor.close()
        if 'connection' in locals() and connection.is_connected():
            connection.close()
            print("MySQL 연결 종료")

def handle_delete_bloodsugar():
    try:
        data = request.get_json()
        user_no = data['user_no']
        measure_date = data['measure_date']
        db_name = 'sugar_note'  # 데이터베이스 이름을 여기서 설정

        if delete_bloodsugar(user_no, measure_date, db_name):
            return jsonify({'message': '혈당 정보 삭제 성공'})
        else:
            return jsonify({'message': '혈당 정보 삭제 실패'}), 500

    except Exception as e:
        return jsonify({'message': '요청 처리 중 오류 발생', 'error': str(e)}), 500
