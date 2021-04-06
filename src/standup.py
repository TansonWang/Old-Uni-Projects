import time
import datetime
from datetime import timezone

from message_functions_fn import position_in_user_data
from error import AccessError, InputError
from auth import get_user_from_token
import data as da

#Assume users thats not in the channel cannot start a standup
def standup_start_fn(token, channel_id, length, channels, users):
    #position_in_user will check if it is a valid token
    position_in_user_data(token, users)
    u_id = get_user_from_token(token)

    for channel in channels:
        if channel['id'] == int(channel_id):
            if u_id not in channel['users']:
                raise AccessError(description="The authorised user is not a member of the channel")
            if channel['standup']['is_active']:
                raise InputError("An active standup is currently running in this channel")
            channel['standup']['start_member'] = u_id
            channel['standup']['is_active'] = True
            channel['standup']['time_finish'] = \
                int(time.mktime((datetime.datetime.now() \
                    + datetime.timedelta(seconds=length)).timetuple()))
            return {'time_finish':(channel['standup'])['time_finish']}

    raise InputError(description="Channel ID is not a valid channel")

def standup_active_fn(token, channel_id, channels, users, messages):
    #position_in_user will check if it is a valid token
    position_in_user_data(token, users)

    for channel in channels:
        #once we get to the time standup finish time we send message
        if (channel['standup'])['time_finish'] and \
            (channel['standup'])['is_active'] and \
                int(time.mktime(datetime.datetime.now().timetuple())) >= \
                    (channel['standup'])['time_finish']:

            time_now = datetime.datetime.now()
            #print(time_now)
            time_now = time_now.replace(tzinfo=timezone.utc).timestamp()
            new_message = create_message((channel['standup'])['start_member'], \
                (channel['standup'])['message'], time_now, channel_id)
            messages.append(new_message)
            (channel['standup'])['start_member'] = None
            (channel['standup'])['is_active'] = False
            (channel['standup'])['message'] = []
            (channel['standup'])['time_finish'] = None

            return {'is_active':False, 'time_finish':None}

        if not (channel['standup'])['is_active']:
            return {'is_active':False, 'time_finish':None}

        return {'is_active':True, 'time_finish':(channel['standup'])['time_finish']}

    raise InputError(description="Channel ID is not a valid channel, standup active")

def standup_send_fn(token, channel_id, message, channels, users):
    u_id = None
    user_handle = None
    channel_id = int(channel_id)
    for user in users:
        if user['token'] == token:
            u_id = user['u_id']
            user_handle = user['handle_str']
            break
    else:
        raise AccessError(description="Invalid Token, Standup_send")

    for channel in channels:
        if channel['id'] == channel_id:
            if u_id not in channel['users']:
                raise AccessError("User is not in this channel cannot send Stand Up")

            if not (channel['standup'])['is_active']:
                raise InputError("An active standup is not currently running in this channel")

            if len(message) > 1000:
                raise InputError("Message is more than 1000 characters")

            message = str(user_handle + ": " + message)
            message = '\n'.join([message, ''])
            (channel['standup'])['message'].append(message)

            return {}


    raise InputError(description="Channel ID is not a valid channel")

def create_message(u_id, message, time_created, channel_id):
    da.MESSAGE_COUNTER += 1
    new_message = {
        'message_id':int(da.MESSAGE_COUNTER),
        'u_id':u_id,
        'message':message,
        'time_created':time_created,
                'reacts': [{
                    'react_id': 1,
                    'u_ids': [],
                    'is_this_user_reacted': False
                }],
        'is_pinned':False,
        'in_channel':int(channel_id)
    }

    return new_message
