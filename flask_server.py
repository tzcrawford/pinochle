#!/usr/bin/env python
import random
import os
import json
import pandas as pd
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

@app.route("/new_user", methods=['POST'])
def new_user():
    # Creates a new user in the database
    try:
        # Here we limit strings to X chars to prevent db insert truncation error
        username = request.json.get('valNewUserUsername')[:25]
        email    = request.json.get('valNewUserEmail')[:40]
        language = request.json.get('valNewUserLanguage')[:40]
        location = request.json.get('valNewUserLocation')[:25]
        country  = request.json.get('valNewUserCountry')[:2]
        password = request.json.get('valNewUserPassword')[:]
    except Exception as e:
        print("Exception in new user creation:", e)
        return "false" # We cannot return native python True/False values

    # Verify the username and password with a query to SQL.
    con = sc.SQLConnection()
    con.execute(f"\
        EXEC create_user (\
            '{username}','{email}','{language}','{country}',{config['staring_skill']})\
    ")
    userid_df = con.SELECT(f"\
        SELECT userid FROM users WHERE username = '{username}' LIMIT 1 \
    ")
    if userid_df < 1:
        print("Error in referencing newly created user.")
        return "false"
    else:
        userid = userid_df.iloc[0]['userid']
    con.select(f"\
        EXEC set_password({userid},NULL,{password}) \
    ")

@app.route("/countries")
def get_countries():
    # Gets a list of countries from the database
    con = sc.SQLConnection()
    countryData = con.select(f"\
        SELECT a.*,b.name AS continent_long_name \
        FROM countries AS a \
        LEFT JOIN continents AS b ON b.code = a.continent \
    ").to_dict('records')
    return jsonify(countryData), 200, {'Content-Type': 'application/json'}

@app.route("/languages", methods=['GET'])
def get_languages():
    # Gets a list of languages from the database
    con = sc.SQLConnection()
    langData = \
        con.select(f"\
            SELECT * FROM languages \
        ").to_dict('records')
    return jsonify(langData), 200, {'Content-Type': 'application/json'}

if __name__ == "__main__":
    app.run(debug=True)

