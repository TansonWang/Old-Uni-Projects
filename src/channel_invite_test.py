import urllib
import flask
import json 
from .error import InputError, AccessError
import pytest
import requests
import urllib.request
from urllib3.exceptions import HTTPError

BASEURL = 'http://127.0.0.1:'

from .data import PORT
BASE_URL = "http://127.0.0.1:" + str(PORT)

@pytest.fixture
def user_channel_init_forchans():
    requests.post(f"{BASEURL}{PORT}/workspace/reset", json = ())

    UONEDATA = requests.post(f"{BASEURL}{PORT}/auth/register", json={
        'email': 'owner@gmail.com',
        'password': 'ownerrrrrr',
        'name_first': 'name_first_owner',
        'name_last': 'name_last_owner'
    })
    UserPayloadOne = UONEDATA.json()

    UTWODATA = requests.post(f"{BASEURL}{PORT}/auth/register", json={
        'email': 'member1@unsw.edu',
        'password': 'member11111',
        'name_first': 'member1_fn',
        'name_last': 'member1_ln'
    })
    UserPayloadTwo = UTWODATA.json()

    USERS = requests.get(f"{BASEURL}{PORT}/users/getall").json()

    assert UserPayloadOne['token'] == USERS[0]['token']

    CHONEDATA = requests.post(f"{BASEURL}{PORT}/channels/create", json={
        'token' : USERS[0]['token'],
        'name' : 'one',
        'is_public' : True
    })

    CHONEDATA2 = requests.post(f"{BASEURL}{PORT}/channels/create", json={
        'token' : USERS[0]['token'],
        'name' : 'two',
        'is_public' : True
    })
    CHANDETAILS = requests.get(f"{BASEURL}{PORT}/channels/all").json()

    assert len(CHANDETAILS) == 2
    assert CHANDETAILS[0]['channel_name'] == 'one'
    assert CHANDETAILS[0]['id'] == 1

    CHANDETAILS = requests.get(f"{BASEURL}{PORT}/channels/all").json()

    assert len(CHANDETAILS[1]['users']) == 1
    assert CHANDETAILS[1]['users'][0] == 0
    return USERS, CHANDETAILS

def test_invite(user_channel_init_forchans):
    USERS, CHANDETAILS = user_channel_init_forchans

    CHINVONE = requests.post(f"{BASEURL}{PORT}/channel/invite", json={
        'token' : USERS[0]['token'],
        'channel_id' : CHANDETAILS[0]['id'],
        'u_id' : USERS[1]['u_id']
    })

    CHANDETAILS = requests.get(f"{BASEURL}{PORT}/channels/all").json()
    assert len(CHANDETAILS[0]['users']) == 2
