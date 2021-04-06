'''
COMP1531 Major Project: Slackr
Term 1 Year 2020
Involved: Tanson Wang
          James Lu
          Alan Vo

Description:
This file contains the following functions:
 - channel_create for create_channel
 - channel_invite for invite_channel
 - channel_details for details_channel
 - channel_messages for messages_channel
 - channel_leave for leave_channel
 - channel_join for join_channel
 - channel_addowner for addowner_channel
 - channel_removeowner for removeowner_channel
 - channel_list for list_channel
 - channel_listall for listall_channel
'''
from json import dumps
from error import InputError, AccessError

def channel_create(token, name, is_public, channel, users, admins):
    new_channel = {
        'channel_name': name,
        'is_public': is_public,
        'id': 0,
        'users': [],
        'owners': [],
        'standup': {
            'start_member':None,
            'is_active': False,
            'message':[],
            'time_finish':None
        }
    }

    new_channel['id'] = len(channel) + 1
    for user in users:
        if user['token'] == token:
            new_channel['users'].append(user['u_id'])
            new_channel['owners'].append(user['u_id'])
            break
    else:
        raise AccessError(description='Invalid Token, channel_invite')

    for admin in admins:
        new_channel['users'].append(admin['u_id'])
        new_channel['owners'].append(admin['u_id'])

    channel.append(new_channel)
    return dumps({})

def channel_invite(token, channel_id, invitee, users, channels):
    inviter = None
    invitee = int(invitee)
    channel_id = int(channel_id)

    for user in users:
        if user['token'] == token:
            inviter = user['u_id']
            break
    else:
        raise AccessError(description='Invalid Token, channel_invite')

    for user in users:
        if user['u_id'] == invitee:
            break
    else:
        raise InputError(description="Invitee does not exist.")

    for channel in channels:
        if channel['id'] == channel_id:
            if not inviter in channel['users']:
                raise AccessError(description="Inviter is not part of the channel")

            if invitee in channel['users']:
                raise InputError(description="Invitee is already part of the channel")

            channel['users'].append(invitee)
            break
    else:
        raise InputError(description="Channel does not exist. Channel_invite")

    return dumps({})

def channel_details(token, channel_id, channels, users):
    u_id = None
    for user in users:
        if token == user['token']:
            u_id = user['u_id']
            break
    else:
        raise AccessError(description='Invalid Token, channel_details')

    owner_members = []
    all_members = []
    for channel in channels:
        if channel['id'] == channel_id:
            if u_id in channel['users']:
                for u_id in channel['owners']:
                    owner_members.append({'u_id': users[u_id]['u_id'],
                                          'name_first': users[u_id]['name_first'],
                                          'name_last': users[u_id]['name_last'],
                                          'profile_img_url':users[u_id]['profile_img_url']
                                          })
                for u_id in channel['users']:
                    all_members.append({'u_id': users[u_id]['u_id'],
                                        'name_first': users[u_id]['name_first'],
                                        'name_last': users[u_id]['name_last'],
                                        'profile_img_url':users[u_id]['profile_img_url']
                                        })
                return dumps({
                    'name': channel['channel_name'],
                    'owner_members': owner_members,
                    'all_members': all_members
                    })
            raise AccessError(description="You are not a member of this channel.")
    raise AccessError(description="Channel does not exist. Channel_details")

def channel_messages(token, channel_id, start, CHANNELS, USERS, MESSAGES):

    channel_is_valid(channel_id, CHANNELS)

    index = position_in_user_data(token, USERS)
    u_id = USERS[index]['u_id']

    if u_id not in CHANNELS[int(channel_id) - 1]['users']:
        raise AccessError("Authorised user is not a member of channel with channel_id")

    if int(start) > len(MESSAGES) and MESSAGES:
        raise InputError("start is greater than the total number of messages in the channel")

    return_messages = []
    if MESSAGES:
        reversedmsg = reversed(MESSAGES)
        for message in reversedmsg:
            if int(message['in_channel']) == int(channel_id):
                reactbool = False
                if u_id in message['reacts'][0]['u_ids']:
                    reactbool = True
                return_messages.append({
                    'message_id': message['message_id'],
                    'u_id': message['u_id'],
                    'message': message['message'],
                    'time_created': message['time_created'],
                    'reacts': [{
                        'react_id': 1,
                        'u_ids': message['reacts'][0]['u_ids'],
                        'is_this_user_reacted': reactbool
                    }],
                    'is_pinned': message['is_pinned']
                })

    return dumps({'messages': return_messages, 'start': int(start), 'end': -1})

def channel_leave(token, channel_id, users, channels):
    u_id = 0
    channel_id = int(channel_id)
    for user in users:
        if user['token'] == token:
            u_id = user['u_id']
            break
    else:
        raise InputError(description="Invalid Token, Channel Leave")

    for channel in channels:
        if channel['id'] == channel_id:
            if u_id in channel['users']:
                channel['users'].remove(u_id)
                if u_id in channel['owners']:
                    channel['owners'].remove(u_id)
                return dumps({})
            raise AccessError(description="You are not in this channel.")
    raise InputError(description="Channel does not exist. Channel_leave")

def channel_join(token, channel_id, users, channels):
    u_id = None
    channel_id = int(channel_id)
    for user in users:
        if user['token'] == token:
            u_id = user['u_id']
            break
    else:
        raise InputError(description="Invalid Token, Channel Join")
    user_index = position_in_user_data(token, users)

    for channel in channels:
        if channel['id'] == channel_id:
            if u_id in channel['users'] or u_id in channel['owners']:
                raise AccessError(description="Already joined in channel")

            if channel['is_public']:
                channel['users'].append(u_id)
                if users[user_index]['permission_id'] == 1:
                    channel['owners'].append(u_id)
                return dumps({})
            if not channel['is_public']:
                if users[user_index]['permission_id'] == 1:
                    channel['users'].append(u_id)
                    channel['owners'].append(u_id)
                return dumps({})

            raise AccessError(description="Channel was private.")
    raise InputError(description="Channel does not exist. Channel_join")

def channel_addowner(token, channel_id, invitee, users, channels):
    inviter = None
    invitee = int(invitee)
    channel_id = int(channel_id)
    for user in users:
        if user['token'] == token:
            inviter = user['u_id']
            break
    else:
        raise InputError(description="Invalid Token, Channel Add Owner")

    for channel in channels:
        if channel['id'] == channel_id:
            if not inviter in channel['owners']:
                raise AccessError(description="Non-owners can not add new owners.")
            if invitee in channel['owners']:
                raise InputError(description="Invitee is already an owner.")
            channel['owners'].append(invitee)
            return dumps({})
    raise InputError(description="Channel does not exist.")

def channel_removeowner(token, channel_id, target, users, channels):
    remover = int(0)
    target = int(target)
    channel_id = int(channel_id)
    for user in users:
        if user['token'] == token:
            remover = user['u_id']
            break
    else:
        raise InputError(description="Invalid Token, Channel Remove Owner")

    for channel in channels:
        if channel['id'] == channel_id:
            if not remover in channel['owners']:
                raise AccessError(description="Non-owners can not remove owners.")
            if not target in channel['owners']:
                raise InputError(description="Target is not an owner in this channel.")
            channel['owners'].remove(target)
            return dumps({})
    raise InputError(description="Channel does not exist. Channel_removeowner")

def channels_list(token, users, channels):
    u_id = None
    return_list = []
    for user in users:
        if token == user['token']:
            u_id = user['u_id']
            break
    else:
        raise InputError(description="Invalid Token, channels_list")

    for channel in channels:
        if u_id in channel['users']:
            return_list.append({
                'channel_id': channel['id'],
                'name': channel['channel_name']
            })

    return dumps({'channels':return_list})

def channels_listall(token, users, channels):
    return_list = []
    for user in users:
        if token == user['token']:
            break
    else:
        raise InputError(description="Invalid Token, channels_listall")

    for channel in channels:
        return_list.append({
            'channel_id': channel['id'],
            'name': channel['channel_name']
        })

    return dumps({'channels':return_list})

# Helper functions
def channel_is_valid(channel_id, channels):
    '''check if channel exists'''
    for channel in channels:
        if channel['id'] == channel_id:
            return
    raise AccessError(description="Channel does not exist. Channel_is_valid")

def position_in_user_data(token, users):
    '''Get the index in users for which token belongs to'''
    called_by = 0
    for user in users:
        if token == user['token']:
            return called_by
        called_by += 1
    raise AccessError(description='Invalid Token')
