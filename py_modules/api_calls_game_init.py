#!/usr/bin/env python

from flask import Blueprint, jsonify

api_calls_game_init = Blueprint('api_calls_game_init', __name__)

@api_calls_game_init.route('/game_init/test')
def test_endpoint():
    return jsonify({'message': 'test init'})
