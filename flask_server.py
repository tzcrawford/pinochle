#!/usr/bin/env python
from flask import Flask, send_from_directory
from flask_cors import CORS, cross_origin
import random

app = Flask(__name__)
CORS(app) # For Cross-Origin Resource Sharing between flask and svelte
    # Specifically, it applies CORS header 'Access-Control-Allow-Origin' to allow data transfer between servers if on different machines (?)
    # Other method would be to use cross_origin decorator along with @app.route
    # https://flask-cors.readthedocs.io/en/latest/

# Path for our main Svelte page
@app.route("/")
def base():
    return send_from_directory('./public', 'index.html')

# Path for all the static files (compiled JS/CSS, etc.)
@app.route("/<path:path>")
def home(path):
    return send_from_directory('./public', path)

@app.route("/rand")
def hello():
    return str(random.randint(0, 100))

if __name__ == "__main__":
    app.run(debug=True)

