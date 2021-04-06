'''
COMP1531 Major Project: Slackr
Term 1 Year 2020
Involved: Tanson Wang
          James Lu
          Yucheng Shan
          Ojasya Suri
          Alan Vo

Description:
This is the main server file. It contains the APP which runs.
All http requests are accessed in this file.
Including all authentication, user, channel, message and standup functions.
This does not require any inputs to run.
'''

import time
import threading
import pickle
from json import dumps
from flask_cors import CORS
from flask import Flask, request
import data as da
from error import InputError


from channel_functions import channel_invite,          \
                              channel_details,         \
                              channel_messages,        \
                              channel_leave,           \
                              channel_join,            \
                              channel_addowner,        \
                              channel_removeowner,     \
                              channel_create,          \
                              channels_list,            \
                              channels_listall

from message_functions_fn import message_send_fn,      \
                                 message_sendlater_fn, \
                                 message_react_fn,     \
                                 message_unreact_fn,   \
                                 message_pin_fn,       \
                                 message_unpin_fn,     \
                                 message_remove_fn,    \
                                 message_edit_fn,      \
                                 search_fn

from user_functions import user_profile_fn, \
                           user_setemail_fn, \
                           user_sethandle_fn, \
                           user_setname_fn, \
                           users_fn,                   \
                           user_permission_change_fn,  \
                           user_profile_uploadphoto_fn,\
                           user_remove_fn

from auth import auth_register,           \
                 auth_login,              \
                 auth_logout,             \
                 auth_request_reset_fn,   \
                 auth_reset_password_fn

from standup import standup_start_fn,   \
                    standup_active_fn,   \
                    standup_send_fn

def default_handler(err):
    response = err.get_response()
    print('response', err, err.get_response())
    response.data = dumps({
        "code": err.code,
        "name": "System Error",
        "message": err.get_description(),
    })
    response.content_type = 'application/json'
    return response

APP = Flask(__name__)
CORS(APP)

APP.config['TRAP_HTTP_EXCEPTIONS'] = True
APP.register_error_handler(Exception, default_handler)

# Example
@APP.route("/echo", methods=['GET'])
def echo():
    data = request.args.get('data')
    if data == 'echo':
        raise InputError(description='Cannot echo "echo"')
    return dumps({
        'data': data
    })

#--------------------AUTH_FUNCTIONS--------------------

@APP.route('/auth/register', methods=['POST'])
def auth_register_flask():
    response = request.get_json()
    email = response['email']
    password = response['password']
    name_first = response['name_first']
    name_last = response['name_last']

    return auth_register(email, password, name_first, name_last, da.USERS)

@APP.route('/auth/login', methods=['POST'])
def auth_login_flask():
    response = request.get_json()
    email = response['email']
    password = response['password']

    return auth_login(email, password, da.USERS)

@APP.route('/auth/logout', methods=['POST'])
def auth_logout_flask():
    response = request.get_json()
    token = response['token']
    return auth_logout(token, da.USERS)

#--------------------CHANNEL_FUNCTIONS--------------------
@APP.route("/channel/invite", methods=['POST'])
def invite_channel():
    response = request.get_json()
    token = response['token']
    channel_id = response['channel_id']
    u_id = int(response['u_id'])
    channel_invite(token, channel_id, u_id, da.USERS, da.CHANNEL)
    return dumps({})

@APP.route("/channel/details", methods=['GET'])
def details_channel():
    token = request.args.get('token')
    #assert token is not None
    channel_idp = request.args.get('channel_id')
    channel_id = int(channel_idp)
    return channel_details(token, channel_id, da.CHANNEL, da.USERS)

@APP.route("/channel/messages", methods=['GET'])
def channel_messages_route():
    token = request.args.get('token')
    channel_id = int(request.args.get('channel_id'))
    start = request.args.get('start')
    return channel_messages(token, channel_id, start, da.CHANNEL, da.USERS, da.MESSAGES)

@APP.route("/channel/leave", methods=['POST'])
def leave_channel():
    response = request.get_json()
    token = response['token']
    channel_id = response['channel_id']
    return channel_leave(token, channel_id, da.USERS, da.CHANNEL)

@APP.route("/channel/join", methods=['POST'])
def join_channel():
    response = request.get_json()
    token = response['token']
    channel_id = response['channel_id']
    channel_join(token, channel_id, da.USERS, da.CHANNEL)
    return dumps({})

@APP.route("/channel/addowner", methods=['POST'])
def addowner_channel():
    response = request.get_json()
    token = response['token']
    channel_id = response['channel_id']
    u_id = response['u_id']
    channel_addowner(token, channel_id, u_id, da.USERS, da.CHANNEL)
    return dumps({})

@APP.route("/channel/removeowner", methods=['POST'])
def removeowner_channel():
    response = request.get_json()
    token = response['token']
    channel_id = response['channel_id']
    u_id = response['u_id']
    channel_removeowner(token, channel_id, u_id, da.USERS, da.CHANNEL)
    return dumps({})

@APP.route("/channels/list", methods=['GET'])
def list_channels():
    token = request.args.get('token')

    return channels_list(token, da.USERS, da.CHANNEL)

@APP.route("/channels/listall", methods=['GET'])
def listall_channels():
    token = request.args.get('token')

    return channels_listall(token, da.USERS, da.CHANNEL)

@APP.route("/channels/create", methods=['POST'])
def channels_create():
    response = request.get_json()
    token = response['token']
    name = response['name']
    is_public = response['is_public']

    channel_create(token, name, is_public, da.CHANNEL, da.USERS, da.ADMINS)

    return dumps({'channel_id': len(da.CHANNEL)})

#--------------------USER_FUNCTIONS--------------------
@APP.route('/user/profile', methods=['GET'])
def user_profile():
    token = request.args.get('token')
    u_id = int(request.args.get('u_id'))

    return user_profile_fn(token, u_id, da.USERS)

@APP.route('/user/profile/setname', methods=['PUT'])
def user_setname():
    data = request.get_json()
    token = data['token']
    name_first = data['name_first']
    name_last = data['name_last']

    user_setname_fn(token, name_first, name_last, da.USERS)

    return dumps({})

@APP.route('/user/profile/setemail', methods=['PUT'])
def user_setemail():
    data = request.get_json()
    token = data['token']
    email = data['email']

    user_setemail_fn(token, email, da.USERS)
    return dumps({})

@APP.route('/user/profile/sethandle', methods=['PUT'])
def user_sethandle():
    data = request.get_json()
    token = data['token']
    handle = data['handle_str']

    user_sethandle_fn(token, handle, da.USERS)

    return dumps({})

@APP.route('/users/all', methods=['GET'])
def users():
    token = request.args.get('token')

    return users_fn(token, da.USERS)

@APP.route('/admin/userpermission/change', methods=['POST'])
def user_permission_change():
    response = request.get_json()
    token = response['token']
    u_id = int(response['u_id'])
    permission_id = int(response['permission_id'])

    user_permission_change_fn(token, u_id, permission_id, da.USERS)
    return dumps({})

#--------------------MESSAGE_FUNCTIONS--------------------

@APP.route("/message/send", methods=['POST'])
def message_send():
    response = request.get_json()
    token = response['token']
    channel_id = response['channel_id']
    message = response['message']

    da.MESSAGE_COUNTER += 1

    return dumps(
        message_send_fn(token, channel_id, message, da.MESSAGES, \
            da.MESSAGE_COUNTER, da.USERS, da.CHANNEL)
    )

@APP.route("/message/sendlater", methods=['POST'])
def message_sendlater():
    response = request.get_json()
    token = response['token']
    channel_id = response['channel_id']
    message = response['message']
    time_sent = response['time_sent']

    return dumps(message_sendlater_fn(token, channel_id, message, time_sent, da.MESSAGES, \
                        da.MESSAGE_COUNTER, da.USERS, da.CHANNEL))


@APP.route("/message/react", methods=['POST'])
def message_react():
    response = request.get_json()
    token = response['token']
    message_id = response['message_id']
    react_id = response['react_id']

    message_react_fn(token, message_id, react_id, da.MESSAGES, da.USERS, da.CHANNEL)

    return dumps({})

@APP.route("/message/unreact", methods=['POST'])
def message_unreact():
    response = request.get_json()
    token = response['token']
    message_id = response['message_id']
    react_id = response['react_id']

    message_unreact_fn(token, message_id, react_id, da.MESSAGES, da.USERS, da.CHANNEL)

    return dumps({})

@APP.route("/message/pin", methods=['POST'])
def message_pin():
    response = request.get_json()
    token = response['token']
    message_id = response['message_id']

    message_pin_fn(token, message_id, da.MESSAGES, da.USERS, da.CHANNEL)

    return dumps({})

@APP.route("/message/unpin", methods=['POST'])
def message_unpin():
    response = request.get_json()
    token = response['token']
    message_id = response['message_id']

    message_unpin_fn(token, message_id, da.MESSAGES, da.USERS, da.CHANNEL)

    return dumps({})

@APP.route("/message/remove", methods=['DELETE'])
def message_remove():
    response = request.get_json()
    token = response['token']
    message_id = int(response['message_id'])

    message_remove_fn(token, message_id, da.MESSAGES, da.USERS, da.CHANNEL)

    return dumps({})

@APP.route("/message/edit", methods=['PUT'])
def message_edit():
    response = request.get_json()
    token = response['token']
    message_id = int(response['message_id'])
    message = response['message']

    message_edit_fn(token, message_id, message, da.MESSAGES, da.USERS, da.CHANNEL)

    return dumps({})

@APP.route("/search", methods=['GET'])
def search():
    token = request.args.get('token')
    query_str = str(request.args.get('query_str'))

    return search_fn(token, query_str, da.MESSAGES, da.USERS)

#--------------------BACKEND WORKSPACE RESET--------------------
@APP.route("/workspace/reset", methods=['POST'])
def reset():
    da.USERS = []
    da.MESSAGES = []
    da.MESSAGE_COUNTER = 0
    da.CHANNEL = []

    return dumps({})

#--------------------STANDUP FUNCTIONS--------------------
@APP.route("/standup/start", methods=['POST'])
def standup_start():
    data = request.get_json()
    token = data['token']
    channel_id = data['channel_id']
    length = data['length']
    return dumps(standup_start_fn(token, channel_id, length, da.CHANNEL, da.USERS))

@APP.route("/standup/active", methods=['GET'])
def standup_active():
    token = request.args.get('token')
    channel_id = request.args.get('channel_id')

    return dumps(standup_active_fn(token, channel_id, da.CHANNEL, da.USERS, da.MESSAGES))

@APP.route("/standup/send", methods=['POST'])
def standup_send():
    data = request.get_json()
    token = data['token']
    channel_id = data['channel_id']
    message = data['message']
    standup_send_fn(token, channel_id, message, da.CHANNEL, da.USERS)

    return dumps({})
#-------------------------function user profile uploadphoto-------------------
@APP.route('/user/profile/uploadphoto', methods=['POST'])
def user_profile_uploadpoto():
    data = request.get_json()
    token = data['token']
    img_url = data['img_url']
    x_start = data['x_start']
    y_start = data['y_start']
    x_end = data['x_end']
    y_end = data['y_end']
    backendurl = request.host
    user_profile_uploadphoto_fn(
        token, img_url, x_start, y_start, x_end, y_end, backendurl, da.USERS
    )
    return dumps({})


#-------------------------Pickling-------------------
def pickle_data():
    while True:
        pickledata = {}

        pickledata['pusers'] = da.USERS
        pickledata['pmessages'] = da.MESSAGES
        pickledata['pmsgcounter'] = da.MESSAGE_COUNTER
        pickledata['pchannels'] = da.CHANNEL
        #pprint.pprint(pickledata)
        #print("Pickel Called")

        with open('pickle_data.p', 'wb') as pickle_file:
            pickle.dump(pickledata, pickle_file)

        time.sleep(1)
    # return # Considered useless since this runs forever

#--------------------PASSWORD RESET FUNCTIONS--------------------
@APP.route('/auth/passwordreset/request', methods=['POST'])
def auth_request_reset():
    data = request.get_json()
    email = data['email']
    auth_request_reset_fn(email, da.USERS)
    return dumps({})

@APP.route('/auth/passwordreset/reset', methods=['POST'])
def auth_reset_password():
    data = request.get_json()
    code = data['reset_code']
    password = data['new_password']
    auth_reset_password_fn(code, password, da.USERS)
    return dumps({})

#--------------------USER REMOVE FUNCTIONS--------------------
@APP.route('/admin/user/remove', methods=['DELETE'])
def admin_user_remove():
    data = request.get_json()
    token = data['token']
    u_id = data['u_id']

    return user_remove_fn(token, u_id, da.USERS, da.CHANNEL, da.MESSAGES)

#--------------------BACKEND TEST FUNCTIONS--------------------
@APP.route('/users/getall', methods=['GET'])
def usersall():
    return dumps(da.USERS)

@APP.route('/messages/all', methods=['GET'])
def messageall():
    return dumps(da.MESSAGES)

@APP.route('/channels/all', methods=['GET'])
def channelsall():
    return dumps(da.CHANNEL)

#--------------------ACTUAL SERVER RUN--------------------
if __name__ == "__main__":

    try:
        P_LOAD_DATA = pickle.load(open("pickle_data.p", "rb"))
        da.USERS = P_LOAD_DATA['pusers']
        da.MESSAGES = P_LOAD_DATA['pmessages']
        da.MESSAGE_COUNTER = P_LOAD_DATA['pmsgcounter']
        da.CHANNEL = P_LOAD_DATA['pchannels']
    except Exception as exception:
        print(f'\n Exception {exception} has occured. Emptying Data File.')
        da.USERS = []
        da.MESSAGES = []
        da.MESSAGE_COUNTER = 0
        da.CHANNEL = []


    PTHREAD = threading.Thread(target=pickle_data, daemon=True)
    PTHREAD.start()

    APP.run(port=(da.PORT), debug=False)
