#!/usr/bin/env python
import random
import os
from flask import Flask, request, jsonify, send_from_directory
from flask_jwt_extended import JWTManager, create_access_token
from flask_cors import CORS, cross_origin

app = Flask(__name__)
CORS(app) # For Cross-Origin Resource Sharing between flask and svelte
    # Specifically, it applies CORS header 'Access-Control-Allow-Origin' to allow data transfer between servers if on different machines (?)
    # Other method would be to use cross_origin decorator along with @app.route
    # https://flask-cors.readthedocs.io/en/latest/
jwt = JWTManager(app) # For JSON Web Token authentication (on subsequent requests).
app.config['SECRET_KEY'] = os.urandom(24) # Need this key for JWT.
    # Code generates a 192 bit random string, which should be suitible to regenerate every time the server script restarts.
    # This is because if the server restarts, user tokens should be reset.

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

@app.route("/login", methods=['POST'])
def login():
    try:
        username = request.json.get('valLoginUsername')
        password = request.json.get('valLoginPassword')
    except:
        return "false" # We cannot return native python True/False vals
    if username == "a" and password =="b":
        return jsonify(
            access_token=create_access_token(identity=
                username # May need to do something more comprehensive here depending on if we want to define it on a databased ID or something like that.
            )
        ), 200
    else:
        return jsonify({'message': 'Invalid credentials'}), 401

if __name__ == "__main__":
    app.run(debug=True)

