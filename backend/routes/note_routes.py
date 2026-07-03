from flask import Blueprint, jsonify, request

from services.note_service import (
    get_all_notes,
    create_note,
    delete_note
)

note_bp = Blueprint("notes", __name__)


@note_bp.route("/", methods=["GET"])
def home():
    """
    Home endpoint.
    """
    return "Application is running"


@note_bp.route("/health", methods=["GET"])
def health():
    """
    Health check endpoint.
    """
    return jsonify({
        "status": "ok"
    })


@note_bp.route("/notes", methods=["GET"])
def get_notes():
    """
    Return all notes.
    """

    return jsonify(
        get_all_notes()
    )


@note_bp.route("/notes", methods=["POST"])
def add_note():
    """
    Create a new note.
    """

    data = request.get_json()

    if not data:

        return jsonify({
            "success": False,
            "message": "Request body is required."
        }), 400

    text = data.get("text", "").strip()

    if text == "":

        return jsonify({
            "success": False,
            "message": "Note cannot be empty."
        }), 400

    note = create_note(text)

    return jsonify({
        "success": True,
        "message": "Note created successfully.",
        "note": note
    }), 201


@note_bp.route("/notes/<int:note_id>", methods=["DELETE"])
def remove_note(note_id):
    """
    Delete a note.
    """

    deleted = delete_note(note_id)

    if not deleted:

        return jsonify({
            "success": False,
            "message": "Note not found."
        }), 404

    return jsonify({
        "success": True,
        "message": "Note deleted successfully."
    }), 200