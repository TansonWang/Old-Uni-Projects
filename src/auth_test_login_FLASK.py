import urllib
import flask
import json 
import pytest
import requests
import urllib.request
from .data import PORT

BASE_URL = 'http://127.0.0.1:' + str(PORT)
HEADER = {"Content-Type": "application/json"}

@pytest.fixture(autouse=True)
def reset_state():
    requests.post(BASE_URL + "/workspace/reset", json = ())
    reg1 = json.dumps({
        'email': 'first@first.com',
        'password': 'happydays',
        'name_first': 'James',
        'name_last': 'Lu'
    }).encode('utf-8')

    req = urllib.request.Request(f"{BASE_URL}/auth/register", headers=HEADER, data=reg1)
    payload_json = json.load(urllib.request.urlopen(req))
    #assert type(payload_json) == 'dict'
    u_id = payload_json['u_id']
    token = payload_json['token']

    return token, u_id

def test_logout_login_one_person(reset_state):
    token, u_id = reset_state
    req = requests.get(BASE_URL + '/users/all?token=' + str(token))
    USERS = req.json()['users']
    assert USERS[u_id]['email'] == 'first@first.com'
    assert len(USERS) == 1

    # Register a second user so you can always use USERS/all
    reg1 = json.dumps({
        'email': 'second@first.com',
        'password': 'happydays',
        'name_first': 'James',
        'name_last': 'Lu'
    }).encode('utf-8')

    req = urllib.request.Request(f"{BASE_URL}/auth/register", headers=HEADER, data=reg1)
    payload_json = json.load(urllib.request.urlopen(req))
    #assert type(payload_json) == 'dict'
    stable_token = payload_json['token']

    logout_token = json.dumps({
        'token': token
    }).encode('utf-8')
    req = urllib.request.Request(f"{BASE_URL}/auth/logout", headers=HEADER, data=logout_token)
    payload_json = json.load(urllib.request.urlopen(req))

    req = requests.get(BASE_URL + '/users/all?token=' + str(stable_token))
    USERS = req.json()['users']
    assert USERS[u_id]['token'] is None

    login_data = json.dumps({
        'email': 'first@first.com',
        'password': 'happydays'
    }).encode('utf-8')
    req = urllib.request.Request(f"{BASE_URL}/auth/login", headers=HEADER, data=login_data)
    user = json.load(urllib.request.urlopen(req))

    req = requests.get(BASE_URL + '/users/all?token=' + str(stable_token))
    USERS = req.json()['users']
    assert USERS[u_id]['token'] == user['token']

def test_logout_login_two_people(reset_state):
    token1, u_id1 = reset_state
    req = requests.get(BASE_URL + '/users/all?token=' + str(token1))
    USERS = req.json()['users']
    assert USERS[u_id1]['email'] == 'first@first.com'
    assert len(USERS) == 1

    # Register a second user so you can always use USERS/all
    reg1 = json.dumps({
        'email': 'second@first.com',
        'password': 'happydays',
        'name_first': 'James',
        'name_last': 'Lu'
    }).encode('utf-8')

    req = urllib.request.Request(f"{BASE_URL}/auth/register", headers=HEADER, data=reg1)
    payload_json = json.load(urllib.request.urlopen(req))
    token2 = payload_json['token']
    u_id2 = payload_json['u_id']

    # Logout user 1
    logout_token = json.dumps({
        'token': token1
    }).encode('utf-8')
    req = urllib.request.Request(f"{BASE_URL}/auth/logout", headers=HEADER, data=logout_token)
    payload_json = json.load(urllib.request.urlopen(req))

    # Assert user 1 token is gone
    req = requests.get(BASE_URL + '/users/all?token=' + str(token2))
    USERS = req.json()['users']
    assert USERS[u_id1]['token'] is None

    # Logout user 2
    logout_token = json.dumps({
        'token': token2
    }).encode('utf-8')
    req = urllib.request.Request(f"{BASE_URL}/auth/logout", headers=HEADER, data=logout_token)
    payload_json = json.load(urllib.request.urlopen(req))

    # Login user 1
    login_data = json.dumps({
        'email': 'first@first.com',
        'password': 'happydays'
    }).encode('utf-8')
    req = urllib.request.Request(f"{BASE_URL}/auth/login", headers=HEADER, data=login_data)
    user = json.load(urllib.request.urlopen(req))
    token1 = user['token']
    u_id1 = user['u_id']

    # Assert user 2 token is gone
    req = requests.get(BASE_URL + '/users/all?token=' + str(token1))
    USERS = req.json()['users']
    assert USERS[u_id2]['token'] is None

    # Login user 2
    login_data = json.dumps({
        'email': 'second@first.com',
        'password': 'happydays'
    }).encode('utf-8')
    req = urllib.request.Request(f"{BASE_URL}/auth/login", headers=HEADER, data=login_data)
    user = json.load(urllib.request.urlopen(req))
    token2 = user['token']
    u_id2 = user['u_id']
