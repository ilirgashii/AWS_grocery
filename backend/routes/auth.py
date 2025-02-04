from flask import Blueprint, request, jsonify

auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    # Your registration logic here
    return jsonify({"message": "Registration endpoint hit"}), 200

@auth_bp.route('/login', methods=['POST'])
def login():
    # Your login logic here
    return jsonify({"message": "Login endpoint hit"}), 200 