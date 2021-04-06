from json import dumps
#from flask_mail import Mail, Message
from flask_cors import CORS
from flask import Flask, request, jsonify
from werkzeug.exceptions import HTTPException
'''
def defaultHandler(err):
    response = err.get_response()
    response.data = dumps({
        "code": err.code,
        "name": "System Error",
        "message": err.get_description(),
    })
    response.content_type = 'application/json'
    return response

APP = Flask(__name__)
APP.config['TRAP_HTTP_EXCEPTIONS'] = True
APP.register_error_handler(Exception, defaultHandler)
CORS(APP)
'''
class InputError(HTTPException):
    code = 400
    message = 'No message specified'
    
class AccessError(HTTPException):
    code = 401
    message = 'No message specified'