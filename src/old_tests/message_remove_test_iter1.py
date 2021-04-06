import pytest
from .error import InputError, AccessError
from .auth import auth_register, auth_login
from .channels import channels_create
from .channel import channel_messages, channel_invite
from .message import message_send, message_remove

@pytest.fixture
def user_channel_init():
    auth_register("hayden.smith@unsw.edu.au", "1234567", "Hayden", "Smith")
    auth_register("jennifer.hudson@unsw.edu.au", "2345678", "Jennifer", "Hudson")
    owner = auth_login("hayden.smith@unsw.edu.au", "1234567")
    member = auth_login("jennifer.hudson@unsw.edu.au", "2345678")
    chan_id = channels_create(owner["token"], "TestChannelT", True)
    channel_invite(owner["token"], chan_id["channel_id"], member["u_id"])
    return (owner, member, chan_id)

def test_correct_return(user_channel_init):
    owner, member, chan_id = user_channel_init

    m_id = message_send(owner["token"], chan_id["channel_id"], "hello frens")

    assert message_remove(owner["token"], m_id["message_id"]) == {}

def test_remove_own_message_as_member(user_channel_init):
    owner, member, chan_id = user_channel_init

    m_id1 = message_send(member["token"], chan_id["channel_id"], "I'm getting removed")
    message_remove(member["token"], m_id1["message_id"])
    m_id2 = message_send(member["token"], chan_id["channel_id"], "I'm staying")

    history = channel_messages(owner["token"], chan_id["channel_id"], 0)

    assert history["messages"][0]["message_id"] == m_id2["message_id"]
    assert history["messages"][0]["u_id"] == member["u_id"]
    assert history["messages"][0]["message"] == "I'm staying"

def test_remove_own_message_as_owner(user_channel_init):
    owner, member, chan_id = user_channel_init

    m_id1 = message_send(owner["token"], chan_id["channel_id"], "I'm getting removed")
    message_remove(owner["token"], m_id1["message_id"])
    m_id2 = message_send(owner["token"], chan_id["channel_id"], "I'm staying")

    history = channel_messages(owner["token"], chan_id["channel_id"], 0)

    assert history["messages"][0]["message_id"] == m_id2["message_id"]
    assert history["messages"][0]["u_id"] == owner["u_id"]
    assert history["messages"][0]["message"] == "I'm staying"

def test_remove_removed_message(user_channel_init):
    owner, member, chan_id = user_channel_init

    m_id = message_send(owner["token"], chan_id["channel_id"], "I'm getting removed")
    message_remove(owner["token"], m_id["message_id"])
    with pytest.raises(InputError) as e:
        message_remove(owner["token"], m_id["message_id"])

def test_remove_other_message_as_member(user_channel_init):
    owner, member, chan_id = user_channel_init

    m_id = message_send(owner["token"], chan_id["channel_id"], "I'm the owner")
    with pytest.raises(AccessError) as e:
        message_remove(member["token"], m_id["message_id"])

def test_remove_other_message_as_owner(user_channel_init):
    owner, member, chan_id = user_channel_init

    m_id1 = message_send(member["token"], chan_id["channel_id"], "I'm getting removed")
    message_remove(owner["token"], m_id1["message_id"])
    m_id2 = message_send(member["token"], chan_id["channel_id"], "Admin abuse!")

    history = channel_messages(owner["token"], chan_id["channel_id"], 0)

    assert history["messages"][0]["message_id"] == m_id2["message_id"]
    assert history["messages"][0]["u_id"] == member["u_id"]
    assert history["messages"][0]["message"] == "Admin abuse!"
