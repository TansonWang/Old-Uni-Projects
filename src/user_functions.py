'''
COMP1531 Major Project: Slackr
Term 1 Year 2020
Involved: Tanson Wang
          James Lu
          Yucheng Shan

Description:
This file contains the following functions:
 - users_fn for users_all
 - user_profile_fn for user_profile
 - user_setname_fn for user_setname
 - user_setemail_fn for user_setemail
 - user_sethandle_fn for user_sethandle
 - user_permission_change_fn for user_permission_change
 - user_profile_uploadphoto_fn for user_profile_uploadphoto
 - user_remove_fn for user_remove
'''
import re
from json import dumps
import requests
from error import InputError, AccessError
from process_img import process_img
from auth import get_user_from_token
from message_functions_fn import position_in_user_data

def users_fn(token, users):
    for user in users:
        if user['token'] == token:
            return dumps({'users': users})
    raise AccessError(description='Invalid token, Users_fn')

def user_profile_fn(token, u_id, users):
    #check token
    tokenbool = True
    for user in users:
        if user['token'] == token:
            tokenbool = False
    if tokenbool:
        raise AccessError(description='Invalid Token')

    for user in users:
        if user['u_id'] == u_id:
            return dumps({'user': user})
    raise AccessError(description='Invalid u_id')

def user_setname_fn(token, first_name, last_name, users):
    if len(str(first_name)) > 50 or not first_name \
        or len(str(last_name)) > 50 or not last_name:
        raise InputError(description='First or Last Name not between 1 and 50 characters')

    if not first_name.strip() or not last_name.strip():
        raise InputError(description='First or Last Name can not be all spaces')

    for user in users:
        if user['token'] == token:
            user['name_first'] = first_name
            user['name_last'] = last_name
            break
    else:
        raise AccessError(description='Invalid Token')

def user_setemail_fn(token, email, users):
    for user in users:
        if user['email'] == email:
            raise InputError(description='Email already in use')

    regex = r'^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$'
    if not re.search(regex, email):
        raise InputError('Invalid email')

    for user in users:
        if user['token'] == token:
            user['email'] = email
            break
    else:
        raise AccessError(description='Invalid Token')

def user_sethandle_fn(token, handle_str, users):
    if len(handle_str) < 2:
        raise InputError(description='Handle was shorter than 2 characters')
    if len(handle_str) > 20:
        raise InputError(description='Handle was longer than 20 characters')

    for user in users:
        if user['handle_str'] == handle_str:
            raise InputError(description='Handle already taken')

    for user in users:
        if user['token'] == token:
            user['handle_str'] = handle_str
            break
    else:
        raise AccessError(description='Invalid Token')

def user_permission_change_fn(token, u_id, permission_id, users):
    for user in users:
        if user['token'] == token:
            if user['permission_id'] != 1:
                raise AccessError(description='Must be an owner to change permission')
            break
    else:
        raise AccessError(description='Invalid Token')

    for user in users:
        if user['u_id'] == u_id:
            user['permission_id'] = permission_id
            return
    raise InputError(description='Invalid u_id')

def user_profile_uploadphoto_fn(token, img_url, x_start, y_start, x_end, y_end, backendurl, users):
    u_id = get_user_from_token(token)
    for user in users:
        if user['token'] == token:
            process_img(img_url, x_start, y_start, x_end, y_end, u_id)
            user['profile_img_url'] = "http://" + backendurl + f"/static/avatar{u_id}.jpg"
    response = requests.get(img_url)
    if response.status_code != 200:
        raise AccessError(description='img_url returns an HTTP status other than 200.')
    return {}

def user_remove_fn(token, u_id, users, channels, messages):

    #Checking that the user to be removed is valid
    u_raise = 0
    for user in users:
        if user['u_id'] == u_id and user['permission_id'] != -1:
            u_raise = 1
    if u_raise == 0:
        raise InputError(description='Cannot remove invalid user')

    #Checking that the token is from a user who is Slackr owner
    index = position_in_user_data(token, users)
    if users[index]['permission_id'] != 1:
        raise AccessError(description='Permission Denied')

    #Checking that the token and u_id are not of the same person
    if users[index]['token'] == token and users[index]['u_id'] == u_id:
        raise AccessError(description='Please dont remove yourself')

    #Removing all their reactions
    for message in messages:
        if u_id in message['reacts'][0]['u_ids']:
            message['reacts'][0]['u_ids'].remove(u_id)

    for channel in channels:
        if u_id in channel['users']:
            channel['users'].remove(u_id)
        if u_id in channel['owners']:
            channel['owners'].remove(u_id)

    for user in users:
        if user['u_id'] == u_id:

            user['token'] = None
            user['permission_id'] = -1
            user['email'] = None
            user['password'] = None
            user['name_last'] = user['name_last'] + ' [REMOVED]'

    return dumps({})
