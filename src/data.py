#File for data storage of all global variables

#Authentication
SECRET = 'break'
REGEX = r'^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$'
FIRST_USER = True

PORT = 1645
ADMINS = []
USERS = []
STANDUP = []
CHANNEL = []
MESSAGES = []
MESSAGE_COUNTER = 0

#Global data for channel section
channel_list = []
channel_count = 0

def get_data():
    '''Gets user data.'''
    global USERS
    return USERS

def get_admins():
    '''Gets admins.'''
    global ADMINS
    return ADMINS

def get_standup():
    '''Gets standup messages.'''
    global STANDUP
    return STANDUP

def get_first_user():
    '''Gets first_user.'''
    global FIRST_USER
    return FIRST_USER

def get_secret():
    '''Gets secret.'''
    global SECRET
    return SECRET

def get_regex():
    '''Gets regex.'''
    global REGEX
    return REGEX

def get_global_messages():
    global MESSAGES
    return MESSAGES

def get_global_message_counter():
    global MESSAGE_COUNTER
    return MESSAGE_COUNTER

def get_global_channel():
    global CHANNEL
    return CHANNEL

def get_global_users():
    global USERS
    return USERS
