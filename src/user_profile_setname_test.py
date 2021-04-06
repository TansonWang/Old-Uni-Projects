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
def test_valid_name_change(reset_state):
    token, u_id = reset_state
    req = requests.get(BASE_URL + '/users/all?token=' + str(token))
    USERS = req.json()['users']

    # assert type(user_dict) == 'dict'
    assert USERS[u_id]['name_first'] == 'James'
    assert USERS[u_id]['name_last'] == 'Lu'

    data = json.dumps({
        'token': token,
        'name_first': 'Hard Pressed',
        'name_last': 'Left 4 Dead'
    }).encode('utf-8')

    req = urllib.request.Request(f"{BASE_URL}/user/profile/setname", headers=HEADER, data=data, method='PUT')
    json.load(urllib.request.urlopen(req))

    req = requests.get(BASE_URL + '/users/all?token=' + str(token))
    USERS = req.json()['users']

    assert USERS[u_id]['name_first'] == 'Hard Pressed'
    assert USERS[u_id]['name_last'] == 'Left 4 Dead'

def test_invalid_token(reset_state):
    token, u_id = reset_state
    req = requests.get(BASE_URL + '/users/all?token=' + str(token))
    USERS = req.json()['users']

    assert USERS[u_id]['name_first'] == 'James'
    assert USERS[u_id]['name_last'] == 'Lu'

    data = json.dumps({
        'token': 'qwerqwer',
        'name_first': 'Hard Pressed',
        'name_last': 'Left 4 Dead'
    }).encode('utf-8')

    req = urllib.request.Request(f"{BASE_URL}/user/profile/setname", headers=HEADER, data=data, method='PUT')
    with pytest.raises(urllib.error.HTTPError) as e:
        json.load(urllib.request.urlopen(req))

def test_short_first_name(reset_state):
    token, u_id = reset_state
    req = requests.get(BASE_URL + '/users/all?token=' + str(token))
    USERS = req.json()['users']

    # assert type(user_dict) == 'dict'
    assert USERS[u_id]['name_first'] == 'James'
    assert USERS[u_id]['name_last'] == 'Lu'

    data = json.dumps({
        'token': token,
        'name_first': 'A',
        'name_last': 'Lu'
    }).encode('utf-8')
    #requests.put(f"{BASE_URL}/user/profile/setemail", json=data)
    req = urllib.request.Request(f"{BASE_URL}/user/profile/setname", headers=HEADER, data=data, method='PUT')
    json.load(urllib.request.urlopen(req))

    req = requests.get(BASE_URL + '/users/all?token=' + str(token))
    USERS = req.json()['users']

    assert USERS[u_id]['name_first'] == 'A'
    assert USERS[u_id]['name_last'] == 'Lu'

def test_too_short_first_name(reset_state):
    token, u_id = reset_state
    req = requests.get(BASE_URL + '/users/all?token=' + str(token))
    USERS = req.json()['users']

    assert USERS[u_id]['name_first'] == 'James'
    assert USERS[u_id]['name_last'] == 'Lu'

    data = json.dumps({
        'token': token,
        'name_first': '',
        'name_last': 'Left 4 Dead'
    }).encode('utf-8')

    req = urllib.request.Request(f"{BASE_URL}/user/profile/setname", headers=HEADER, data=data, method='PUT')
    with pytest.raises(urllib.error.HTTPError) as e:
        json.load(urllib.request.urlopen(req))

def test_long_first_name(reset_state):
    token, u_id = reset_state
    req = requests.get(BASE_URL + '/users/all?token=' + str(token))
    USERS = req.json()['users']

    # assert type(user_dict) == 'dict'
    assert USERS[u_id]['name_first'] == 'James'
    assert USERS[u_id]['name_last'] == 'Lu'

    data = json.dumps({
        'token': token,
        'name_first': 'A' * 50,
        'name_last': 'Lu'
    }).encode('utf-8')
    #requests.put(f"{BASE_URL}/user/profile/setemail", json=data)
    req = urllib.request.Request(f"{BASE_URL}/user/profile/setname", headers=HEADER, data=data, method='PUT')
    json.load(urllib.request.urlopen(req))

    req = requests.get(BASE_URL + '/users/all?token=' + str(token))
    USERS = req.json()['users']

    assert USERS[u_id]['name_first'] == 'A' * 50
    assert USERS[u_id]['name_last'] == 'Lu'

def test_too_long_first_name(reset_state):
    token, u_id = reset_state
    req = requests.get(BASE_URL + '/users/all?token=' + str(token))
    USERS = req.json()['users']

    assert USERS[u_id]['name_first'] == 'James'
    assert USERS[u_id]['name_last'] == 'Lu'

    data = json.dumps({
        'token': token,
        'name_first': 'A' * 51,
        'name_last': 'Left 4 Dead'
    }).encode('utf-8')

    req = urllib.request.Request(f"{BASE_URL}/user/profile/setname", headers=HEADER, data=data, method='PUT')
    with pytest.raises(urllib.error.HTTPError) as e:
        json.load(urllib.request.urlopen(req))

def test_short_last_name(reset_state):
    token, u_id = reset_state
    req = requests.get(BASE_URL + '/users/all?token=' + str(token))
    USERS = req.json()['users']

    # assert type(user_dict) == 'dict'
    assert USERS[u_id]['name_first'] == 'James'
    assert USERS[u_id]['name_last'] == 'Lu'

    data = json.dumps({
        'token': token,
        'name_first': 'Hard Pressed',
        'name_last': 'A'
    }).encode('utf-8')
    #requests.put(f"{BASE_URL}/user/profile/setemail", json=data)
    req = urllib.request.Request(f"{BASE_URL}/user/profile/setname", headers=HEADER, data=data, method='PUT')
    json.load(urllib.request.urlopen(req))

    req = requests.get(BASE_URL + '/users/all?token=' + str(token))
    USERS = req.json()['users']

    assert USERS[u_id]['name_first'] == 'Hard Pressed'
    assert USERS[u_id]['name_last'] == 'A'

def test_too_short_last_name(reset_state):
    token, u_id = reset_state
    req = requests.get(BASE_URL + '/users/all?token=' + str(token))
    USERS = req.json()['users']

    assert USERS[u_id]['name_first'] == 'James'
    assert USERS[u_id]['name_last'] == 'Lu'

    data = json.dumps({
        'token': token,
        'name_first': 'Hard Pressed',
        'name_last': ''
    }).encode('utf-8')

    req = urllib.request.Request(f"{BASE_URL}/user/profile/setname", headers=HEADER, data=data, method='PUT')
    with pytest.raises(urllib.error.HTTPError) as e:
        json.load(urllib.request.urlopen(req))

def test_long_last_name(reset_state):
    token, u_id = reset_state
    req = requests.get(BASE_URL + '/users/all?token=' + str(token))
    USERS = req.json()['users']

    # assert type(user_dict) == 'dict'
    assert USERS[u_id]['name_first'] == 'James'
    assert USERS[u_id]['name_last'] == 'Lu'

    data = json.dumps({
        'token': token,
        'name_first': 'Hard Pressed',
        'name_last': 'A' * 50
    }).encode('utf-8')
    #requests.put(f"{BASE_URL}/user/profile/setemail", json=data)
    req = urllib.request.Request(f"{BASE_URL}/user/profile/setname", headers=HEADER, data=data, method='PUT')
    json.load(urllib.request.urlopen(req))

    req = requests.get(BASE_URL + '/users/all?token=' + str(token))
    USERS = req.json()['users']

    assert USERS[u_id]['name_first'] == 'Hard Pressed'
    assert USERS[u_id]['name_last'] == 'A' * 50

def test_too_long_last_name(reset_state):
    token, u_id = reset_state
    req = requests.get(BASE_URL + '/users/all?token=' + str(token))
    USERS = req.json()['users']

    assert USERS[u_id]['name_first'] == 'James'
    assert USERS[u_id]['name_last'] == 'Lu'

    data = json.dumps({
        'token': token,
        'name_first': 'Hard Pressed',
        'name_last': 'A' * 51
    }).encode('utf-8')

    req = urllib.request.Request(f"{BASE_URL}/user/profile/setname", headers=HEADER, data=data, method='PUT')
    with pytest.raises(urllib.error.HTTPError) as e:
        json.load(urllib.request.urlopen(req))

def test_all_spaces_first_name(reset_state):
    token, u_id = reset_state
    req = requests.get(BASE_URL + '/users/all?token=' + str(token))
    USERS = req.json()['users']

    assert USERS[u_id]['name_first'] == 'James'
    assert USERS[u_id]['name_last'] == 'Lu'

    data = json.dumps({
        'token': token,
        'name_first': '        ',
        'name_last': 'Left 4 Dead'
    }).encode('utf-8')

    req = urllib.request.Request(f"{BASE_URL}/user/profile/setname", headers=HEADER, data=data, method='PUT')
    with pytest.raises(urllib.error.HTTPError) as e:
        json.load(urllib.request.urlopen(req))

def test_all_spaces_last_name(reset_state):
    token, u_id = reset_state
    req = requests.get(BASE_URL + '/users/all?token=' + str(token))
    USERS = req.json()['users']

    assert USERS[u_id]['name_first'] == 'James'
    assert USERS[u_id]['name_last'] == 'Lu'

    data = json.dumps({
        'token': token,
        'name_first': 'Hard Pressed',
        'name_last': '     '
    }).encode('utf-8')

    req = urllib.request.Request(f"{BASE_URL}/user/profile/setname", headers=HEADER, data=data, method='PUT')
    with pytest.raises(urllib.error.HTTPError) as e:
        json.load(urllib.request.urlopen(req))
