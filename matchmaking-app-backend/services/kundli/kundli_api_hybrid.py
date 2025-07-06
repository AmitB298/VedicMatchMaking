from flask import Flask, request, jsonify
import joblib
import pandas as pd
import os
from kundli_match_full import match_kundli

app = Flask(__name__)

# Expected features for the AI model
expected_features = [
    "mangal_dosha", "kaal_sarp",
    "varna", "vashya", "tara", "yoni",
    "graha_maitri", "gana", "bhakoot", "nadi"
]

def prepare_features(result):
    try:
        doshas = result.get("doshas", {})
        guna = result.get("guna_breakdown", {})

        person1_dosha = doshas.get("person1", {})
        person2_dosha = doshas.get("person2", {})

        return {
            "mangal_dosha": int(person1_dosha.get("mangal_dosha", 0) or person2_dosha.get("mangal_dosha", 0)),
            "kaal_sarp": int(person1_dosha.get("kaal_sarp", 0) or person2_dosha.get("kaal_sarp", 0)),
            "varna": guna.get("varna", {}).get("score", 0),
            "vashya": guna.get("vashya", {}).get("score", 0),
            "tara": guna.get("tara", {}).get("score", 0),
            "yoni": guna.get("yoni", {}).get("score", 0),
            "graha_maitri": guna.get("graha_maitri", {}).get("score", 0),
            "gana": guna.get("gana", {}).get("score", 0),
            "bhakoot": guna.get("bhakoot", {}).get("score", 0),
            "nadi": guna.get("nadi", {}).get("score", 0)
        }, None
    except Exception as e:
        return None, f"❌ Exception during feature prep: {str(e)}"


@app.route("/api/kundli/hybrid", methods=["POST"])
def hybrid_kundli_api():
    data = request.get_json()

    if not data or "person1" not in data or "person2" not in data:
        return jsonify({"error": "❌ person1 and person2 fields required"}), 400

    person1 = data["person1"]
    person2 = data["person2"]

    vedic_result = match_kundli(person1, person2)
    guna_score = vedic_result.get("guna_score", 0)

    # Default outputs
    ai_score = -1
    nlp_score = -1
    explanation = []
    compatibility_score = guna_score
    verdict = "✅ Matched"

    features, error_msg = prepare_features(vedic_result)
    if not features:
        explanation.append(error_msg)
        verdict = "❌ Vedic data incomplete"
    else:
        try:
            model_path = os.path.join("models", "kundli_match_predictor.pkl")
            model = joblib.load(model_path)
            df = pd.DataFrame([features])[expected_features]
            ai_score = model.predict_proba(df)[0][1] * 100
            compatibility_score = round((guna_score * 2 + ai_score) / 3, 1)
        except Exception as e:
            explanation.append(f"⚠️ AI prediction failed: {str(e)}")
            verdict = "⚠️ Compatibility concerns"

    return jsonify({
        "vedic_score": guna_score,
        "ai_match_score": round(ai_score, 2),
        "nlp_score": nlp_score,
        "verdict": verdict,
        "explanation": explanation,
        "compatibility_score": round(compatibility_score, 1)
    })

if __name__ == "__main__":
    print("🚀 Starting Hybrid Kundli Match API...")
    app.run(debug=True, port=5055)
