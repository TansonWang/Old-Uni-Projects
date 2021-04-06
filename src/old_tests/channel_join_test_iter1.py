import pytest
from .channels import channels_list
from .channels import channels_create
from .channel import channel_join
from .error import InputError, AccessError

def test_channel_join():

    u_id1 = 1
    u_id2 = 2
    token1 = 'abc'
    token2 = 'def'
    new_channel1 = channels_create('abc','channel1',1)
    new_channel2 = channels_create('def','channel2',0)
    new_channel2[id] = 1

    channels_list.append(new_channel1)
    channels_list.append(new_channel2)
    channels_list.append(new_channel3)

    channel_join(token1,2)
    assert(new_channel3.users[0]) == 1

def test_channel_is_valid():
    with pytest.raises(InputError
, match = r'invalid input'):
        channel_join('abc',4)

def test_channel_is_private():
    with pytest.raises(AccessError, match = r'Access denied'):
        channel_join('abc',1)
