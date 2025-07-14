from flask import Flask, request, jsonify
app = Flask(__name__)
@app.route('/api/kundli', methods=['POST'])
def generate_kundli():
    data = request.json
    return jsonify({
        'status': 'success',
        'details': f'Advanced Kundli generated for {data.get("name", "Unknown")}'
    })
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3000)
