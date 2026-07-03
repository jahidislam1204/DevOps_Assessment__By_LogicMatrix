import unittest

from app import create_app


class AppTestCase(unittest.TestCase):
    def setUp(self):
        app = create_app()
        self.client = app.test_client()

    def test_health_endpoint_returns_ok(self):
        response = self.client.get("/health")

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.get_json(), {"status": "ok"})

    def test_get_notes_returns_a_list(self):
        response = self.client.get("/notes")

        self.assertEqual(response.status_code, 200)
        self.assertIsInstance(response.get_json(), list)

    def test_add_note_rejects_empty_payload(self):
        response = self.client.post("/notes", json={"text": "   "})

        self.assertEqual(response.status_code, 400)
        self.assertFalse(response.get_json()["success"])


if __name__ == "__main__":
    unittest.main()
