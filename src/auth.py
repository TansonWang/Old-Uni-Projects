from json import dumps
import re
import random
import hashlib
import smtplib
import ssl
import jwt
import data as da
from error import InputError, AccessError

#auth_register to register new users
def auth_register(email, password, name_first, name_last, users):
    if email_is_valid(email):
        for user in users:
            if user['email'] == email:
                raise InputError(description="Email Already Taken")

        if len(name_first) > 50 or not name_first or \
            len(name_last) > 50 or not name_last:
            raise InputError(description='First or Last Name not between 1 and 50 characters')

        if not name_first.strip() or not name_last.strip():
            raise InputError(description='First or Last Name can not be all spaces')

        if len(password) < 6:
            raise InputError(description='Password less then 6 characters long')

        handle_str = name_first + name_last
        u_id = len(users)

        for user in users:
            if user['handle_str'] == handle_str:
                handle_len = len(handle_str) + len(str(u_id))
                if handle_len > 20:
                    handle_str = handle_str[0:(20-len(str(u_id)))] + str(u_id)
                else:
                    handle_str = handle_str + str(u_id)

        newtok = generate_token(u_id)

        users.append({
            'email': email,
            'password': hashPassword(password),
            'name_first': name_first,
            'name_last': name_last,
            'handle_str': handle_str,
            'u_id': len(users),
            'token': newtok,
            'permission_id': 0,
            'reset_code': None,
            'profile_img_url': None
        })
        if len(users) == 1:
            users[0]['permission_id'] = 1

        return dumps({
            'token': newtok,
            'u_id': u_id
        })

    raise InputError(description='Email invalid')

def auth_login(email, password, users):
    print("\n" + email + '\n' + password + '\n')
    for user in users:
        if (user['email'] == email and user['password'] == hashPassword(password)):
            u_id = user['u_id']
            user['token'] = generate_token(u_id)

            return dumps({
                'token': generate_token(u_id),
                'u_id': u_id
            })
    raise InputError(description='invalid login details')

def auth_logout(token, users):
    for user in users:
        if user['token'] == token:
            user['token'] = None
            print('\nDeleted token\n')
            return dumps({'is_success': True})

    print('\nFailed to delete token\n')
    return dumps({'is_success': False})

def auth_request_reset_fn(email, users):
    for user in users:
        if user['email'] == email:
            first_name = user['name_first']
            code = user['u_id'] + 10000 + 1000 * ord(user['name_last'][0])\
                + random.randint(9999, 89999)
            user['reset_code'] = code
            break
    else:
        return

    port = 465  # For SSL
    smtp_server = "smtp.gmail.com"
    sender_email = "comp1531testingground@gmail.com"  # A gmail I made for this
    receiver_email = email
    password = '1531TestingGrounds' # Oh no, you know the password now
    message = """\
    Subject: COMP1531 Group: I need a break Password Reset Request

    Hey, {name}
    Your code is {code}.""".format(name=first_name, code=code)

    context = ssl.create_default_context()
    with smtplib.SMTP_SSL(smtp_server, port, context=context) as server:
        server.login(sender_email, password)
        server.sendmail(sender_email, receiver_email, message)
    return

def auth_reset_password_fn(reset_code, password, users):
    print(reset_code)
    reset_code = int(reset_code)
    if len(password) < 6:
        raise InputError(description="Password less then 6 characters long")

    print('\n' + password + '\n')
    print(users)
    for user in users:
        print('\n Within search loop\n\n')
        if user['reset_code'] == reset_code:
            print('desu')
            user['reset_code'] = None
            user['password'] = hashPassword(password)
            return

    raise InputError(description=("Reset Code is Invalid"))

##### HELPER FUNCTIONS ######
#generating token
def generate_token(u_id):
    token = jwt.encode({'u_id': u_id}, da.SECRET, algorithm='HS256').decode('UTF-8')
    #print(token)
    #return u_id
    return str(token)

#getting u_id associated to the token
def get_user_from_token(token):
    decoded_u_id = jwt.decode(token, da.SECRET, algorithms='HS256')
    return decoded_u_id['u_id']

#hashing the password
def hashPassword(password):
    return hashlib.sha256(password.encode()).hexdigest()

#checks if the email supplied is valid
def email_is_valid(email):
    regex = r'^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$'
    return re.search(regex, email)

#checking for a valid token
def valid_is_token(token, users):
    for user in users:
        if user['token'] == token:
            return True
    raise AccessError('Token not Valid, token_is_valid function')
