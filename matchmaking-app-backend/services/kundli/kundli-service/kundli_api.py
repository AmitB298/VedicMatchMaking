from flask import Flask, request, jsonify
from kundli_match_full import match_kundli

app = Flask(__name__)

# Health check endpoint
@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({"status": "ok", "message": "Kundli Match API healthy"}), 200

# Root endpoint for easy testing
@app.route('/', methods=['GET'])
def index():
    return jsonify({"status": "running", "message": "Welcome to the Kundli Match API"}), 200

# Main matching endpoint
@app.route('/api/kundli/match', methods=['POST'])
def kundli_match_api():
    try:
        data = request.get_json()
        if not data:
            return jsonify({'error': 'Missing JSON body'}), 400

        if 'person1' not in data or 'person2' not in data:
            return jsonify({'error': 'Missing required fields: person1 and person2'}), 400

        person1 = data['person1']
        person2 = data['person2']

        # Call your matching function
        result = match_kundli(person1, person2)

        return jsonify({"status": "success", "data": result}), 200

    except Exception as e:
        import traceback
        traceback.print_exc()
        return jsonify({'status': 'error', 'message': str(e)}), 500

if __name__ == '__main__':
    print("🚀 Starting Kundli Match API on port 5055...")
    app.run(debug=True, host='0.0.0.0', port=5055)
