import urllib
import flask
import json
import requests
import pytest
BASEURL = 'http://127.0.0.1:'

from .data import PORT
BASE_URL = "http://127.0.0.1:" + str(PORT)

@pytest.fixture
def user_channel_message_init():
    requests.post(f"{BASEURL}{PORT}/workspace/reset", json = ())

    UONEDATA = requests.post(f"{BASEURL}{PORT}/auth/register", json={
        'email': 'owner@gmail.com',
        'password': 'ownerrrr',
        'name_first': 'name_first_owner',
        'name_last': 'name_last_owner'
    })
    UserPayloadOne = UONEDATA.json()

    UTWODATA = requests.post(f"{BASEURL}{PORT}/auth/register", json={
        'email': 'member1@unsw.edu',
        'password': 'member1111',
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
    #ChannelPayloadOne = CHONEDATA.json()
    CHONEDATA2 = requests.post(f"{BASEURL}{PORT}/channels/create", json={
        'token' : USERS[0]['token'],
        'name' : 'two',
        'is_public' : True
    })
    CHANDETAILS = requests.get(f"{BASEURL}{PORT}/channels/all").json()

    #assert ChannelPayloadOne['token'] == CHANDETAILS[0]['token']
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
    assert USERS[0]['token'] == UserPayloadOne['token']

    CHANTHREE = requests.post(f"{BASEURL}{PORT}/channels/create", json={
        'token' : USERS[1]['token'],
        'name' : 'Memberchannel',
        'is_public' : True
    })
    CHANDETAILS = requests.get(f"{BASEURL}{PORT}/channels/all").json()

    assert len(CHANDETAILS) == 3

    OWNERMSGCHAN1 = requests.post(f"{BASEURL}{PORT}/message/send", json={
        'token': USERS[0]['token'],
        'channel_id': CHANDETAILS[0]['id'],
        'message': 'Owner message channel 1'
    })

    MESSAGES = requests.get(f"{BASEURL}{PORT}/messages/all").json()
    assert len(MESSAGES) == 1

    OWNERMSGCHAN2 = requests.post(f"{BASEURL}{PORT}/message/send", json={
        'token': USERS[0]['token'],
        'channel_id': CHANDETAILS[1]['id'],
        'message': 'Owner message channel 2'
    })
    MESSAGES = requests.get(f"{BASEURL}{PORT}/messages/all").json()
    assert len(MESSAGES) == 2
    MEMBERMSGCHAN1 = requests.post(f"{BASEURL}{PORT}/message/send", json={
        'token': USERS[1]['token'],
        'channel_id': CHANDETAILS[0]['id'],
        'message': 'Member message channel 1'
    })
    MEMBERMSGCHAN3 = requests.post(f"{BASEURL}{PORT}/message/send", json={
        'token': USERS[1]['token'],
        'channel_id': CHANDETAILS[2]['id'],
        'message': 'Member message channel 3'
    })

    MESSAGES = requests.get(f"{BASEURL}{PORT}/messages/all").json()
    assert len(MESSAGES) == 4

    return USERS, CHANDETAILS, MESSAGES

def test_remove_user(user_channel_message_init):
    USERS, CHANDETAILS, MESSAGES = user_channel_message_init
    assert len(USERS) == 2
    requests.delete(f"{BASEURL}{PORT}/admin/user/remove", json = {
        'token': USERS[0]['token'],
        'u_id': USERS[1]['u_id']
    })

    CHANDETAILS = requests.get(f"{BASEURL}{PORT}/channels/all").json()
    USERS = requests.get(f"{BASEURL}{PORT}/users/getall").json()
    assert 1 not in CHANDETAILS[0]['users']
    assert USERS[1]['permission_id'] == -1
    assert len(USERS) == 2

def test_remove_user_as_member(user_channel_message_init):
    USERS, CHANDETAILS, MESSAGES = user_channel_message_init
    with pytest.raises(requests.exceptions.HTTPError):
        requests.delete(f"{BASEURL}{PORT}/admin/user/remove", json = {
            'token': USERS[1]['token'],
            'u_id': USERS[0]['u_id']
    }).raise_for_status()

def test_remove_invalid_user(user_channel_message_init):
    USERS, CHANDETAILS, MESSAGES = user_channel_message_init
    with pytest.raises(requests.exceptions.HTTPError):
        requests.delete(f"{BASEURL}{PORT}/admin/user/remove", json = {
            'token': USERS[0]['token'],
            'u_id': 2
    }).raise_for_status()