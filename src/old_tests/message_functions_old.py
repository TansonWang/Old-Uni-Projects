from json import dumps
from flask import Flask, request
from error import InputError, AccessError
#from channel_functions import channel_list  #Get the channel_list data, temp solution.
#from auth_functions import user_data        #Get the user_data data, temp. 
import time 
import datetime
import jwt
import threading
'''
    REMINDER! GET RID OF ALL OF THE LOOPS
'''
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

message_data = []
message_counter = 1

'''
def get_global_messages():
    global message_data
    return message_data
'''

@APP.route("/message/send", methods=['POST'])
def message_send(token, channel_id, message):

    #Getting information from request
    token = request.form.get('token')
    channel_id = request.form.get('channel_id')
    message = request.form.get('message')

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

    timer = threading.Timer((time_sent - time_now), message_send(token, channel_id, message))
    timer.start()

    return dumps({'message_id': message_counter + 1})


@APP.route("/message/react", methods=['POST']) 
def message_react(token, message_id, react_id):

    token = request.form.get('token')
    message_id = request.form.get('message_id')
    react_id = request.form.get("react_id")

    position = position_in_user_data(token, user_data)

    check_valid_react_id(react_id)
    check_valid_message_id(message_id, message_data)
    is_user_in_channel_mid(position, user_data, channel_list, message_id, message_data)
    check_if_deleted(message_id, message_data)

    for message in message_data:
        if message_id == message['message_id']:
            if user_data[position]['u_id'] in message['reacts']['u_id']:
                message['reacts']['is_this_user_reacted'] = True
                raise InputError(description='Already reacted by requested user')

            message['reacts']['u_id'].append(user_data[position]['u_id'])
            message['reacts']['is_this_user_reacted'] = True    #This is the scary one
            break
            


    return dumps({})

@APP.route("/message/unreact", methods=['POST'])
def message_unreact(token, message_id, react_id):

    token = request.form.get('token')
    message_id = request.form.get('message_id')
    react_id = request.form.get("react_id")

    position = position_in_user_data(token, user_data)

    check_valid_react_id(react_id)
    check_valid_message_id(message_id, message_data)
    is_user_in_channel_mid(position, user_data, channel_list, message_id, message_data)
    check_if_deleted(message_id, message_data)

    for message in message_data:
        if message_id == message['message_id']:
            if user_data[position]['u_id'] not in message['reacts']['u_id']:
                message['reacts']['is_this_user_reacted'] = False
                raise InputError(description='No reaction to unreact')

            message['reacts']['u_id'].remove(user_data[position]['u_id'])
            message['reacts']['is_this_user_reacted'] = False   #This is the scary one
            break

    return dumps({})

@APP.route("/message/pin", methods=['POST'])
def message_pin(token, message_id):

    token = request.form.get('token')
    message_id = request.form.get('message_id')

    position = position_in_user_data(token, user_data)
    check_valid_message_id(message_id, message_data)
    check_user_is_owner(position, user_data, channel_list)
    is_user_in_channel_mid(position, user_data, channel_list, message_id, message_data)
    check_if_deleted(message_id, message_data)

    for message in message_data:
        if message_id == message['message_id']:
            if message['is_pinned'] == True:
                raise InputError(description='Message is already pinned')
            else: 
                message['is_pinned'] = True

    return dumps({})

@APP.route("/message/unpin", methods=['POST'])
def message_unpin(token, message_id):

    token = request.form.get('token')
    message_id = request.form.get('message_id')

    position = position_in_user_data(token, user_data)
    check_valid_message_id(message_id, message_data)
    check_user_is_owner(position, user_data, channel_list)
    is_user_in_channel_mid(position, user_data, channel_list, message_id, message_data)
    check_if_deleted(message_id, message_data)

    for message in message_data:
        if message_id == message['message_id']:
            if message[is_pinned] == False:
                raise InputError(description='Message is already unpinned')
            else: 
                message['is_pinned'] = False

    return dumps({})

@APP.route("/message/remove", methods=['DELETE'])
def message_remove(token, message_id):

    token = request.form.get('token')
    message_id = request.form.get('message_id')
    message_index = message_id - 1

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

'''
HELPER FUNCTIONS
'''

def position_in_user_data(token, user_data):
    called_by = 0
    for user in user_data:
        if token == user['token']:
            break
        called_by += 1
    return called_by

def check_valid_message(message):
    if len(message) > 1000: 
        raise InputError(description='Message is more than 1000 characters')
    elif len(message) == 0:
        raise InputError(description='Message cannot be nothing')

def check_valid_react_id(react_id):
    if react_id != 1:
        raise InputError(description='Invalid react_id')

def is_user_in_channel(position, user_data, channel_id, channel_list):
    for channel in channel_list:
        if channel['id'] == channel_id:
            #Need to double check that I'm acessing the right keys in channel_list and user_data
            if user_data[position]['u_id'] not in channel['users']:
                raise AccessError(description='User not in channel')
        break

def is_user_in_channel_mid(position, user_data, channel_list, message_id):
    channel_id = channel_id_from_message_id(message_id, message_data)
    is_user_in_channel(position, user_data, channel_id, channel_list)
    
def check_valid_message_id(message_id, message_data):
    if message_id > len(message_data) or message_id < 1:
        raise InputError(description='Invalid message_id')
    for message in message_data:
        if message['message'] == None:
            raise InputError(description='Message of message_id has been deleted')

def check_user_is_owner(position, message_id, user_data, channel_list):
    #Currently assumes slackr owner is automatically added to the channel owner list
    #If not i could just check with an if statment0
    channel_id = channel_id_from_message_id(message_id, message_data)
    for channel in channel_list:
        if channel['id'] == channel_id:
            if user_data[position]['u_id'] not in channel['owners']:
                raise InputError(description='User is not an owner')

def channel_id_from_message_id(message_id, message_data):
    channel_id = -1
    for message in message_data:
        if message['message_id'] == message_id:
            channel_id = message['in_channel']
    if channel_id == -1:
        raise InputError(description='SOMETHING HAS GONE WRONG IN FINDING CHANNEL_ID')
    return channel_id

def check_if_deleted(message_id, message_data):
    message_index = message_id - 1
    if message_data[message_index]['message_id'] == message_id:
        if message[message_index]['message'] == None:
            raise InputError(description='Message has been deleted')