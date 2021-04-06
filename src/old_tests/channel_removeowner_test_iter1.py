
from .auth import auth_register, auth_login
import pytest
from .channels import channels_create, channels_listall
from .channel import channel_invite, channel_addowner, channel_removeowner
from .error import InputError, AccessError
# valid owner
def test_backend_channel_removeowner_1():
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
    name_first = "First"
    name_last = "Last"
    assert (auth_register(email2, password, name_first, name_last)) is not None
    login_dictionary = auth_login(email2, password)
    assert (login_dictionary) is not None
    token = login_dictionary['token']
    # user 2 creates channel
    channel_dictionary = channels_create(token, "testchannel", True)
    channel_id = channel_dictionary['channel_id']
    assert (channel_id) is not None
    # user 2 invites user 1
    assert (channel_invite(token, channel_id, u_id)) is not None
    # user 2 makes user 1 an owner
    assert (channel_addowner(token, channel_id, u_id)) is not None
    # user 2 removes user 1 as an owner
    assert (channel_removeowner(token, u_id, channel_id)) is not None

# authorised user not an owner
def test_backend_channel_removeowner_2():
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
    name_first = "First"
    name_last = "Last"
    assert (auth_register(email2, password, name_first, name_last)) is not None
    login_dictionary = auth_login(email2, password)
    assert (login_dictionary) is not None
    token = login_dictionary['token']
    login_u_id = login_dictionary['u_id']
    # user 2 creates channel
    channel_dictionary = channels_create(token, "testchannel", True)
    channel_id = channel_dictionary['channel_id']
    assert (channel_id) is not None
    # user 2 invites user 1
    assert (channel_invite(token, channel_id, u_id)) is not None
    # user 1 tries to remove user 2 as an owner
    with pytest.raises(InputError) as e:
        channel_removeowner(register_token, login_u_id, channel_id)

# trying to remove when already not an owner
def test_backend_channel_removeowner_3():
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
    login_dictionary = auth_login(email2, password)
    assert (login_dictionary) is not None
    token = login_dictionary['token']
    # user 2 creates channel
    channel_dictionary = channels_create(token, "testchannel", True)
    channel_id = channel_dictionary['channel_id']
    assert (channel_id) is not None
    # user 2 invites user 1
    assert (channel_invite(token, channel_id, u_id)) is not None
    # user 2 makes user 1 an owner
    assert (channel_addowner(token, channel_id, u_id)) is not None
    # user 2 removes user 1 as an owner
    assert (channel_removeowner(token, u_id, channel_id)) is not None
    # user 2 tries to remove user 1 as an owner again
    with pytest.raises(AccessError) as e:
        channel_removeowner(token, u_id, channel_id)