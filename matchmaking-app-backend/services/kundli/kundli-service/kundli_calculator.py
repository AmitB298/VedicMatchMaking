import swisseph as swe
import sys
import json

def calculate_kundli(birth_date, birth_time, latitude, longitude):
    jd = swe.julday(*map(int, birth_date.split('-')), float(birth_time.split(':')[0]) + float(birth_time.split(':')[1])/60)
    
    planet_positions = {}
    for planet_id in range(1, 11):
        position = swe.calc(jd, planet_id)
        planet_positions[planet_id] = position[0]

    houses = swe.houses(jd, lat=latitude, lon=longitude)
    ascendant = houses[0][0]

    moon_position = planet_positions[2]
    nakshatra = get_nakshatra(moon_position)

    return json.dumps({
        "planet_positions": planet_positions,
        "ascendant": ascendant,
        "nakshatra": nakshatra
    })

def get_nakshatra(moon_position):
    nakshatras = [
        "Ashwini", "Bharani", "Krittika", "Rohini", "Mrigashira", "Ardra", "Punarvasu",
        "Pushya", "Ashlesha", "Magha", "Purvaphalguni", "UttaraPhalguni", "Hasta", "Chitra",
        "Swati", "Vishakha", "Anuradha", "Jyeshtha", "Mula", "Purvashadha", "UttaraAshadha",
        "Shravana", "Dhanishta", "Shatabhisha", "Purvabhadrapada", "UttaraBhadrapada", "Revati"
    ]
    nakshatra_index = int(moon_position // 13.3333)
    return nakshatras[nakshatra_index]

if __name__ == "__main__":
    birth_date = sys.argv[1]
    birth_time = sys.argv[2]
    latitude = float(sys.argv[3])
    longitude = float(sys.argv[4])
    print(calculate_kundli(birth_date, birth_time, latitude, longitude))
