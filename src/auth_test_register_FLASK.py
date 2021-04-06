import urllib
import flask
import json 
import pytest
import requests
import urllib.request
#from .error import InputError
from .data import PORT

BASE_URL = 'http://127.0.0.1:' + str(PORT)
HEADER = {"Content-Type": "application/json"}

@pytest.fixture(autouse=True)
def reset_state():
    requests.post(BASE_URL + "/workspace/reset", json = ())
    return

def test_valid_register():
    reg = json.dumps({
        'email': 'first@first.com',
        'password': 'happydays',
        'name_first': 'James',
        'name_last': 'Lu'
    }).encode('utf-8')

    req = urllib.request.Request(f"{BASE_URL}/auth/register", headers=HEADER, data=reg, method='POST')
    payload_json = json.load(urllib.request.urlopen(req))
    token = payload_json['token']

    USERS = requests.get(f"{BASE_URL}/users/all?token={token}").json()['users']
    assert len(USERS) == 1

def test_invalid_email():
    reg = json.dumps({
        'email': 'lolwutisemail',
        'password': 'happydays',
        'name_first': 'James',
        'name_last': 'Lu'
    }).encode('utf-8')

    req = urllib.request.Request(f"{BASE_URL}/auth/register", headers=HEADER, data=reg, method='POST')
    with pytest.raises(urllib.error.HTTPError) as e:
        json.load(urllib.request.urlopen(req))

def test_password_too_short():
    reg = json.dumps({
        'email': 'first@first.com',
        'password': 'A',
        'name_first': 'James',
        'name_last': 'Lu'
    }).encode('utf-8')

    req = urllib.request.Request(f"{BASE_URL}/auth/register", headers=HEADER, data=reg, method='POST')
    with pytest.raises(urllib.error.HTTPError) as e:
        json.load(urllib.request.urlopen(req))
        
def test_repeat_email():
    # Register first user
    reg = json.dumps({
        'email': 'first@first.com',
        'password': 'happydays',
        'name_first': 'James',
        'name_last': 'Lu'
    }).encode('utf-8')

    req = urllib.request.Request(f"{BASE_URL}/auth/register", headers=HEADER, data=reg, method='POST')
    payload_json = json.load(urllib.request.urlopen(req))
    token = payload_json['token']

    # assert user has been registered
    USERS = requests.get(f"{BASE_URL}/users/all?token={token}").json()['users']
    assert len(USERS) == 1

    # Register second user
    reg2 = json.dumps({
        'email': 'first@first.com',
        'password': 'happydays',
        'name_first': 'James',
        'name_last': 'Lu'
    }).encode('utf-8')

    # Check for error raise
    req = urllib.request.Request(f"{BASE_URL}/auth/register", headers=HEADER, data=reg2, method='POST')
    with pytest.raises(urllib.error.HTTPError) as e:
        json.load(urllib.request.urlopen(req))

def test_name_first_short():
    reg = json.dumps({
        'email': 'first@first.com',
        'password': 'happydays',
        'name_first': '',
        'name_last': 'Lu'
    }).encode('utf-8')

    req = urllib.request.Request(f"{BASE_URL}/auth/register", headers=HEADER, data=reg, method='POST')
    with pytest.raises(urllib.error.HTTPError) as e:
        json.load(urllib.request.urlopen(req))

def test_name_first_long():
    reg = json.dumps({
        'email': 'first@first.com',
        'password': 'happydays',
        'name_first': 'A' * 51,
        'name_last': 'Lu'
    }).encode('utf-8')

    req = urllib.request.Request(f"{BASE_URL}/auth/register", headers=HEADER, data=reg, method='POST')
    with pytest.raises(urllib.error.HTTPError) as e:
        json.load(urllib.request.urlopen(req))

def test_name_last_short():
    reg = json.dumps({
        'email': 'first@first.com',
        'password': 'happydays',
        'name_first': 'James',
        'name_last': ''
    }).encode('utf-8')

    req = urllib.request.Request(f"{BASE_URL}/auth/register", headers=HEADER, data=reg, method='POST')
    with pytest.raises(urllib.error.HTTPError) as e:
        json.load(urllib.request.urlopen(req))

def test_name_last_long():
    reg = json.dumps({
        'email': 'first@first.com',
        'password': 'happydays',
        'name_first': 'James',
        'name_last': 'A' * 51
    }).encode('utf-8')

    req = urllib.request.Request(f"{BASE_URL}/auth/register", headers=HEADER, data=reg, method='POST')
    with pytest.raises(urllib.error.HTTPError) as e:
        json.load(urllib.request.urlopen(req))
