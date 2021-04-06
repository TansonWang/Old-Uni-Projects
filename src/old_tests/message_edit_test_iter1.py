import pytest
from .error import InputError, AccessError
from .auth import auth_register, auth_login
from .channels import channels_create
from .channel import channel_messages, channel_invite, channel_leave
from .message import message_send, message_edit, message_remove

@pytest.fixture
def user_channel_init():
    auth_register("hayden.smith@unsw.edu.au", "1234567", "Hayden", "Smith")
    auth_register("jennifer.hudson@unsw.edu.au", "2345678", "Jennifer", "Hudson")
    owner = auth_login("hayden.smith@unsw.edu.au", "1234567")
    member = auth_login("jennifer.hudson@unsw.edu.au", "2345678")
    chan_id = channels_create(owner["token"], "TestChannelT", True)
    channel_invite(owner["token"], chan_id["channel_id"], member["u_id"])
    return (owner, member, chan_id)

def test_correct_return(user_channel_init):lmao
    owner, member, chan_id = user_channel_init

    m_id = message_send(owner["token"], chan_id["channel_id"], "hello frens")

    assert message_edit(owner["token"], m_id["message_id"], "Changed") == {}

def test_edit_own_as_member(user_channel_init):
    owner, member, chan_id = user_channel_init

    m_id = message_send(member["token"], chan_id["channel_id"], "Unchanged")
    message_edit(member["token"], m_id["message_id"], "Changed")

    history = channel_messages(owner["token"], chan_id["channel_id"], 0)

    assert history["messages"][0]["message_id"] == m_id["message_id"]
    assert history["messages"][0]["u_id"] == member["u_id"]
    assert history["messages"][0]["message"] == "Changed"

def test_edit_own_as_owner(user_channel_init):
    owner, member, chan_id = user_channel_init

    m_id = message_send(owner["token"], chan_id["channel_id"], "Unchanged")
    message_edit(owner["token"], m_id["message_id"], "Changed")

    history = channel_messages(owner["token"], chan_id["channel_id"], 0)

    assert history["messages"][0]["message_id"] == m_id["message_id"]
    assert history["messages"][0]["u_id"] == owner["u_id"]
    assert history["messages"][0]["message"] == "Changed"

def test_edit_other_as_member(user_channel_init):
    owner, member, chan_id = user_channel_init

    m_id = message_send(owner["token"], chan_id["channel_id"], "Owner: Unchanged")
    with pytest.raises(AccessError) as e:
        message_edit(member["token"], m_id["message_id"], "Member: Changed")


def test_edit_other_as_owner(user_channel_init):
    owner, member, chan_id = user_channel_init

    m_id = message_send(member["token"], chan_id["channel_id"], "Member: Unchanged")
    message_edit(owner["token"], m_id["message_id"], "Owner: Changed")

    history = channel_messages(owner["token"], chan_id["channel_id"], 0)

    assert history["messages"][0]["message_id"] == m_id["message_id"]
    assert history["messages"][0]["u_id"] == member["u_id"]
    assert history["messages"][0]["message"] == "Owner: Changed"

def test_edit_to_nothing(user_channel_init):
    owner, member, chan_id = user_channel_init

    m_id = message_send(owner["token"], chan_id["channel_id"], "Unchanged")
    with pytest.raises(InputError) as e:
        message_edit(owner["token"], m_id["message_id"], "")


def test_edit_to_over_1000_chars(user_channel_init):
    owner, member, chan_id = user_channel_init

    m_id = message_send(owner["token"], chan_id["channel_id"], "Unchanged")
    with pytest.raises(InputError) as e:
        message_edit(owner["token"], m_id["message_id"], "a" * 1001)

def test_edit_removed_message(user_channel_init):
    owner, member, chan_id = user_channel_init

    m_id = message_send(owner["token"], chan_id["channel_id"], "Unchanged")
    message_remove(owner["token"], m_id["message_id"])
    with pytest.raises(InputError) as e:
        message_edit(owner["token"], m_id["message_id"], "Changed")
