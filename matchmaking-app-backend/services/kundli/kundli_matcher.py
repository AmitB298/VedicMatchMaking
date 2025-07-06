# kundli_matcher.py
import swisseph as swe
import datetime
from typing import Dict, Any

class KundliMatcher:
    def __init__(self):
        swe.set_ephe_path("ephemeris/")  # Swiss Ephemeris data folder

    def parse_datetime(self, birth_date: str, birth_time: str) -> datetime.datetime:
        dt_str = f"{birth_date} {birth_time}"
        return datetime.datetime.strptime(dt_str, "%Y-%m-%d %H:%M:%S")

    def get_planet_positions(self, dt: datetime.datetime, lat: float, lon: float) -> Dict[str, float]:
        jd = swe.julday(dt.year, dt.month, dt.day, dt.hour + dt.minute / 60.0 + dt.second / 3600.0)
        flag = swe.FLG_SWIEPH | swe.FLG_SPEED
        planet_positions = {}
        for planet in [swe.SUN, swe.MOON, swe.MARS, swe.MERCURY, swe.JUPITER, swe.VENUS, swe.SATURN]:
            pos, _ = swe.calc_ut(jd, planet, flag)
            planet_positions[swe.get_planet_name(planet)] = pos[0]
        return planet_positions

    def ashtakoota_score(self, boy_data, girl_data) -> int:
        # Placeholder logic for demo
        return 22

    def detect_mangal_dosha(self, data: Dict[str, Any]) -> bool:
        # Placeholder — advanced logic to be added later
        return False

    def check_kaal_sarp_dosha(self, data: Dict[str, Any]) -> bool:
        # Placeholder
        return False

    def compute_dasha_compatibility(self, boy_data: Dict[str, Any], girl_data: Dict[str, Any]) -> int:
        # Placeholder: Based on Mahadasha lord or Nakshatra matching
        return 2

    def navamsa_chart(self, dt: datetime.datetime, lat: float, lon: float) -> str:
        # Placeholder
        return "Scorpio Navamsa"

    def match(self, boy: Dict[str, Any], girl: Dict[str, Any]) -> Dict[str, Any]:
        boy_dt = self.parse_datetime(boy["birth_date"], boy["birth_time"])
        girl_dt = self.parse_datetime(girl["birth_date"], girl["birth_time"])

        boy_pos = self.get_planet_positions(boy_dt, boy["latitude"], boy["longitude"])
        girl_pos = self.get_planet_positions(girl_dt, girl["latitude"], girl["longitude"])

        ashta_score = self.ashtakoota_score(boy, girl)
        mangal_boy = self.detect_mangal_dosha(boy)
        mangal_girl = self.detect_mangal_dosha(girl)
        kaal_sarp_boy = self.check_kaal_sarp_dosha(boy)
        kaal_sarp_girl = self.check_kaal_sarp_dosha(girl)
        dasha_score = self.compute_dasha_compatibility(boy, girl)

        return {
            "guna_score": ashta_score,
            "mangal_dosha": {
                "person1": mangal_boy,
                "person2": mangal_girl,
                "compatible": not (mangal_boy or mangal_girl)
            },
            "kaal_sarp_dosha": {
                "person1": kaal_sarp_boy,
                "person2": kaal_sarp_girl
            },
            "dasha_koota_score": dasha_score,
            "navamsa": {
                "person1": self.navamsa_chart(boy_dt, boy["latitude"], boy["longitude"]),
                "person2": self.navamsa_chart(girl_dt, girl["latitude"], girl["longitude"])
            },
            "verdict": "Good compatibility with minor remedies." if not (mangal_boy or mangal_girl) else "Moderate match. Mangal Dosha detected."
        }
