#!/usr/bin/env python
import random
import os
import json
from flask import Flask, request, jsonify, send_from_directory, send_file
from flask_jwt_extended import JWTManager, create_access_token
from flask_cors import CORS, cross_origin
import keyring
import sql_connect as sc

config_file = "config.json"

with open(config_file) as config_json:
    config = json.load(config_json)

# Collect password for db queries
db_password = keyring.get_password

app = Flask(__name__)

CORS(app) # For Cross-Origin Resource Sharing between flask and svelte
    # Specifically, it applies CORS header 'Access-Control-Allow-Origin' to allow data transfer between servers if on different machines (?)
    # Other method would be to use cross_origin decorator along with @app.route
    # https://flask-cors.readthedocs.io/en/latest/

# For JSON Web Token (JWT) authentication (on subsequent requests).
jwt = JWTManager(app) 
if 'JWT_secret_key' in config and config['JWT_secret_key'] is not None:
    app.config['SECRET_KEY'] = config['JWT_secret_key']
else:
    app.config['SECRET_KEY'] = os.urandom(24) 
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

@app.route('/config')
def get_config():
    try:
        return send_file('config.json', mimetype='application/json')
    except FileNotFoundError:
        return jsonify({'error': 'Config file not found'}), 404

@app.route("/login", methods=['POST'])
def login():
    try:
        username = request.json.get('valLoginUsername')
        password = request.json.get('valLoginPassword')
    except:
        return "false" # We cannot return native python True/False values

    # Verify the username and password with a query to SQL.
    con = sc.SQLConnection()
    #userID = con.execute(f"\
    #    SELECT userid \
    #    FROM users \
    #    WHERE username = {username} \
    #    LIMIT 1 \
    #")
    pass_auth_df = con.select(f"\
        SELECT pass_auth('{username}', '{password}') \
    ")

    if len(pass_auth_df) > 0:
        access_token=create_access_token(identity=username) # May need to do something more comprehensive here depending on if we want to define it on a databased ID or something like that.
        print(jsonify({'access_token': access_token, 'username': username}))
        return jsonify({'access_token': access_token, 'username': username}), 200
    else:
        return jsonify({'message': 'Invalid credentials'}), 401

if __name__ == "__main__":
    app.run(debug=True)

