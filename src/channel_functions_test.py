import urllib
import flask
import json 
import pytest
import requests
import urllib.request

BASEURL = 'http://127.0.0.1:'

from .data import PORT
BASE_URL = "http://127.0.0.1:" + str(PORT)
HEADER = {"Content-Type": "application/json"}

#@pytest.fixture(autouse=True)
#def reset_state():
#    reg1 = json.dumps({
#    'email': 'first@first.com',
#    'password': 'happy',
#    'name_first': 'James',
#    'name_last': 'Lu'
#    }).encode('utf-8')#

    # Register a user
#    req = urllib.request.Request(f"{BASE_URL}/auth/register", headers=HEADER, data=reg1)
#    payload_json = json.load(urllib.request.urlopen(req))
#    payload_dict = json.loads(payload_json.read().decode('utf-8'))
#    u_id = payload_dict['u_id']
#    token = payload_dict['token']

#    return token, u_id

def test_create_channel():
    
    # User create a channel
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

    CHONEDATA = requests.post(f"{BASE_URL}/channels/create", json={
        'token' : USERS[0]['token'],
        'name' : 'chan0',
        'is_public' : True
    })
    #ChannelPayloadOne = CHONEDATA.json()

    CHANDETAILS = requests.get(f"{BASE_URL}/channels/all").json()

    #assert ChannelPayloadOne['token'] == CHANDETAILS[0]['token']
    assert len(CHANDETAILS) == 1
    assert CHANDETAILS[0]['channel_name'] == 'chan0'
    assert CHANDETAILS[0]['id'] == 1

    CHINVONE = requests.post(f"{BASE_URL}/channel/invite", json={
        'token' : USERS[0]['token'],
        'channel_id' : CHANDETAILS[0]['id'],
        'u_id' : USERS[1]['u_id']
    })

    CHANDETAILS = requests.get(f"{BASE_URL}/channels/all").json()

    assert len(CHANDETAILS[0]['users']) == 2

'''
def test_leave_channel():
    
    # User leaves a channel

    channel1_detail_data = requests.post(f"{BASE_URL}/channel/leave", json={
        'token' : USERS[0]['token'],
        'u_id' : ' ',
        'channel_id' : 'broken_ankles4'
    })
    payload_one_channel = channel1_data.json()
    
    channel2_detail_data = requests.get(f"{BASE_URL}/channel/leave", json={
        'token' : USERS[1]['token'],
        'u_id' : ' ',
        'channel_id' : 'cold_corona2'
    })
    payload_two_channel = channel2_data.json()   
'''    
