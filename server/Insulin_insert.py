from flask import Flask, request, jsonify
import mysql.connector

app = Flask(__name__)

current_insulin_inject = {}

def get_next_insulin_inject(user_no):
    if user_no in current_insulin_inject:
        current_insulin_inject[user_no] += 1
        if current_insulin_inject[user_no] > 30:
            current_insulin_inject[user_no] = 1
    else:
        current_insulin_inject[user_no] = 1
    
    return current_insulin_inject[user_no]

@app.route('/add_insulin', methods=['POST'])
def add_insulin():
    data = request.json
    user_no = data['user_no']
    measure_date = data['measure_date']
    db_name = 'sugar_note'

    next_insulin_inject = get_next_insulin_inject(user_no)
    if next_insulin_inject is None:
        return jsonify({'error': 'Failed to get next insulin inject value'}), 500

    try:
        connection = mysql.connector.connect(
            host='localhost',
            database='sugar_note',
            user='root',
            password='010319'
        )

        if connection.is_connected():
            cursor = connection.cursor()

            # Insert new data
            insert_query = """
            INSERT INTO Insulin (user_no, Insulin_inject, measure_date)
            VALUES (%s, %s, %s)
            """
            cursor.execute(insert_query, (user_no, next_insulin_inject, measure_date))
            connection.commit()
            return jsonify({'message': 'Insulin data added successfully'})

    except mysql.connector.Error as e:
        print("MySQL 연결 오류:", e)
        return jsonify({'error': 'Failed to add Insulin data'}), 500

    finally:
        if 'cursor' in locals() and cursor is not None:
            cursor.close()
        if 'connection' in locals() and connection.is_connected():
            connection.close()

if __name__ == '__main__':
    app.run(debug=True)
