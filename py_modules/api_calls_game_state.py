#!/usr/bin/env python

from flask import Blueprint, jsonify

api_calls_game_state = Blueprint('api_calls_game_state', __name__)

@api_calls_game_state.route('/game_state/test')
def test_endpoint():
    return jsonify({'message': 'test state'})
