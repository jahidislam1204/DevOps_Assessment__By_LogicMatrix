from data.notes import notes
import data.notes as note_data

from models.note import Note


def get_all_notes():
    """
    Return all notes.
    """

    return [note.to_dict() for note in notes]


def create_note(text):
    """
    Create a new note.
    """

    note = Note(

        note_id=note_data.next_note_id,

        text=text

    )

    notes.append(note)

    note_data.next_note_id += 1

    return note.to_dict()


def delete_note(note_id):
    """
    Delete a note by ID.
    """

    for note in notes:

        if note.id == note_id:

            notes.remove(note)

            return True

    return False


def get_note_by_id(note_id):
    """
    Find a note by ID.
    """

    for note in notes:

        if note.id == note_id:

            return note.to_dict()

    return None


def search_notes(keyword):
    """
    Search notes by keyword.
    """

    keyword = keyword.lower()

    result = []

    for note in notes:

        if keyword in note.text.lower():

            result.append(note.to_dict())

    return result


def total_notes():
    """
    Return total number of notes.
    """

    return len(notes)