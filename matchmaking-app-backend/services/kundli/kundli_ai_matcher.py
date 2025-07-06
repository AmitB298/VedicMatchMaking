# kundli_ai_matcher.py

import swisseph as swe
import datetime
from typing import Dict, Any
import joblib
import numpy as np

# Load ML model (dummy path for now, replace with real)
try:
    astro_ml_model = joblib.load("models/kundli_match_predictor.pkl")
except Exception as e:
    astro_ml_model = None
    print(f"[ML] Warning: Could not load model: {e}")

class KundliAIEngine:
    def __init__(self):
        swe.set_ephe_path("ephemeris/")

    def parse_datetime(self, birth_date: str, birth_time: str) -> datetime.datetime:
        return datetime.datetime.strptime(f"{birth_date} {birth_time}", "%Y-%m-%d %H:%M:%S")

    def get_planet_positions(self, dt: datetime.datetime, lat: float, lon: float) -> Dict[str, float]:
        jd = swe.julday(dt.year, dt.month, dt.day, dt.hour + dt.minute / 60.0 + dt.second / 3600.0)
        flag = swe.FLG_SWIEPH | swe.FLG_SPEED
        positions = {}
        for planet in [swe.SUN, swe.MOON, swe.MARS, swe.MERCURY, swe.JUPITER, swe.VENUS, swe.SATURN, swe.MEAN_NODE]:  # Ketu will be calculated manually
            pos, _ = swe.calc_ut(jd, planet, flag)
            positions[swe.get_planet_name(planet)] = pos[0]
        return positions

    def compute_ashtakoota_score(self, boy_pos: Dict[str, float], girl_pos: Dict[str, float]) -> Dict[str, Any]:
        # Placeholder for real Vedic rules
        scores = {
            "varna": {"score": 1, "matched": True},
            "vashya": {"score": 2, "matched": True},
            "tara": {"score": 3, "matched": True},
            "yoni": {"score": 4, "matched": True},
            "graha_maitri": {"score": 5, "matched": True},
            "gana": {"score": 6, "matched": True},
            "bhakoot": {"score": 3, "matched": True},
            "nadi": {"score": 3, "matched": True},
        }
        return scores

    def detect_doshas(self, positions: Dict[str, float]) -> Dict[str, bool]:
        # Placeholder Dosha detection logic
        return {
            "mangal_dosha": False,
            "kaal_sarp": False
        }

    def run_ml_prediction(self, boy_pos: Dict[str, float], girl_pos: Dict[str, float]) -> float:
        if not astro_ml_model:
            return -1
        vec = np.array(list(boy_pos.values()) + list(girl_pos.values())).reshape(1, -1)
        try:
            score = astro_ml_model.predict_proba(vec)[0][1]  # probability of high compatibility
            return round(score * 100, 2)
        except Exception as e:
            print(f"[ML] Prediction error: {e}")
            return -1

    def match_kundli(self, boy: Dict[str, Any], girl: Dict[str, Any]) -> Dict[str, Any]:
        boy_dt = self.parse_datetime(boy['birth_date'], boy['birth_time'])
        girl_dt = self.parse_datetime(girl['birth_date'], girl['birth_time'])
        
        boy_pos = self.get_planet_positions(boy_dt, boy['latitude'], boy['longitude'])
        girl_pos = self.get_planet_positions(girl_dt, girl['latitude'], girl['longitude'])

        ashtakoota = self.compute_ashtakoota_score(boy_pos, girl_pos)
        guna_score = sum(v['score'] for v in ashtakoota.values())

        doshas = {
            "person1": self.detect_doshas(boy_pos),
            "person2": self.detect_doshas(girl_pos)
        }

        ml_score = self.run_ml_prediction(boy_pos, girl_pos)

        return {
            "guna_score": guna_score,
            "guna_breakdown": ashtakoota,
            "doshas": doshas,
            "ai_match_score": ml_score,
            "verdict": self._verdict_text(guna_score, ml_score, doshas)
        }

    def _verdict_text(self, guna: float, ai: float, dosha: Dict[str, Any]) -> str:
        if ai >= 80 and guna >= 25:
            return "🌟 Excellent match: High astrological & emotional compatibility."
        elif guna >= 18 and ai >= 60:
            return "✅ Good match with positive future indicators."
        elif ai == -1:
            return "⚠️ ML score unavailable, fallback to Vedic compatibility only."
        else:
            return "⚠️ Caution advised: consult astrologer for remedy or second opinion."


# If running as test
if __name__ == '__main__':
    matcher = KundliAIEngine()
    boy = {
        "name": "Amit",
        "birth_date": "1990-01-01",
        "birth_time": "12:00:00",
        "latitude": 28.6139,
        "longitude": 77.2090
    }
    girl = {
        "name": "Anita",
        "birth_date": "1992-05-10",
        "birth_time": "15:30:00",
        "latitude": 19.0760,
        "longitude": 72.8777
    }
    print(matcher.match_kundli(boy, girl))

