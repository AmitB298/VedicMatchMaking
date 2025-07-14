import swisseph as swe
from datetime import datetime

class KundliService:
    def __init__(self, ephe_path="swiss_ephe"):
        swe.set_ephe_path(ephe_path)

    def generate_kundli(self, birth_date, birth_time, latitude, longitude):
        dt = datetime.strptime(f"{birth_date} {birth_time}", "%Y-%m-%d %H:%M:%S")
        jd = swe.julday(dt.year, dt.month, dt.day, dt.hour + dt.minute / 60.0)
        planets = {}
        for i in range(swe.SUN, swe.PLUTO + 1):
            pos = swe.calc_ut(jd, i)[0]
            planets[swe.get_planet_name(i)] = pos
        asc = swe.houses(jd, latitude, longitude, b'P')[1][0]
        return {
            "planets": planets,
            "ascendant": asc,
            "birth_details": {
                "date": birth_date,
                "time": birth_time,
                "latitude": latitude,
                "longitude": longitude
            }
        }

    def match_kundli(self, kundli1, kundli2):
        return {"compatibility_score": 0.8}
