import pytests
import requests
import sys
sys.path.append("../")
import server
import data
from .data import PORT

BASE_URL = 'http://127.0.0.1:' + str(PORT)
HEADER = {"Content-Type": "application/json"}

@pytest.fixture(autouse=True)
def reset_state():
    ''''
    Testing fixture occurs for every function used
    ''''
    r = requests.post(f"{BASE_URL}/workspace/reset")
    assert r.status_code = requests.codes.ok
    
def test_system(user_1, user_2):
    ''''
    Testing user functions 
    ''''
    # Get user_1 and user_2 details
    # TODO by Tanson
    # Pretty much just write your users tests in here
    
    
    ''''
    Testing channel functions
    ''''
    
    # User 1 creates two channels
    channel_1 = {**token1, **{"name": "Corona_Cold", "is_public": True}}
    r3 = requests.post(f"{BASE_URL}/channels/create", headers=HEADERS, json=channel_1)
    assert r3.status_code == requests.code.ok
    
    r4 = requests.post(f"{BASE_URL}/channels/create", headers=HEADERS, json=channel_1)
    assert r4.status_code == requests.code.ok
    
    # Get their channel_ids
    channel_1_id = {"channel_id": r3.json()["channel_id"]}
    channel_2_id = {"channel_id": r4.json()["channel_id"]}
    assert channel_1_id != channel_2_id
    
    # User 2 is invited to join channel 1 by user 1
    invite_1 = {**token1, **channel_1, **u_id2}
    r5 = requests.post(f"{BASE_URL}/channel/join", headers=HEADERS, json=invite_1)
    assert r5.status_code == requests.code.ok
    
    # User 2 joins channel 2
    invite_2 = {**token2, **channel_2_id}
    r6 = requests.post(f"{BASE_URL}/channel/join", headers=HEADERS, json=invite_2)
    assert r6.status_code == requests.code.ok
    
    # User 2 leaves channel 1
    leave_1 = {**token2, **channel_1_id}
    r7 = requests.post(f"{BASE_URL}/channel/leave", headers=HEADERS, json=leave_1)
    assert r7.status_code == requests.code.ok
    
    # User 2 leaves channel 2
    leave_2 = {**token2, **channel_2_id}
    r8 = requests.post(f"{BASE_URL}/channel/leave", headers=HEADERS, json=leave_2)
    assert r8.status_code == requests.code.ok
    
    
    
    
        


