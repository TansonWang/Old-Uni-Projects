# Testing the functionality of the users_all function.
# Presumption of functioning system for searching for confirmation of token validity
# Presumption of accuracy of testing for input data
# Presumption of data existing in database as expected by test cases.
# Presumption of functionality of function "user_profile"
# Presumption that the user list is handled via a dictonary of users

import pytest
from .other import users_all
from .error import InputError, AccessError
from .auth import auth_register, auth_login
from .channels import channels_create
from .channel import channel_messages, channel_invite, channel_leave
from .message import message_send, message_edit, message_remove

@pytest.fixture
def other_search_init():
    auth_register("1@1.com", "1", "1", "1")
    auth_register("2@2.com", "2", "2", "2")
    auth_register("3@3.com", "3", "3", "3")

    user1 = auth_login("1@1.com", "1")
    user2 = auth_login("2@2.com", "2")
    user3 = auth_login("3@3.com", "3")

    return (user1, user2, user3)

def test_general_case(other_search_init):
    user1, user2, user3 = other_search_init
    assert users_all('1') == [user1, user2, user3]