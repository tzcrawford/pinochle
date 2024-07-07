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
from py_modules.api_calls_game_init import api_calls_game_init
from py_modules.api_calls_game_state import api_calls_game_state

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
        # Collect appropriate values from the form
        field_vals=dict()
        fields = \
            {'Username': 25, 'Email': 40,'Language':2,'Location': 25,'Country': 2,'Password': None}
        for key,val in fields.items():
            field_vals[key] = request.json.get('valNewUser'+key)
            if field_vals[key] is None or field_vals[key].strip() == "":
                field_vals[key] = 'NULL'
            else:
                if val: # Truncate the field entry if appropriate to prevent db insert truncation err
                    field_vals[key] = field_vals[key][:val]

                field_vals[key] = "'" + field_vals[key].strip() + "'"
        # Perform the SQL insertion
        con = sc.SQLConnection()
        con.execute(f"\
            SELECT * FROM \
            create_user(\
                {field_vals['Username']},{field_vals['Email']},{field_vals['Language']},{field_vals['Location']},{field_vals['Country']},{str(config['starting_skill'])})\
        ")
        
        # Verify the insertion worked correctly and get the userid of the newly created user.
        userid_df = con.select(f"\
            SELECT userid FROM users WHERE username = {field_vals['Username']} LIMIT 1 \
        ")
        if len(userid_df) < 1:
            raise Exception("Error in referencing newly created user.")
        else:
            userid = userid_df.iloc[0]['userid']
            print(f"User creation successful for userid: {str(userid)}")
        con.execute(f"\
            SELECT * FROM \
            set_password({str(userid)},NULL,{field_vals['Password']}) \
        ")
        print(f"User password set for userid: {str(userid)}")
        return "true"
    except Exception as e:
        print("Exception in new user creation:", e)
        if "duplicate key value violates unique constraint \"unique_username\"" in str(e):
            return "false", 403
        else:
            return "false", 500


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

@app.route("/user_stats", methods=['POST'])
def get_user_stats():
    username = request.json.get('username')
    con = sc.SQLConnection()
    langData = \
        con.select(f"\
            SELECT * FROM users_vw WHERE username = '{username}'\
        ").to_dict('records')
    return jsonify(langData), 200, {'Content-Type': 'application/json'}

for i in [api_calls_game_init,api_calls_game_state]:
    app.register_blueprint(i)

if __name__ == "__main__":
    app.run(debug=True)

