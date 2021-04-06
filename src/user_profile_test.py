import json
import urllib.request
import pytest
import requests
from .error import AccessError
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


def test_valid_profile_search(reset_state):
    [token, u_id] = reset_state
    #assert type(reset_state) == 'dict'
    queryString = urllib.parse.urlencode({
        'token': token,
        'u_id': u_id
    })
    req = urllib.request.Request(f"{BASE_URL}/user/profile?{queryString}", headers=HEADER)
    payload = json.load(urllib.request.urlopen(req))['user']
    #assert type(payload) == 'dict'

    assert payload['u_id'] == u_id
    assert payload['email'] == 'first@first.com'
    assert payload['name_first'] == 'James'
    assert payload['name_last'] == 'Lu'
    assert payload['handle_str'] == 'JamesLu'

def test_token_id_mismatch_search_(reset_state):
    [token, u_id] = reset_state
    #assert type(reset_state) == 'dict'
    queryString = urllib.parse.urlencode({
        'token': token,
        'u_id': 132412351235
    })
    req = urllib.request.Request(f"{BASE_URL}/user/profile?{queryString}", headers=HEADER)

    with pytest.raises(urllib.error.HTTPError) as e:
        json.load(urllib.request.urlopen(req))
