from .auth import auth_register, auth_login
import pytest
from .channels import channels_create
from .channel import channel_leave,channel_invite


# valid leave
def test_backend_channel_leave_1():
    # user registers, logs on
    email = "validemail@gmail.com"
    password = "password"
    name_first = "The First"
    name_last = "The last"
    assert (auth_register(email, password, name_first, name_last)) is not None
    login_dic = auth_login(email, password)
    assert (login_dic) is not None
    token = login_dic['token']
    # user creates channel
    channel_dic = channels_create(token, "testchannel", True)
    channel_id = channel_dic['channel_id']
    #make sure Channel ID is valid
    assert (channel_id) is not None
    # user leaves the channel
    assert (channel_leave(token, channel_id)) is not None

# leave when invited
def test_backend_channel_leave_2():
    # user 1 registers
    email = "validemail@gmail.com"
    password = "password"
    name_first = "The First"
    name_last = "The Last"
    # get user 1 u_id
    register_dictionary = auth_register(email, password, name_first, name_last)
    assert (register_dictionary) is not None
    u_id = register_dictionary['u_id']
    register_token = register_dictionary['token']
    
    # user 2 registers, logs on
    email2 = "validemail2@gmail.com"
    password = "password"
    name_first = "The First"
    name_last = "The Last"
    assert (auth_register(email2, password, name_first, name_last)) is not None
    login_dic = auth_login(email2, password)
    assert (login_dic) is not None
    token = login_dic['token']
    # user 2 creates channel
    channel_dictionary = channels_create(token, "testchannel", True)
    channel_id = channel_dictionary['channel_id']
    assert (channel_id) is not None
    # user 2 invites user 1
    assert (channel_invite(token, channel_id, u_id)) is not None
    # user 1 leaves
    assert (channel_leave(register_token, channel_id)) is not None