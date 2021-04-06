# Testing the functionality of the search function.
# Presumption of functioning system for searching for confirmation of token validity
# Presumption of accuracy of testing for input data
# Presumption of data existing in database as expected by test cases.
# Presumption of functionality of function "user_profile"
# Assumption that the return will be a list of strings
# Assumption that the search will only return a dictionary of messages

import pytest
from .other import search
from .error import InputError, AccessError
from .auth import auth_register, auth_login
from .channels import channels_create
from .channel import channel_messages, channel_invite, channel_leave
from .message import message_send, message_edit, message_remove

@pytest.fixture
def other_search_init():
    auth_register("hayden.smith@unsw.edu,au", "1234567", "Hayden", "Smith")
    auth_register("jennifer.hudson@unsw.edu.au", "2345678", "Jennifer", "Hudson")

    owner = auth_login("hayden.smith@unsw.edu.au", "1234567")
    member = auth_login("jennifer.hudson@unsw.edu.au", "2345678")

    chan_id_1 = channels_create(owner["token"], "Channel_1", True)
    channel_invite(owner["token"], chan_id_1["channel_id"], member["u_id"])
    chan_id_2 = channels_create(owner["token"], "Channel_1", True)
    channel_invite(owner["token"], chan_id_2["channel_id"], member["u_id"])

    m_1_1 = message_send(owner["token"], chan_id_1["channel_id"], "Channel 1 Message 1 likes dogs")
    m_1_2 = message_send(owner["token"], chan_id_1["channel_id"], "Channel 1 Message 2 likes cats")
    m_1_3 = message_send(member["token"], chan_id_1["channel_id"], "Channel 1 Message 3 likes dogs")
    m_2_1 = message_send(owner["token"], chan_id_2["channel_id"], "Channel 2 Message 1 likes birds")
    m_2_2 = message_send(owner["token"], chan_id_2["channel_id"], "Channel 2 Message 2 likes cats")
    m_2_3 = message_send(member["token"], chan_id_2["channel_id"], "Channel 2 Message 3 likes birchnuts")

    return (owner, member, chan_id_1, chan_id_2, m_1_1, m_1_2, m_1_3, m_2_1, m_2_2, m_2_3)

def test_general_case(other_search_init):
    owner, member, chan_id_1, chan_id_2, m_1_1, m_1_2, m_1_3, m_2_1, m_2_2, m_2_3 = other_search_init
    assert search(owner["token"], "Channel") == [m_1_1, m_1_2, m_1_3, m_2_1, m_2_2, m_2_3]

def test_one_return(other_search_init):
    owner, member, chan_id_1, chan_id_2, m_1_1, m_1_2, m_1_3, m_2_1, m_2_2, m_2_3 = other_search_init
    assert search(owner["token"], "birds") == [m_2_1]

def test_within_channel(other_search_init):
    owner, member, chan_id_1, chan_id_2, m_1_1, m_1_2, m_1_3, m_2_1, m_2_2, m_2_3 = other_search_init
    assert search(owner["token"], "dogs") == [m_1_1,m_1_3]

def test_multi_channel(other_search_init):
    owner, member, chan_id_1, chan_id_2, m_1_1, m_1_2, m_1_3, m_2_1, m_2_2, m_2_3 = other_search_init
    assert search(owner["token"], "cats") == [m_1_2, m_2_2]

def test_partial_words(other_search_init):
    owner, member, chan_id_1, chan_id_2, m_1_1, m_1_2, m_1_3, m_2_1, m_2_2, m_2_3 = other_search_init
    assert search(owner["token"], "bir") == [m_2_1, m_2_3]
