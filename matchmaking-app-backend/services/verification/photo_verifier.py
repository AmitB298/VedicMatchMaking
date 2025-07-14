from flask import Flask, request, jsonify
from PIL import Image
import os

app = Flask(__name__)

UPLOAD_FOLDER = "uploads"
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

@app.route("/")
def healthcheck():
    return jsonify({"status": "ok", "message": "Photo Verifier Service Running"}), 200

@app.route("/verify", methods=["POST"])
def verify_photo():
    if "photo" not in request.files:
        return jsonify({"error": "No photo file provided"}), 400

    photo = request.files["photo"]
    if photo.filename == "":
        return jsonify({"error": "Empty filename"}), 400

    save_path = os.path.join(UPLOAD_FOLDER, photo.filename)
    photo.save(save_path)

    try:
        with Image.open(save_path) as img:
            img.verify()
        return jsonify({
            "status": "success",
            "message": "Photo uploaded and verified",
            "filename": photo.filename
        }), 200
    except Exception as e:
        return jsonify({"error": f"Image verification failed: {str(e)}"}), 400

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
