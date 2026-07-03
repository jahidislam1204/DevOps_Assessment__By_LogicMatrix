from datetime import datetime


class Note:
    """
    Represents a single note.
    """

    def __init__(self, note_id: int, text: str):

        self.id = note_id

        self.text = text

        self.created_at = datetime.now()

    def to_dict(self):
        """
        Convert the Note object to a dictionary.
        """

        return {
            "id": self.id,
            "text": self.text,
            "createdAt": self.created_at.isoformat()
        }