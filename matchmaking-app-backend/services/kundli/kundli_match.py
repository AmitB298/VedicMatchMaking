import swisseph as swe
from datetime import datetime
import json

class KundliMatcher:
    def __init__(self, ephe_path='swiss_ephe'):
        swe.set_ephe_path(ephe_path)

    def generate_kundli(self, birth_date, birth_time, lat, lon):
        dt = datetime.strptime(f"{birth_date} {birth_time}", '%Y-%m-%d %H:%M:%S')
        jd = swe.julday(dt.year, dt.month, dt.day, dt.hour + dt.minute / 60.0)
        planets = {swe.get_planet_name(i): swe.calc_ut(jd, i)[0] for i in range(swe.SUN, swe.PLUTO + 1)}
        houses, ascmc = swe.houses(jd, lat, lon)
        moon_pos = planets['Moon'][0]
        rasi = int(moon_pos // 30) + 1
        nakshatra = int((moon_pos % 360) / (360/27)) + 1
        return {
            'planets': planets,
            'ascendant': ascmc[0],
            'houses': houses,
            'rasi': rasi,
            'nakshatra': nakshatra,
            'birth_details': {
                'date': birth_date,
                'time': birth_time,
                'latitude': lat,
                'longitude': lon,
            }
        }

    def match_kundli(self, k1, k2):
        def varna(r1, r2): return 1 if r1 % 4 == r2 % 4 else 0
        def vashya(r1, r2): return 2 if r1 % 5 == r2 % 5 else 0
        def tara(n1, n2): return 3 if abs(n1 - n2) % 9 in [0, 1] else 2 if abs(n1 - n2) % 9 in [2,3,4] else 1
        def yoni(n1, n2):
            ymap = [1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13,14]
            y1, y2 = ymap[n1-1], ymap[n2-1]
            if y1 == y2: return 4
            elif abs(y1 - y2) <= 2: return 2
            else: return 0
        def graha_maitri(r1, r2): return 5 if abs(r1 - r2) <= 2 or abs(r1 - r2) >= 10 else 2
        def gana(n1, n2):
            g1, g2 = (n1 - 1)//9, (n2 - 1)//9
            if g1 == g2: return 6
            elif {g1, g2} == {0, 1}: return 4
            else: return 0
        def bhakoot(r1, r2): return 0 if abs(r1 - r2) in [2, 4, 6, 8, 9, 11] else 7
        def nadi(n1, n2): return 0 if (n1 - 1)%3 == (n2 - 1)%3 else 8
        def mangal_dosha(k):
            mars = k['planets']['Mars'][0]
            return any(abs(h - mars) < 30 for h in [k['houses'][0], k['houses'][3], k['houses'][6], k['houses'][7], k['houses'][10]])

        scores = {
            'Varna': varna(k1['rasi'], k2['rasi']),
            'Vashya': vashya(k1['rasi'], k2['rasi']),
            'Tara': tara(k1['nakshatra'], k2['nakshatra']),
            'Yoni': yoni(k1['nakshatra'], k2['nakshatra']),
            'Graha Maitri': graha_maitri(k1['rasi'], k2['rasi']),
            'Gana': gana(k1['nakshatra'], k2['nakshatra']),
            'Bhakoot': bhakoot(k1['rasi'], k2['rasi']),
            'Nadi': nadi(k1['nakshatra'], k2['nakshatra'])
        }
        total = sum(scores.values())
        m1 = mangal_dosha(k1)
        m2 = mangal_dosha(k2)

        return {
            'scores': scores,
            'total_score': total,
            'mangal_dosha': {
                'person1': m1,
                'person2': m2,
                'compatible': not (m1 and m2)
            },
            'verdict': 'Excellent' if total >= 30 else 'Good' if total >= 24 else 'Average' if total >= 18 else 'Not Recommended'
        }

if __name__ == "__main__":
    matcher = KundliMatcher()
    person1 = matcher.generate_kundli("1990-01-01", "12:00:00", 28.6139, 77.2090)  # Delhi
    person2 = matcher.generate_kundli("1992-02-15", "14:30:00", 19.0760, 72.8777)  # Mumbai
    result = matcher.match_kundli(person1, person2)
    print(json.dumps(result, indent=2))
