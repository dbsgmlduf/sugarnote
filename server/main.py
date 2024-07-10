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
            return jsonify({'message': '1'})
        else:
            return jsonify({'message': '00'})
        
    except Exception as error:
        return jsonify({'message': '0'})
    

@app.route('/delete_bloodsugar', methods=['delete'])
def handle_delete_bloodsugar():
    try:
        data = request.get_json()
        user_no = data['user_no']
        measure_date = data['measure_date']

        success,error = delete_bloodsugar(user_no, measure_date)
        if success :
            return jsonify({'message': '1'})
        
    except Exception as e:
        return jsonify({'message' : '0'})

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
            'blood_sugar': bloodsugar_data['blood_sugar'],
        }
        return jsonify(response)
    else:
        return jsonify({'message': '0'})

if __name__ == '__main__':
    app.run(debug=True)