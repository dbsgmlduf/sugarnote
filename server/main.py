from flask import Flask, request, jsonify, make_response
import mysql.connector
from mysql.connector import Error
from bloodsugar_insert import insert_bloodsugar,update_bloodsugar_measure
from bloodsugar_get import get_bloodsugar
from user_insert import insert_user


app = Flask(__name__)

@app.route('/test') 
def main():
    success_message = "flask connect"
    return jsonify({
        'success_message': success_message
    })

#user 삽입
@app.route('/insert_user', methods=['POST'])
def insert_user_route():
    try:
        data = request.get_json()
        name = data['name']
        age = data['age']
        height = data['height']
        weight = data['weight']
        ID = data['ID']
        PW = data['PW']

        success = insert_user(name,age,height, weight,ID,PW)

        if success:
            return jsonify({'message': '1'})
        
    except Exception as error:
        return jsonify({'message': '0'})

#혈당 테이블 생성
@app.route('/insert_bloodsugar', methods=['POST'])
def handle_insert_bloodsugar():
    try:
        data = request.get_json()
        user_no = data['user_no']
        measure_date = data['measure_date']
        measure = data['measure']

        success = insert_bloodsugar(user_no,measure_date,measure)
        if success:
            return jsonify({'message': '1'})
        
    except Exception as error:
        return jsonify({'message': '0'})
    

    
#혈당 데이터 업데이트
@app.route('/update_bloodsugar', methods=['POST'])
def update_measure_route():
    try:
        data = request.json
        user_no = data['user_no']
        new_measure = data['new_measure']
        measure_date = data['measure_date']
    
        success, error = update_bloodsugar_measure(user_no, new_measure, measure_date)
    
        if not user_no or not new_measure or not measure_date:
            return jsonify({"message":'0'})

        if success:
            return jsonify({"message": "1"})
         
    except Exception as error:
        return jsonify({'message': '0'})

@app.route('/get_bloodsugar', methods=['GET'])
def get_bloodsugar_route():
    data = request.get_json()
    user_no = data['user_no']
    measure_date = data['measure_date']

    if not user_no or not measure_date:
        return jsonify({'message': 'user_no와 measure_date를 제공해야 합니다.'})

    bloodsugar_data = get_bloodsugar(user_no, measure_date)

    if bloodsugar_data:
        response = {
            'message':'1',
            'user_no': bloodsugar_data['user_no'],
            'measure_date': bloodsugar_data['measure_date'],
            'blood_sugar': bloodsugar_data['measure'],
        }
        return jsonify(response)
    else:
        return jsonify({'message': '0'})

if __name__ == '__main__':
    app.run(debug=True)