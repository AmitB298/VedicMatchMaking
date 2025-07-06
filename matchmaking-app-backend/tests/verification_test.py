# verification_test.py
import unittest
import requests
import os

class VerificationServiceTest(unittest.TestCase):
    BASE_URL = 'http://localhost:5000'

    def test_verify_photo(self):
        with open('test_image.jpg', 'rb') as photo:
            response = requests.post(f'{self.BASE_URL}/verify', files={'photo': photo})
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertIn('photo', data)
        self.assertTrue(data['photo']['verified'])

    def test_verify_no_photo(self):
        response = requests.post(f'{self.BASE_URL}/verify')
        self.assertEqual(response.status_code, 400)

if __name__ == '__main__':
    unittest.main()
