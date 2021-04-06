import pytest
from .error import InputError, AccessError
from .auth import auth_register, auth_login
from .channels import channels_create
from .channel import channel_messages, channel_invite, channel_leave
from .message import message_send

@pytest.fixture
def user_channel_init():
    auth_register("hayden.smith@unsw.edu.au", "1234567", "Hayden", "Smith")
    auth_register("jennifer.hudson@unsw.edu.au", "2345678", "Jennifer", "Hudson")
    owner = auth_login("hayden.smith@unsw.edu.au", "1234567")
    member = auth_login("jennifer.hudson@unsw.edu.au", "2345678")
    chan_id = channels_create(owner["token"], "TestChannelT", True)
    channel_invite(owner["token"], chan_id["channel_id"], member["u_id"])
    return (owner, member, chan_id)

def test_message_send(user_channel_init):
    owner, member, chan_id = user_channel_init

    m_id = message_send(owner["token"], chan_id["channel_id"], "hello frens")

    history = channel_messages(owner["token"], chan_id["channel_id"], 0)

    assert history["messages"][0]["message_id"] == m_id["message_id"]
    assert history["messages"][0]["u_id"] == owner["u_id"]
    assert history["messages"][0]["message"] == "hello frens"

def test_over_1000_characters(user_channel_init):
    owner, member, chan_id = user_channel_init

    with pytest.raises(InputError) as e:
        message_send(owner["token"], chan_id["channel_id"], "a" * 1001)

def test_no_message(user_channel_init):
    owner, member, chan_id = user_channel_init

    with pytest.raises(InputError) as e:
        message_send(owner["token"], chan_id["channel_id"], "")

def test_not_joined_in_channel(user_channel_init):
    owner, member, chan_id = user_channel_init
    channel_leave(member["token"], chan_id["channel_id"])

    with pytest.raises(AccessError) as e:
        message_send(member["token"], chan_id["channel_id"], "LETMEIN")

def test_invited_to_channel(user_channel_init):
    owner, member, chan_id = user_channel_init

    m_id = message_send(member["token"], chan_id["channel_id"], "I'm in")

    history = channel_messages(owner["token"], chan_id["channel_id"], 0)

    assert history["messages"][0]["message_id"] == m_id["message_id"]
    assert history["messages"][0]["u_id"] == member["u_id"]
    assert history["messages"][0]["message"] == "I'm in"
    