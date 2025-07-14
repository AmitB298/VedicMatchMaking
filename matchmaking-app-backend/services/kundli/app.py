from flask import Flask, request, jsonify
from kundli_service import KundliService

app = Flask(__name__)
service = KundliService()

@app.route('/')
def index():
    return jsonify({"status": "Kundli Service is running"}), 200

@app.route('/generate', methods=['POST'])
def generate_kundli():
    data = request.get_json()
    try:
        result = service.generate_kundli(
            data["birth_date"],
            data["birth_time"],
            data["latitude"],
            data["longitude"]
        )
        return jsonify(result)
    except Exception as e:
        return jsonify({"error": str(e)}), 400

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
