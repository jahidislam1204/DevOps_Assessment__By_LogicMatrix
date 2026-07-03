"""
Temporary in-memory storage for notes.

This will be replaced with AWS RDS MySQL
in a future version of the application.
"""

from models.note import Note


# In-memory note storage
notes = []


# Auto-increment ID counter
next_note_id = 1