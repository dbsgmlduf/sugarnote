from flask import Flask, jsonify
from bloodsugar_delete import handle_delete_bloodsugar
from bloodsugar_insert import handle_insert_bloodsugar

app = Flask(__name__)

@app.route('/delete_bloodsugar', methods=['DELETE'])
def delete_bloodsugar_route():
    return handle_delete_bloodsugar()

@app.route('/insert_bloodsugar', methods=['POST'])
def handle_insert_bloodsugar():
    return handle_insert_bloodsugar()

if __name__ == '__main__':
    app.run(debug=True)
