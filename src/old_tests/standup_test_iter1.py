import urllib
import flask
import json 
import pytest
import requests
import urllib.request
from standup import standup_start, standup_active, standup_send
from error import AccessError, InputError
from authentication import auth_login, auth_register, auth_logout
import datetime
from .data import PORT

BASE_URL = 'http://127.0.0.1:' + str(PORT)

@pytest.fixture 
def register():
    clearData()
    #create two accounts
    user0 = auth_register("owner@unsw.edu.au", "myunsw", "I am","owner")
    user1 = auth_register("member1@unsw.edu.au", "mygmail", "I am", "member")
    return [user0, user1]


def test_standup_startsuccess(register):
    requests.post(BASE_URL+ "workspace/reset", json = ())
    UONEDATA = requests.post(BASE_URL + "/auth/register", json={
        'email': 'owner@gmail.com',
        'password': 'owner',
        'name_first': 'name_first_owner',
        'name_last': 'name_last_owner'
    })
    UserPayloadOne = UONEDATA.json()

    UTWODATA = requests.post(BASE_URL + "/auth/register", json={
        'email': 'member1@unsw.edu',
        'password': 'member1',
        'name_first': 'member1_fn',
        'name_last': 'member1_ln'
    })
    UserPayloadTwo = UTWODATA.json()

    channel = channels_create(login_return['token'], "Test Channel 0", True)
    u_id = login_return['u_id']
    token = login_return['token']
    now = datetime.datetime.now()
    duration = datetime.timedelta(seconds=10)
    time_f = now+duration
    time_f = datetime.datetime.timestamp(time_f)
    assert standup_start(token,channel['channel_id'],10) == {'time_finish': time_f}


def test_standup_start_invalidID(register):
    auth_logout(register[0]['token'])
    auth_logout(register[1]['token'])
    login_return = auth_login("owner@unsw.edu.au", "myunsw")
    login_return2 = auth_login("member1@unsw.edu.au", "mygmail")
    channel = channels_create(login_return['token'], "Test Channel 0", True)
    u_id = login_return['u_id']
    token = login_return['token']
    with pytest.raises(ValueError):
        standup_start(token,1000,10),"Channel (based on ID) does not exist"

def test_standup_start_isrunning(register):
    auth_logout(register[0]['token'])
    auth_logout(register[1]['token'])
    login_return = auth_login("owner@unsw.edu.au", "myunsw")
    login_return2 = auth_login("member1@unsw.edu.au", "mygmail")
    channel = channels_create(login_return['token'], "Test Channel 0", True)
    u_id = login_return['u_id']
    token = login_return['token']
    standup_start(token, 1, 20)
    with pytest.raises(ValueError):
        standup_start(token,1,20),"An active standup is currently running in this channel"

def standup_active_success(register):
    auth_logout(register[0]['token'])
    auth_logout(register[1]['token'])
    login_return = auth_login("owner@unsw.edu.au", "myunsw")
    login_return2 = auth_login("member1@unsw.edu.au", "mygmail")
    channel = channels_create(login_return['token'], "Test Channel 0", True)
    u_id = login_return['u_id']
    token = login_return['token']
    assert standup_active(token,channel['channel_id']) == {is_active: False, 
                time_finish: None 
            }
def standup_active_success1(register):
    auth_logout(register[0]['token'])
    auth_logout(register[1]['token'])
    login_return = auth_login("owner@unsw.edu.au", "myunsw")
    login_return2 = auth_login("member1@unsw.edu.au", "mygmail")
    channel = channels_create(login_return['token'], "Test Channel 0", True)
    u_id = login_return['u_id']
    token = login_return['token']
    standup=standup_start(token, channel['channel_id'], 20)
    assert standup_active(token,channel['channel_id']) == { is_active: True, 
                time_finish:standup['time_finish']
            }

def standup_active_invalidChannelID(register):
    auth_logout(register[0]['token'])
    auth_logout(register[1]['token'])
    login_return = auth_login("owner@unsw.edu.au", "myunsw")
    login_return2 = auth_login("member1@unsw.edu.au", "mygmail")
    channel = channels_create(login_return['token'], "Test Channel 0", True)
    u_id = login_return['u_id']
    token = login_return['token']
    standup_start(token, channel['channel_id'], 20)
    with pytest.raises(ValueError):
        standup_active(token,20),"Channel (based on ID) does not exist"


def standup_sendsuccess(register):
    auth_logout(register[0]['token'])
    auth_logout(register[1]['token'])
    login_return = auth_login("owner@unsw.edu.au", "myunsw")
    login_return2 = auth_login("member1@unsw.edu.au", "mygmail")
    channel = channels_create(login_return['token'], "Test Channel 0", True)
    u_id = login_return['u_id']
    token = login_return['token']
    standup_start(token, channel['channel_id'], 20)
    assert standup_send(token,channel['channel_id'],'success') == {}


def standup_sendInvalidID(register):
    auth_logout(register[0]['token'])
    auth_logout(register[1]['token'])
    login_return = auth_login("owner@unsw.edu.au", "myunsw")
    login_return2 = auth_login("member1@unsw.edu.au", "mygmail")
    channel = channels_create(login_return['token'], "Test Channel 0", True)
    u_id = login_return['u_id']
    token = login_return['token']
    standup_start(token, 1, 20)
    with pytest.raises(ValueError):
        standup_send(token,1000,'a;kdskdsa'),"Channel (based on ID) does not exist"


def standup_sendLongmsg(register):
    auth_logout(register[0]['token'])
    auth_logout(register[1]['token'])
    login_return = auth_login("owner@unsw.edu.au", "myunsw")
    login_return2 = auth_login("member1@unsw.edu.au", "mygmail")
    channel = channels_create(login_return['token'], "Test Channel 0", True)
    u_id = login_return['u_id']
    token = login_return['token']
    message = "a" * 1001
    standup_start(token, channel['channel_id'], 20)
    with pytest.raises(ValueError):
        standup_send(token,channel['channel_id'],message),"Message is more than 1000"


def standup_send_unactive(register):
    auth_logout(register[0]['token'])
    auth_logout(register[1]['token'])
    login_return = auth_login("owner@unsw.edu.au", "myunsw")
    login_return2 = auth_login("member1@unsw.edu.au", "mygmail")
    channel = channels_create(login_return['token'], "Test Channel 0", True)
    u_id = login_return['u_id']
    token = login_return['token']
    with pytest.raises(ValueError):
        standup_send(token,1,'unactive'),"An active standup is not currently running in this channel"


def standup_send_notmember(register):
    auth_logout(register[0]['token'])
    auth_logout(register[1]['token'])
    login_return = auth_login("owner@unsw.edu.au", "myunsw")
    login_return2 = auth_login("member1@unsw.edu.au", "mygmail")
    channel = channels_create(login_return['token'], "Test Channel 0", True)
    u_id = login_return['u_id']
    token = login_return['token']
    token1 = login_return2['token']
    standup_start(token, 1, 20)
    with pytest.raises(ValueError):
        standup_send(token1,1,'notmember'),"not a member of the channel"