from flask import Flask, request, jsonify, make_response
import mysql.connector
from mysql.connector import Error
from bloodsugar_insert import update_bloodsugar_measure
from bloodsugar_get import get_bloodsugar
from user_insert import insert_user,get_user
from insulin import get_injection,update_injection
from mets_function import add_exercise,get_exercise
from gpt_answer import counseling
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

        result = insert_user(name, age, height, weight, ID, PW)

        if result == True:
            return jsonify({'message': '1'})
        elif result == "EXIST":
            return jsonify({'message': '2'})
        else:
            return jsonify({'message': '0'})
        
    except Exception as error:
        return jsonify({'message': '0'})
    
#로그인
@app.route('/get_user', methods=['POST'])
def get_user_route():
    try:
        data = request.get_json()
        ID = data['ID']
        PW = data['PW']

        success, result = get_user(ID, PW)

        if success:
            return jsonify({'message': '1', 'user': result})
        else:
            return jsonify({'message': '0'})
        
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
    
        success= update_bloodsugar_measure(user_no, new_measure, measure_date)

        if success:
            return jsonify({"message": "1"})
         
    except Exception as error:
        return jsonify({'message': '0'})

@app.route('/get_bloodsugar', methods=['POST'])
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
    

    #인슐린 투약 테이블 생성
@app.route('/get_injection', methods=['POST'])
    
def get_injection_route():
    data = request.get_json()
    user_no = data['user_no']
    measure_date = data['measure_date']

    if not user_no or not measure_date:
        return jsonify({'message': 'user_no와 measure_date를 제공해야 합니다.'})

    injection_data = get_injection(user_no, measure_date)

    if injection_data:
        response = {
            'message':'1',
            'user_no': injection_data['user_no'],
            'measure_date': injection_data['measure_date'],
            'injection': injection_data['measure'],
        }
        return jsonify(response)
    else:
        return jsonify({'message': '0'})
    
@app.route('/update_injection', methods=['POST'])
def update_injection_route():
    try:
        data = request.json
        user_no = data['user_no']
        new_measure = data['new_measure']
        measure_date = data['measure_date']
    
        success = update_injection(user_no, new_measure, measure_date)

        if success:
            response = {
                'message': '1',
                'user_no': user_no,
                'measure_date': measure_date,
                'new_measure': new_measure,
            }
            return jsonify(response)
        else:
            return jsonify({'message': '0'})
         
    except Exception as error:
        return jsonify({'message': '0', 'error_message': str(error)})
    
#운동량 계산 후 기입    
@app.route('/add_exercise', methods=['POST'])
def add_exercise_route():
    try:
        data = request.json
        user_no = data.get('user_no')
        exercise = data.get('exercise')
        exercise_time = data.get('exercise_time')
        measure_date = data.get('measure_date')

        result, status_code = add_exercise(user_no, exercise, exercise_time, measure_date)
        return jsonify(result), status_code

    except Exception as error:
        return jsonify({'message': '0'})
    
@app.route('/get_exercise', methods=['POST'])
def get_exercise_route():
    try:
        data = request.json
        user_no = data.get('user_no')
        measure_date = data.get('measure_date')

        if not user_no or not measure_date:
            return jsonify({"error": "user_no and measure_date parameters are required"}), 400

        exercise_details = get_exercise(user_no,measure_date)

        if exercise_details:
            return jsonify({'message' : '1'},exercise_details)

        return jsonify({'message':'0'})
    except Exception as error:
        return jsonify({'message': '0'})
    

# 건강 진단 API 엔드포인트
@app.route('/counseling', methods=['POST'])
def counseling_route():
    try: 
        data = request.json
        user_no = data.get('user_no')
        measure_date = data.get('measure_date')
        #counsel = data.get('counsel')

    # 상담 기능 함수 호출
        response = counseling(user_no, measure_date)

        # 결과 반환
        if not response:
            return jsonify({'error': '2'}), 808

        return jsonify(response)

    except Exception as error:
        return jsonify({'error': str(error)}), 500

if __name__ == '__main__':
    app.run(debug=True)