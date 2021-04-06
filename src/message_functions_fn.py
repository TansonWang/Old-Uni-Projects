import threading
from datetime import timezone, datetime
from json import dumps
import pytz
from error import InputError, AccessError


def message_send_fn(token, channel_id, message, MESSAGES, MESSAGE_COUNTER, USERS, channel_list):

    position = position_in_user_data(token, USERS)
    is_user_in_channel(position, USERS, channel_id, channel_list)
    check_valid_message(message)
    time_now = datetime.now()
    #print(time_now)
    time_now = time_now.replace(tzinfo=timezone.utc).timestamp()
    #print(time_now)

    append_message = {
        'message_id': int(MESSAGE_COUNTER),
        'u_id': int(USERS[position]['u_id']),
        'message': message,
        'time_created': time_now,
        'reacts': [{
            'react_id': 1,
            'u_ids': [],
            'is_this_user_reacted': False
            }],
        'is_pinned': False,
        'in_channel': int(channel_id)
    }
    MESSAGES.append(append_message)

    return dumps({'message_id': MESSAGE_COUNTER})

def message_sendlater_fn(token, channel_id, message, time_sent, MESSAGES, \
                        MESSAGE_COUNTER, USERS, channel_list):

    position = position_in_user_data(token, USERS)
    is_user_in_channel(position, USERS, channel_id, channel_list)
    check_valid_message(message)

    tz = pytz.timezone("Australia/NSW")
    time_now = datetime.timestamp(datetime.now(tz))

    print('\ntime_now is: ' + str(time_now))
    print('time_sent is: ' + str(time_sent))

    interval = time_sent - time_now
    print('sent - d_aware is: ' + str(interval) + '\n')


    if interval < 0:
        raise InputError(description='Time sent can not be less than current time.')

    timer = threading.Timer(int(interval), \
            message_send_fn, \
            [token, channel_id, message, MESSAGES, MESSAGE_COUNTER, USERS, channel_list])
    timer.start()

    return dumps({'message_id': MESSAGE_COUNTER})


def message_react_fn(token, message_id, react_id, MESSAGES, USERS, channel_list):

    message_index = int(message_id - 1)
    react_index = int(react_id) - 1
    position = position_in_user_data(token, USERS)
    #print(react_id)
    check_valid_react_id(react_id)
    check_valid_message_id(message_id, MESSAGES)
    is_user_in_channel_mid(position, USERS, channel_list, message_id, MESSAGES)
    check_if_deleted(message_id, MESSAGES)

    if USERS[position]['u_id'] in MESSAGES[message_index]['reacts'][react_index]['u_ids']:
        MESSAGES[message_index]['reacts'][react_index]['is_this_user_reacted'] = True
        raise InputError(description='Already reacted by requested user')
    else:
        MESSAGES[message_index]['reacts'][react_index]['u_ids'].append(USERS[position]['u_id'])
        MESSAGES[message_index]['reacts'][react_index]['is_this_user_reacted'] = True

    return dumps({})

def message_unreact_fn(token, message_id, react_id, MESSAGES, USERS, channel_list):

    message_index = int(message_id) - 1
    react_index = int(react_id) - 1
    position = int(position_in_user_data(token, USERS))

    check_valid_react_id(react_id)
    check_valid_message_id(message_id, MESSAGES)
    is_user_in_channel_mid(position, USERS, channel_list, message_id, MESSAGES)
    check_if_deleted(message_id, MESSAGES)

    if USERS[position]['u_id'] not in MESSAGES[message_index]['reacts'][react_index]['u_ids']:
        MESSAGES[message_index]['reacts'][react_index]['is_this_user_reacted'] = False
        raise InputError(description='No reaction to unreact for specified react_id')
    else:
        MESSAGES[message_index]['reacts'][react_index]['u_ids'].remove(USERS[position]['u_id'])
        MESSAGES[message_index]['reacts'][react_index]['is_this_user_reacted'] = False

    return dumps({})

def message_pin_fn(token, message_id, MESSAGES, USERS, channel_list):

    message_index = message_id - 1

    position = position_in_user_data(token, USERS)
    check_valid_message_id(message_id, MESSAGES)
    is_user_in_channel_mid(position, USERS, channel_list, message_id, MESSAGES)
    check_user_is_owner(position, message_id, USERS, channel_list, MESSAGES)
    check_if_deleted(message_id, MESSAGES)

    if MESSAGES[message_index]['is_pinned']:
        raise InputError(description='Message is already pinned')
    else:
        MESSAGES[message_index]['is_pinned'] = True

    return dumps({})

def message_unpin_fn(token, message_id, MESSAGES, USERS, channel_list):

    message_index = message_id - 1

    position = position_in_user_data(token, USERS)
    check_valid_message_id(message_id, MESSAGES)
    is_user_in_channel_mid(position, USERS, channel_list, message_id, MESSAGES)
    check_user_is_owner(position, message_id, USERS, channel_list, MESSAGES)
    check_if_deleted(message_id, MESSAGES)

    if not MESSAGES[message_index]['is_pinned']:
        raise InputError(description='Message is already unpinned')
    else:
        MESSAGES[message_index]['is_pinned'] = False

    return dumps({})


def message_remove_fn(token, message_id, MESSAGES, USERS, channel_list):

    message_index = message_id - 1

    position = position_in_user_data(token, USERS)
    check_valid_message_id(message_id, MESSAGES)
    is_user_in_channel_mid(position, USERS, channel_list, message_id, MESSAGES)
    check_if_deleted(message_id, MESSAGES)

    if USERS[position]['permission_id'] != 1 and \
    MESSAGES[message_index]['u_id'] != USERS[position]['u_id']:
        raise AccessError(description='Permission denied')
    else:
        MESSAGES[message_index]['message'] = None

    return dumps({})

def message_edit_fn(token, message_id, message, MESSAGES, USERS, channel_list):

    message_index = message_id - 1

    position = position_in_user_data(token, USERS)
    check_valid_message(message)
    check_valid_message_id(message_id, MESSAGES)
    is_user_in_channel_mid(position, USERS, channel_list, message_id, MESSAGES)
    check_if_deleted(message_id, MESSAGES)

    if USERS[position]['permission_id'] != 1 and \
    MESSAGES[message_index]['u_id'] != USERS[position]['u_id']:
        raise AccessError(description='Permission denied')
    else:
        MESSAGES[message_index]['message'] = message

    return dumps({})

def search_fn(token, query_str, MESSAGES, USERS):

    position = position_in_user_data(token, USERS)
    u_id = USERS[position]['u_id']

    messages_return = []

    for message in reversed(MESSAGES):
        if message['message'] is None:
            continue
        if query_str in message['message']:
            reactbool = False
            if u_id in message['reacts'][0]['u_ids']:
                reactbool = True
            messages_return.append({
                'message_id': message['message_id'],
                'u_id': message['u_id'],
                'message': message['message'],
                'time_created': message['time_created'],
                'reacts':[{
                    'react_id': 1,
                    'u_ids': message['reacts'][0]['u_ids'],
                    'is_this_user_reacted': reactbool
                }],
                'is_pinned': message['is_pinned']
            })

    return dumps({'messages': messages_return})

#Helper Functions

def position_in_user_data(token, USERS):
    '''Get the index in USERS for which token belongs to'''
    called_by = 0
    for user in USERS:
        if token == user['token']:
            return int(called_by)
        called_by += 1
    raise AccessError(description='Invalid Token')

def check_valid_message(message):
    '''Check that the message is valid'''
    if len(message) > 1000:
        raise InputError(description='Message is more than 1000 characters')
    elif message == '':
        raise InputError(description='Message cannot be nothing')

def check_valid_react_id(react_id):
    '''Check that the react_id is valid'''
    if react_id != 1:
        raise InputError(description='Invalid react_id')

def is_user_in_channel(position, USERS, channel_id, channel_list):
    '''Check if the user is apart of a channel'''
    if USERS[position]['u_id'] not in channel_list[int(channel_id) - 1]['users']:
        raise AccessError(description='User not in channel')

def is_user_in_channel_mid(position, USERS, channel_list, message_id, MESSAGES):
    '''Check if the user is apart of a channel using message_id'''
    channel_id = channel_id_from_message_id(message_id, MESSAGES)
    is_user_in_channel(position, USERS, channel_id, channel_list)

def check_valid_message_id(message_id, MESSAGES):
    '''Check if a message_id corresponds to a valid message'''
    if message_id > len(MESSAGES) or message_id < 1:
        raise InputError(description='Invalid message_id' + str(message_id))
    check_if_deleted(message_id, MESSAGES)

def check_user_is_owner(position, message_id, USERS, channel_list, MESSAGES):
    '''Check that the user is has owner permissions'''
    #Currently assumes slackr owner is automatically added to the channel owner list
    #If not i could just check with an if statment0
    channel_id = channel_id_from_message_id(message_id, MESSAGES)
    for channel in channel_list:
        if channel['id'] == channel_id:
            if USERS[position]['u_id'] not in channel['owners']:
                raise InputError(description='User is not an owner')

def channel_id_from_message_id(message_id, MESSAGES):
    '''From the message_id, get the corresponding channel_id assuming message_id is valid'''
    channel_id = -1
    for message in MESSAGES:
        if message['message_id'] == message_id:
            channel_id = message['in_channel']
    if channel_id == -1:
        raise InputError(description='SOMETHING HAS GONE WRONG IN FINDING CHANNEL_ID')
    return channel_id

def check_if_deleted(message_id, MESSAGES):
    '''Checks if a message has been deleted. Deleted messages have data; 'message': None'''
    message_index = message_id - 1
    if MESSAGES[message_index]['message_id'] == message_id:
        if MESSAGES[message_index]['message'] is None:
            raise InputError(description='Message has been deleted')
