from json import dumps
from flask import Flask, request
from error import InputError, AccessError
from data import get_global_channel, get_global_users, get_global_messages, message_counter
import time 
import datetime
import jwt
import threading
'''
message_data = [{'message_id': '', 
            'u_id': '', 
            'message': '', 
            'time_created': '', 
            'reacts': [{
                'react_id': ''
                'u_id;: []
                'is_this_user_reacted': booleen
            }]
            'is_pinned': ''
            'in_channel': ''
}]
'''
'''
message_data = []
message_counter = 1
'''

def get_global_messages():
    global message_data
    return message_data

@APP.route("/message/send", methods=['POST'])
def message_send(token, channel_id, message):

    #Getting information from request
    token = request.form.get('token')
    channel_id = request.form.get('channel_id')
    message = request.form.get('message')
    message_data = get_global_messages()
    user_data = get_global_users()

    #Determinig which user in the list of diciontarys requested
    position = position_in_user_data(token, user_data)

    #Checking for correct input
    is_user_in_channel(position, user_data, channel_id, channel_list)
    check_valid_message(message)

    append_message = {'message_id': message_counter, 
            'u_id': user_data[position]['u_id'],
            'message': message, 
            'time_created': datetime.now(), 
            'reacts': [{
                'react_id': 1,
                'u_id': [],
                'is_this_user_reacted': False
            }], 
            #Cheating since theres only one react_id for now
            'is_pinned': False,
            'in_channel': channel_id
}
    message_data.append(append_message)

    message_counter += 1

    return dumps({'message_id': message_counter})

@APP.route("/message/sendlater", methods=['POST']) #UNIMPLIMENTED
def message_sendlater(token, channel_id, message, time_sent):

    token = request.form.get('token')
    channel_id = request.form.get('channel_id')
    message = request.form.get('message')
    time_sent = request.form.get('time_sent')

    is_user_in_channel(position, user_data)
    check_valid_message(message)
    time_now = datetime.now()
    time_now = time_now.replace(tzinfo=timezone.utc).timestamp()

    if time_sent < time_now:
        raise InputError(description='time_sent is in the past')

    timer = threading.Timer((time_sent - time_now), message_send(token, channel_id, message))
    timer.start()

    return dumps({'message_id': message_counter + 1})


@APP.route("/message/react", methods=['POST']) 
def message_react(token, message_id, react_id):

    token = request.form.get('token')
    message_id = request.form.get('message_id')
    react_id = request.form.get("react_id")
    message_index = message_id - 1
    message_data = get_global_messages()
    user_data = get_global_users()
    channel_list = get_global_channel()

    position = position_in_user_data(token, user_data)

    check_valid_react_id(react_id)
    check_valid_message_id(message_id, message_data)
    is_user_in_channel_mid(position, user_data, channel_list, message_id, message_data)
    check_if_deleted(message_id, message_data)

    if user_data[position]['u_id'] in message_data[message_index]['reacts']['u_id']:
            message['reacts']['is_this_user_reacted'] = True
            raise InputError(description='Already reacted by requested user')
    else:
        message['reacts']['u_id'].append(user_data[position]['u_id'])
        message['reacts']['is_this_user_reacted'] = True    #This is the scary one

    return dumps({})

@APP.route("/message/unreact", methods=['POST'])
def message_unreact(token, message_id, react_id):

    token = request.form.get('token')
    message_id = request.form.get('message_id')
    react_id = request.form.get("react_id")
    message_index = message_id - 1
    message_data = get_global_messages()
    user_data = get_global_users()
    channel_list = get_global_channel()

    position = position_in_user_data(token, user_data)

    check_valid_react_id(react_id)
    check_valid_message_id(message_id, message_data)
    is_user_in_channel_mid(position, user_data, channel_list, message_id, message_data)
    check_if_deleted(message_id, message_data)

    if user_data[position]['u_id'] not in message_data[message_index]['reacts']['u_id']:
            message['reacts']['is_this_user_reacted'] = False
            raise InputError(description='Already reacted by requested user')
    else:
        message['reacts']['u_id'].remove(user_data[position]['u_id'])
        message['reacts']['is_this_user_reacted'] = False    #This is the scary one

    return dumps({})

@APP.route("/message/pin", methods=['POST'])
def message_pin(token, message_id):

    token = request.form.get('token')
    message_id = request.form.get('message_id')
    message_index = message_id - 1
    message_data = get_global_messages()
    user_data = get_global_users()
    channel_list = get_global_channel()

    position = position_in_user_data(token, user_data)
    check_valid_message_id(message_id, message_data)
    check_user_is_owner(position, user_data, channel_list)
    is_user_in_channel_mid(position, user_data, channel_list, message_id, message_data)
    check_if_deleted(message_id, message_data)

    if message_data[message_index]['is_pinned'] == True:
        raise InputError(description='Message is already pinned')
    else: 
        message_data[message_index]['is_pinned'] = True

    return dumps({})

@APP.route("/message/unpin", methods=['POST'])
def message_unpin(token, message_id):

    token = request.form.get('token')
    message_id = request.form.get('message_id')
    message_data = get_global_messages()
    user_data = get_global_users()
    channel_list = get_global_channel()

    position = position_in_user_data(token, user_data)
    check_valid_message_id(message_id, message_data)
    check_user_is_owner(position, user_data, channel_list)
    is_user_in_channel_mid(position, user_data, channel_list, message_id, message_data)
    check_if_deleted(message_id, message_data)

    if message_data[message_index]['is_pinned'] == False:
        raise InputError(description='Message is already unpinned')
    else: 
        message_data[message_index]['is_pinned'] = False

    return dumps({})

@APP.route("/message/remove", methods=['DELETE'])
def message_remove(token, message_id):

    token = request.form.get('token')
    message_id = request.form.get('message_id')
    message_index = message_id - 1
    message_data = get_global_messages()
    user_data = get_global_users()
    channel_list = get_global_channel()

    position = position_in_user_data(token, user_data)
    check_valid_message_id(message_id, message_data)
    check_user_is_owner(position, user_data, channel_list)
    is_user_in_channel_mid(position, user_data, channel_list, message_id, message_data)
    check_if_deleted(message_id, message_data)

    if user_data[position]['permission_id'] != 1 and message_data[message_index]['u_id'] != user_data[position]['u_id']:
        raise AccessError(description='Permission denied')
    else:
        message_data[message_position]['message'] = None

    return dumps({})

@APP.route("/message/edit", methods=['PUT'])
def message_edit(token, message_id, message):

    token = request.form.get('token')
    message_id = request.form.get('message_id')
    message = request.form.get('message')
    message_data = get_global_messages()
    user_data = get_global_users()
    channel_list = get_global_channel()

    position = position_in_user_data(token, user_data)
    check_valid_message(message)
    check_valid_message_id(message_id, message_data)
    check_user_is_owner(position, user_data, channel_list)
    is_user_in_channel_mid(position, user_data, channel_list, message_id, message_data)
    check_if_deleted(message_id, message_data)

    if user_data[position]['permission_id'] != 1 and message_data[message_position]['u_id'] != user_data[position]['u_id']:
        raise AccessError(description='Permission denied')
    else:
        message_data[message_position]['message'] = message

    return dumps({})

@APP.route("/search", methods=['GET'])
def search(token, query_str):

    token = request.args.get('token')
    query_str = request.args.get('query_str')
    message_data = get_global_messages()
    user_data = get_global_users()

    position = position_in_user_data(token, user_data)
    u_id = user_data[position]['u_id']

    messages_return = []

    for message in message_data:
        if query_str in message['message']:
            if u_id in message['reacts']['u_id']:
                message['reacts']['is_this_user_reacted'] = True
            else:
                message['reacts']['is_this_user_reacted'] = False
        messages_return.append(message)

    return dumps(messages_return)

'''
HELPER FUNCTIONS
'''

def position_in_user_data(token, user_data):
    '''Get the index in user_data for which token belongs to'''
    called_by = 0
    for user in user_data:
        if token == user['token']:
            break
        called_by += 1
    return called_by

def check_valid_message(message):
    '''Check that the message is valid'''
    if len(message) > 1000: 
        raise InputError(description='Message is more than 1000 characters')
    elif len(message) == 0:
        raise InputError(description='Message cannot be nothing')

def check_valid_react_id(react_id):
    '''Check that the react_id is valid'''
    if react_id != 1:
        raise InputError(description='Invalid react_id')

def is_user_in_channel(position, user_data, channel_id, channel_list):
    '''Check if the user is apart of a channel'''
    for channel in channel_list:
        if channel['id'] == channel_id:
            #Need to double check that I'm acessing the right keys in channel_list and user_data
            if user_data[position]['u_id'] not in channel['users']:
                raise AccessError(description='User not in channel')
        break

def is_user_in_channel_mid(position, user_data, channel_list, message_id):
    '''Check if the user is apart of a channel using message_id'''
    channel_id = channel_id_from_message_id(message_id, message_data)
    is_user_in_channel(position, user_data, channel_id, channel_list)
    
def check_valid_message_id(message_id, message_data):
    '''Check if a message_id corresponds to a valid message'''
    if message_id > len(message_data) or message_id < 1:
        raise InputError(description='Invalid message_id')
    check_if_deleted(message_id, message_data)

def check_user_is_owner(position, message_id, user_data, channel_list):
    '''Check that the user is has owner permissions'''
    #Currently assumes slackr owner is automatically added to the channel owner list
    #If not i could just check with an if statment0
    channel_id = channel_id_from_message_id(message_id, message_data)
    for channel in channel_list:
        if channel['id'] == channel_id:
            if user_data[position]['u_id'] not in channel['owners']:
                raise InputError(description='User is not an owner')

def channel_id_from_message_id(message_id, message_data):
    '''From the message_id, get the corresponding channel_id'''
    '''Assumes that the message_id is valid'''
    channel_id = -1
    for message in message_data:
        if message['message_id'] == message_id:
            channel_id = message['in_channel']
    if channel_id == -1:
        raise InputError(description='SOMETHING HAS GONE WRONG IN FINDING CHANNEL_ID')
    return channel_id

def check_if_deleted(message_id, message_data):
    '''Checks if a message has been deleted. Deleted messages have data; 'message': None'''
    message_index = message_id - 1
    if message_data[message_index]['message_id'] == message_id:
        if message[message_index]['message'] == None:
            raise InputError(description='Message has been deleted')