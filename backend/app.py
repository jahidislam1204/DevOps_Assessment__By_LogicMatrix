from flask import Flask
from flask_cors import CORS

from config import Config
from routes.note_routes import note_bp


def create_app():

    app = Flask(__name__)

    app.config["SECRET_KEY"] = Config.SECRET_KEY

    CORS(app)

    app.register_blueprint(note_bp)

    return app


app = create_app()


if __name__ == "__main__":

    app.run(

        host=Config.HOST,

        port=Config.PORT,

        debug=Config.DEBUG

    )