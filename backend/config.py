import os


class Config:
    """
    Base configuration for the NoteApp backend.
    """

    # ============================
    # Flask Configuration
    # ============================

    HOST = "0.0.0.0"
    PORT = 8080
    DEBUG = True

    SECRET_KEY = os.getenv(
        "SECRET_KEY",
        "noteapp-secret-key"
    )

    # ============================
    # Database Configuration
    # (Currently unused)
    # ============================

    DB_HOST = os.getenv(
        "DB_HOST",
        "localhost"
    )

    DB_PORT = os.getenv(
        "DB_PORT",
        "3306"
    )

    DB_NAME = os.getenv(
        "DB_NAME",
        "noteapp"
    )

    DB_USER = os.getenv(
        "DB_USER",
        "root"
    )

    DB_PASSWORD = os.getenv(
        "DB_PASSWORD",
        ""
    )

    # Future SQLAlchemy URI
    SQLALCHEMY_DATABASE_URI = (
        f"mysql+pymysql://"
        f"{DB_USER}:{DB_PASSWORD}"
        f"@{DB_HOST}:{DB_PORT}"
        f"/{DB_NAME}"
    )

    SQLALCHEMY_TRACK_MODIFICATIONS = False