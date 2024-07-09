from flask import Flask, jsonify,request,make_response
from bloodsugar_delete import delete_bloodsugar
from bloodsugar_insert import insert_bloodsugar

app = Flask(__name__)


@app.route('/insert_bloodsugar', methods=['POST'])
def insert_bloodsugar_route():
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

if __name__ == '__main__':
    app.run(debug=True)