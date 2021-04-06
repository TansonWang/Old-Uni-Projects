import json
import urllib.request
from urllib3.exceptions import HTTPError
import pytest
import requests
from .error import AccessError, InputError
from .data import PORT

BASE_URL = 'http://127.0.0.1:' + str(PORT)
HEADER = {"Content-Type": "application/json"}

@pytest.fixture
def user_init():
    requests.post(f"{BASE_URL}/workspace/reset", json = ())

    UONEDATA = requests.post(f"{BASE_URL}/auth/register", json={
        'email': 'owner@gmail.com',
        'password': 'ownerrrrrr',
        'name_first': 'name_first_owner',
        'name_last': 'name_last_owner'
    })
    UserPayloadOne = UONEDATA.json()

    UTWODATA = requests.post(f"{BASE_URL}/auth/register", json={
        'email': 'member1@unsw.edu',
        'password': 'member11111',
        'name_first': 'member1_fn',
        'name_last': 'member1_ln'
    })
    UserPayloadTwo = UTWODATA.json()

    USERS = requests.get(f"{BASE_URL}/users/getall").json()

    assert UserPayloadOne['token'] == USERS[0]['token']

    return USERS

def test_create_channel(user_init):
    USERS = user_init
    CHONEDATA = requests.post(f"{BASE_URL}/channels/create", json={
        'token' : USERS[0]['token'],
        'name' : 'one',
        'is_public' : True
    })

    CHONEDATA2 = requests.post(f"{BASE_URL}/channels/create", json={
        'token' : USERS[0]['token'],
        'name' : 'two',
        'is_public' : True
    })
    
    CHANDETAILS = requests.get(f"{BASE_URL}/channels/all").json()

    assert len(CHANDETAILS) == 2
    assert CHANDETAILS[0]['channel_name'] == 'one'
    assert CHANDETAILS[0]['id'] == 1

    CHINVONE = requests.post(f"{BASE_URL}/channel/invite", json={
        'token' : USERS[0]['token'],
        'channel_id' : CHANDETAILS[0]['id'],
        'u_id' : USERS[1]['u_id']
    })

    CHANDETAILS = requests.get(f"{BASE_URL}/channels/all").json()

    assert len(CHANDETAILS[0]['users']) == 2
    assert len(CHANDETAILS[1]['users']) == 1
    assert CHANDETAILS[1]['users'][0] == 0