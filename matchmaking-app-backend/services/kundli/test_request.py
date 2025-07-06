# test_request.py
import requests

url = "http://127.0.0.1:5055/api/kundli/hybrid"

payload = {
    "person1": {
        "name": "Amit",
        "birth_date": "1990-01-01",
        "birth_time": "12:00:00",
        "latitude": 28.6139,
        "longitude": 77.2090
    },
    "person2": {
        "name": "Anita",
        "birth_date": "1992-05-10",
        "birth_time": "15:30:00",
        "latitude": 19.0760,
        "longitude": 72.8777
    }
}

response = requests.post(url, json=payload)

print("✅ API Response:")
print(response.json())
