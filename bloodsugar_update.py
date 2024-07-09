from flask import Flask, request, jsonify
import mysql.connector
from mysql.connector import Error

app = Flask(__name__)

def update_bloodsugar(user_no, new_blood_sugar, measure_date, db_name):
    try:
        connection = mysql.connector.connect(
            host='localhost',
            database=db_name,
            user='root',
            password='010319'
        )

        if connection.is_connected():
            cursor = connection.cursor()

            # bloodsugar 테이블 업데이트
            update_query = """
            UPDATE bloodsugar
            SET blood_sugar = %s, measure_date = %s
            WHERE user_no = %s
            """
            update_data = (new_blood_sugar, measure_date, user_no)

            cursor.execute(update_query, update_data)
            connection.commit()

            print(f"user_no {user_no}의 정보 업데이트 완료")
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

@app.route('/update_bloodsugar', methods=['POST'])
def update_bloodsugar_endpoint():
    data = request.get_json()

    user_no = data.get('user_no')
    new_blood_sugar = data.get('new_blood_sugar')
    measure_date = data.get('measure_date')
    db_name = data.get('db_name', 'sugar_note')  # 기본 데이터베이스 이름 설정

    if update_bloodsugar(user_no, new_blood_sugar, measure_date, db_name):
        return jsonify({'message': '혈당 측정 정보 업데이트 성공'}), 200
    else:
        return jsonify({'message': '혈당 측정 정보 업데이트 실패'}), 500

if __name__ == "__main__":
    app.run(debug=True)
