import pandas as pd
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score
import joblib
import os

# Define feature columns
features = [
    "mangal_dosha", "kaal_sarp",
    "varna", "vashya", "tara", "yoni",
    "graha_maitri", "gana", "bhakoot", "nadi"
]

# Simulate a training dataset (replace with real data if available)
data = pd.DataFrame([
    [0, 0, 1, 2, 3, 4, 5, 6, 3, 3, 1],
    [1, 0, 1, 1, 2, 3, 4, 4, 2, 1, 0],
    [0, 1, 1, 2, 3, 4, 3, 5, 2, 2, 1],
    [1, 1, 0, 1, 1, 2, 2, 2, 1, 0, 0],
], columns=features + ["match"])

X = data[features]
y = data["match"]

model = LogisticRegression()
model.fit(X, y)

# Save model
os.makedirs("models", exist_ok=True)
joblib.dump(model, "models/kundli_match_predictor.pkl")
print("✅ Model trained and saved.")
