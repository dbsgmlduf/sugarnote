from flask import Flask, request, jsonify
import mysql.connector
from mysql.connector import Error

# 데이터베이스에 데이터 삽입
def insert_bloodsugar(user_no, blood_sugar, measure_date):
    try:
        connection = mysql.connector.connect(
            host='localhost',
            database='sugar_note',
            user='root',
            password='010319'
        )
        if connection is not None:
            cursor = connection.cursor()
            
            insert_query = """
            INSERT INTO bloodsugar (user_no, blood_sugar, measure_date)
            VALUES (%s, %s, %s)
            """
            record = (user_no, blood_sugar, measure_date)

            cursor.execute(insert_query, record)
            connection.commit()

            return True, None
    except Error as e:
        print("MySQL 데이터 삽입 오류:", e)
        return False, str(e)
    finally:
        if 'cursor' in locals() and cursor is not None:
            cursor.close()
        if 'connection' in locals() and connection.is_connected():
            connection.close()



    