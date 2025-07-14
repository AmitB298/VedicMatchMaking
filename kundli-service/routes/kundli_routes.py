from flask import Blueprint, request, jsonify
from controllers.kundli_controller import generate_kundli

kundli_bp = Blueprint('kundli', __name__)

@kundli_bp.route('/generate', methods=['POST'])
def generate():
    data = request.json
    result = generate_kundli(data)
    return jsonify(result)
