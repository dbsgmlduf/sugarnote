from flask import Flask, request, jsonify, make_response
import mysql.connector
from mysql.connector import Error
from bloodsugar_insert import insert_bloodsugar
from bloodsugar_delete import delete_bloodsugar
from bloodsugar_get import get_bloodsugar
app = Flask(__name__)

@app.route('/test') 
def main():
    success_message = "flask connect"
    return jsonify({
        'success_message': success_message
    })


@app.route('/insert_bloodsugar', methods=['POST'])
def handle_insert_bloodsugar():
    try:
        data = request.get_json()
        user_no = data['user_no']
        blood_sugar = data['blood_sugar']
        measure_date = data['measure_date']

        success, error = insert_bloodsugar(user_no, blood_sugar, measure_date)
        if success:
            return jsonify({'message': '혈당 정보 삽입 성공'})
        else:
            return jsonify({'message': '혈당 정보 삽입 실패', 'error': error}), 500
    except KeyError as e:
        return jsonify({'message': f'필수 데이터 누락: {str(e)}'}), 400 
    

@app.route('/delete_bloodsugar', methods=['delete'])
def handle_delete_bloodsugar():
    try:
        data = request.get_json()
        user_no = data['user_no']
        measure_date = data['measure_date']
        db_name = 'sugar_note'

        success,error = delete_bloodsugar(user_no, measure_date, db_name)
        if success :
            return jsonify({'message': '혈당 정보 삭제 성공'})
        else:
            return jsonify({'message': '혈당 정보 삭제 실패'}), 500
        
    except KeyError as e:
        return jsonify({'message': f'필수 데이터 누락: {str(e)}'}), 400
    except Exception as e:
        return jsonify({'message': '요청 처리 중 오류 발생', 'error': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True)

@app.route('/get_bloodsugar_data', methods=['GET'])
def get_data():
    user_no = request.args.get('user_no')
    measure_date = request.args.get('measure_date')

    if not user_no or not measure_date:
        return jsonify({'message': 'user_no와 measure_date를 제공해야 합니다.'}), 400

    result = get_bloodsugar(user_no, measure_date)

    if result:
        return jsonify(result)
    else:
        return jsonify({'message': '데이터 조회 실패'}), 404

if __name__ == '__main__':
    app.run(debug=True)