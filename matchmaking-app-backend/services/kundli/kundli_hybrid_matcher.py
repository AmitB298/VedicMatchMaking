import json
import os
import joblib
import pandas as pd
from kundli_match_full import match_kundli

# -------------------------
# 1. Input
# -------------------------
person1 = {
    "name": "Amit Sharma",
    "birth_date": "1990-01-01",
    "birth_time": "12:00:00",
    "latitude": 28.6139,
    "longitude": 77.2090
}

person2 = {
    "name": "Anita Patel",
    "birth_date": "1992-05-10",
    "birth_time": "15:30:00",
    "latitude": 19.0760,
    "longitude": 72.8777
}

# -------------------------
# 2. Name and Caste Parsing
# -------------------------
def extract_name_parts(full_name):
    parts = full_name.strip().split(" ")
    return parts[0], parts[-1] if len(parts) > 1 else parts[0]

name1, surname1 = extract_name_parts(person1["name"])
name2, surname2 = extract_name_parts(person2["name"])

caste_map = {
    "Sharma": "Brahmin from North India",
    "Patel": "Patidar from Gujarat",
    "Verma": "Kayastha",
    "Yadav": "Ahir",
    "Reddy": "Reddy from South India",
    "Singh": "Kshatriya",
    "Iyer": "Tamil Brahmin"
}

caste1 = caste_map.get(surname1, "Unknown caste")
caste2 = caste_map.get(surname2, "Unknown caste")

# -------------------------
# 3. Vedic Match Calculation
# -------------------------
vedic_result = match_kundli(person1, person2)
guna_score = vedic_result.get("guna_score", 0)
doshas = vedic_result.get("doshas", {})
guna = vedic_result.get("guna_breakdown", {})

# -------------------------
# 4. Feature Preparation
# -------------------------
expected_features = [
    "mangal_dosha", "kaal_sarp",
    "varna", "vashya", "tara", "yoni",
    "graha_maitri", "gana", "bhakoot", "nadi"
]

explanation = []
remedies = []
guna_explanations = []

def prepare_features(explanation_list):
    try:
        return {
            "mangal_dosha": int(doshas.get("person1", {}).get("mangal_dosha", 0) or doshas.get("person2", {}).get("mangal_dosha", 0)),
            "kaal_sarp": int(doshas.get("person1", {}).get("kaal_sarp", 0) or doshas.get("person2", {}).get("kaal_sarp", 0)),
            "varna": guna.get("varna", {}).get("score", 0),
            "vashya": guna.get("vashya", {}).get("score", 0),
            "tara": guna.get("tara", {}).get("score", 0),
            "yoni": guna.get("yoni", {}).get("score", 0),
            "graha_maitri": guna.get("graha_maitri", {}).get("score", 0),
            "gana": guna.get("gana", {}).get("score", 0),
            "bhakoot": guna.get("bhakoot", {}).get("score", 0),
            "nadi": guna.get("nadi", {}).get("score", 0)
        }
    except Exception as e:
        explanation_list.append(f"❌ Feature preparation failed: {str(e)}")
        return None

# -------------------------
# 5. Caste Insight
# -------------------------
if caste1 != caste2:
    explanation.append(
        f"⚠️ Cross-caste match: {person1['name']} is {caste1} and {person2['name']} is {caste2}. "
        f"Social integration might need open dialogue, especially in traditional families."
    )

# -------------------------
# 6. Guna Matching Analysis
# -------------------------
for guna_key in expected_features[2:]:  # skip doshas
    score = guna.get(guna_key, {}).get("score", 0)
    if score == 0:
        guna_explanations.append(f"❌ {guna_key.title()} does not match — potential area of incompatibility.")
    else:
        guna_explanations.append(f"✅ {guna_key.title()} matched — strength in this compatibility area.")

# -------------------------
# 7. Dosha & Remedies
# -------------------------
if doshas.get("person1", {}).get("mangal_dosha") or doshas.get("person2", {}).get("mangal_dosha"):
    explanation.append("⚠️ Mangal Dosha detected — may impact harmony, especially post-marriage.")
    remedies.append("🔥 Suggestion: Perform Mangal Dosh Nivaran Puja before marriage.")

if guna.get("nadi", {}).get("score", 1) == 0:
    explanation.append("⚠️ Nadi Dosha detected — can affect progeny and health.")
    remedies.append("🌿 Suggestion: Consult priest for Nadi Shanti rituals.")

if guna.get("varna", {}).get("score", 1) < 2:
    explanation.append(f"⚠️ Low Varna match between {name1} and {name2} can lead to ego or social friction.")
    remedies.append("🧘 Practice humility-building rituals together and avoid dominance games.")

# -------------------------
# 8. AI Prediction
# -------------------------
features = prepare_features(explanation)
ai_score = -1
nlp_score = -1
compatibility_score = guna_score
verdict = "✅ Matched"

if features:
    try:
        model = joblib.load(os.path.join("models", "kundli_match_predictor.pkl"))
        df = pd.DataFrame([features])[expected_features]
        ai_score = model.predict_proba(df)[0][1] * 100
        compatibility_score = round((guna_score * 2 + ai_score) / 3, 1)
    except Exception as e:
        explanation.append(f"⚠️ AI prediction failed: {str(e)}")
        verdict = "⚠️ Compatibility concerns"
else:
    explanation.append("❌ Could not prepare features for AI scoring.")
    verdict = "❌ Vedic data incomplete"

# -------------------------
# 9. Final Output
# -------------------------
result = {
    "vedic_score": guna_score,
    "ai_match_score": round(ai_score, 2),
    "nlp_score": nlp_score,
    "verdict": verdict,
    "guna_analysis": guna_explanations,
    "explanation": explanation,
    "remedies": remedies,
    "compatibility_score": compatibility_score
}

print(json.dumps(result, indent=2))
