from flask import Flask, request, jsonify
from kundli_service import KundliService

app = Flask(__name__)
service = KundliService()

@app.route("/generate-kundli", methods=["POST"])
def generate_kundli():
    data = request.get_json()
    birth_date = data.get("date")
    birth_time = data.get("time")
    latitude = data.get("latitude")
    longitude = data.get("longitude")

    try:
        result = service.generate_kundli(birth_date, birth_time, latitude, longitude)
        return jsonify(result)
    except Exception as e:
        return jsonify({"error": str(e)}), 400

@app.route("/match-kundli", methods=["POST"])
def match_kundli():
    data = request.get_json()
    kundli1 = data.get("kundli1")
    kundli2 = data.get("kundli2")
    try:
        result = service.match_kundli(kundli1, kundli2)
        return jsonify(result)
    except Exception as e:
        return jsonify({"error": str(e)}), 400

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5055)
