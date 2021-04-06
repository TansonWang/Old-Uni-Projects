import json
import urllib.request
import pytest
import requests
from .error import AccessError, InputError
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

    # Register a user
    req = urllib.request.Request(f"{BASE_URL}/auth/register", headers=HEADER, data=reg1)
    payload_json = json.load(urllib.request.urlopen(req))
    #assert type(payload_json) == 'dict'
    u_id = payload_json['u_id']
    token = payload_json['token']

    return token, u_id

# Actual functions
def test_valid_email_change(reset_state):
    token, u_id = reset_state
    req = requests.get(BASE_URL + '/users/all?token=' + str(token))
    USERS = req.json()['users']

    #assert type(USERS[0]) == 'dict'
    assert USERS[u_id]['email'] == 'first@first.com'

    data = json.dumps({
        'token': token,
        'email': 'second@second.com'
    }).encode('utf-8')
    #requests.put(f"{BASE_URL}/user/profile/setemail", json=data)
    req = urllib.request.Request(f"{BASE_URL}/user/profile/setemail", headers=HEADER, data=data, method='PUT')
    json.load(urllib.request.urlopen(req))

    req = requests.get(BASE_URL + '/users/all?token=' + str(token))
    USERS = req.json()['users']

    assert USERS[u_id]['email'] == 'second@second.com'

def test_already_active_email(reset_state):
    token, u_id = reset_state
    req = requests.get(BASE_URL + '/users/all?token=' + str(token))
    USERS = req.json()['users']

    # assert type(user_dict) == 'dict'
    assert USERS[u_id]['email'] == 'first@first.com'

    data = json.dumps({
        'token': token,
        'email': 'first@first.com'
    }).encode('utf-8')

    req = urllib.request.Request(f"{BASE_URL}/user/profile/setemail", headers=HEADER, data=data, method='PUT')

    with pytest.raises(urllib.error.HTTPError) as e:
        json.load(urllib.request.urlopen(req))

def test_invalid_email(reset_state):
    token, u_id = reset_state
    req = requests.get(BASE_URL + '/users/all?token=' + str(token))
    USERS = req.json()['users']
    assert USERS[u_id]['email'] == 'first@first.com'

    data = json.dumps({
        'token': token,
        'email': 'lolwutisemail'
    }).encode('utf-8')
    req = urllib.request.Request(f"{BASE_URL}/user/profile/setemail", headers=HEADER, data=data, method='PUT')

    with pytest.raises(urllib.error.HTTPError) as e:
        json.load(urllib.request.urlopen(req))
