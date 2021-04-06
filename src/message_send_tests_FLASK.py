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
def user_channel_init():
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
        'name' : 'need_toilet_paper',
        'is_public' : True
    })

    CHONEDATA2 = requests.post(f"{BASEURL}{PORT}/channels/create", json={
        'token' : USERS[0]['token'],
        'name' : 'two',
        'is_public' : True
    })
    CHANDETAILS = requests.get(f"{BASEURL}{PORT}/channels/all").json()

    assert len(CHANDETAILS) == 2
    assert CHANDETAILS[0]['channel_name'] == 'need_toilet_paper'
    assert CHANDETAILS[0]['id'] == 1

    CHINVONE = requests.post(f"{BASEURL}{PORT}/channel/invite", json={
        'token' : USERS[0]['token'],
        'channel_id' : CHANDETAILS[0]['id'],
        'u_id' : USERS[1]['u_id']
    })

    CHANDETAILS = requests.get(f"{BASEURL}{PORT}/channels/all").json()

    assert len(CHANDETAILS[0]['users']) == 2
    assert len(CHANDETAILS[1]['users']) == 1
    assert CHANDETAILS[1]['users'][0] == 0
    assert USERS[0]['token'] == UserPayloadOne['token']
    return USERS, CHANDETAILS


def test_message_send(user_channel_init):
    USERS, CHANDETAILS = user_channel_init

    MSGONE = requests.post(f"{BASEURL}{PORT}/message/send", json={
        'token': USERS[0]['token'],
        'channel_id': CHANDETAILS[0]['id'],
        'message': 'hello'
    })

    MESSAGES = requests.get(f"{BASEURL}{PORT}/messages/all").json()
    print(MESSAGES)
    assert len(MESSAGES) == 1

def test_send_multiple_messages(user_channel_init):
    USERS, CHANDETAILS = user_channel_init

    MSGONE = requests.post(f"{BASEURL}{PORT}/message/send", json={
        'token': USERS[0]['token'],
        'channel_id': CHANDETAILS[0]['id'],
        'message': 'ONE'
    })

    MESSAGES = requests.get(f"{BASEURL}{PORT}/messages/all").json()
    assert MESSAGES[0]['message_id'] == 1

    MSGTWO = requests.post(f"{BASEURL}{PORT}/message/send", json={
        'token': USERS[0]['token'],
        'channel_id': CHANDETAILS[0]['id'],
        'message': 'TWO'
    })

    MESSAGES = requests.get(f"{BASEURL}{PORT}/messages/all").json()
    assert MESSAGES[1]['message_id'] == 2

    MSGTHREE = requests.post(f"{BASEURL}{PORT}/message/send", json={
        'token': USERS[0]['token'],
        'channel_id': CHANDETAILS[0]['id'],
        'message': 'THREE'
    })
    MESSAGES = requests.get(f"{BASEURL}{PORT}/messages/all").json()

    MSGFOUR = requests.post(f"{BASEURL}{PORT}/message/send", json={
        'token': USERS[0]['token'],
        'channel_id': CHANDETAILS[1]['id'],
        'message': 'FOUR'
    })

    MSGFIVE = requests.post(f"{BASEURL}{PORT}/message/send", json={
        'token': USERS[1]['token'],
        'channel_id': CHANDETAILS[0]['id'],
        'message': 'FIVE'
    })
    MSGSIX = requests.post(f"{BASEURL}{PORT}/message/send", json={
        'token': USERS[1]['token'],
        'channel_id': CHANDETAILS[0]['id'],
        'message': 'SIX'
    })

    MESSAGES = requests.get(f"{BASEURL}{PORT}/messages/all").json()
    assert MESSAGES[5]['message_id'] == 6
    assert len(MESSAGES) == 6

def test_over_1000_characters(user_channel_init):
    USERS, CHANDETAILS = user_channel_init
    message = 'a' * 10000

    with pytest.raises(requests.exceptions.HTTPError):
        MSGONE = requests.post(f"{BASEURL}{PORT}/message/send", json={
            'token': USERS[0]['token'],
            'channel_id': CHANDETAILS[0]['id'],
            'message': message
        }).raise_for_status()

def test_no_message(user_channel_init):
    USERS, CHANDETAILS = user_channel_init
    message = ''

    with pytest.raises(requests.exceptions.HTTPError):
        MSGONE = requests.post(f"{BASEURL}{PORT}/message/send", json={
            'token': USERS[0]['token'],
            'channel_id': CHANDETAILS[0]['id'],
            'message': message
        }).raise_for_status()


def test_not_joined_in_channel(user_channel_init):
    USERS, CHANDETAILS = user_channel_init
    with pytest.raises(requests.exceptions.HTTPError):
        MSGONE = requests.post(f"{BASEURL}{PORT}/message/send", json={
            'token': USERS[1]['token'],
            'channel_id': CHANDETAILS[1]['id'],
            'message': 'message'
        }).raise_for_status()

'''
def test_sendlater_is_not_sent_preemtovely(user_channel_init):

def test_sendlater_is_sent_later(user_channel_init): 

def test_sendlater_time_is_in_the_past(user_channel_init):
'''
