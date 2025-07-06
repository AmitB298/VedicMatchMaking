# kundli_service_test.py
import unittest
from kundli_service import KundliService

class KundliServiceTest(unittest.TestCase):
    def setUp(self):
        self.service = KundliService()

    def test_generate_kundli(self):
        kundli = self.service.generate_kundli("1990-01-01", "12:00:00", 28.6139, 77.2090)
        self.assertIn("planets", kundli)
        self.assertIn("Sun", kundli["planets"])
        self.assertIn("ascendant", kundli)

if __name__ == '__main__':
    unittest.main()
