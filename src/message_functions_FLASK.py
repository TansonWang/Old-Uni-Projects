from json import dumps
from flask import Flask, request
from server import APP
from message_functions_fn import message_send_fn,      \
                                 message_sendlater_fn, \
                                 message_react_fn,     \
                                 message_unreact_fn,   \
                                 message_pin_fn,       \
                                 message_unpin_fn,     \
                                 message_remove_fn,    \
                                 message_edit_fn,      \
                                 search_fn

@APP.route("/message/send", methods=['POST'])
def message_send():

    token = request.form.get('token')
    channel_id = int(request.form.get('channel_id'))
    message = str(request.form.get('message'))

    return dumps(message_edit_fn(token, channel_id, message))

@APP.route("/message/sendlater", methods=['POST'])
def message_sendlater():

    token = request.form.get('token')
    channel_id = int(request.form.get('channel_id'))
    message = str(request.form.get('message'))
    time_sent = request.form.get('time_sent')

    return dumps(message_send_later_fn(token, channel_id, message, time_sent))


@APP.route("/message/react", methods=['POST']) 
def message_react():

    token = request.form.get('token')
    message_id = str(request.form.get('message_id'))
    react_id = int(request.form.get("react_id"))

    message_react_fn(token, message_id, react_id)

    return dumps({})

@APP.route("/message/unreact", methods=['POST'])
def message_unreact():

    token = request.form.get('token')
    message_id = int(request.form.get('message_id'))
    react_id = int(request.form.get("react_id"))

    message_unreact_fn(token, message_id, react_id)

    return dumps({})

@APP.route("/message/pin", methods=['POST'])
def message_pin():

    token = request.form.get('token')
    message_id = int(request.form.get('message_id'))

    message_pin_fn(token, message_id)

    return dumps({})

@APP.route("/message/unpin", methods=['POST'])
def message_unpin():

    token = request.form.get('token')
    message_id = int(request.form.get('message_id'))

    message_unpin_fn(token, message_id)

    return dumps({})

@APP.route("/message/remove", methods=['DELETE'])
def message_remove():

    token = request.form.get('token')
    message_id = int(request.form.get('message_id'))

    message_remove_fn(token, message_id)

    return dumps({})

@APP.route("/message/edit", methods=['PUT'])
def message_edit():

    token = request.form.get('token')
    message_id = int(request.form.get('message_id'))
    message = str(request.form.get('message'))

    message_edit_fn(token, message_id, message)

    return dumps({})

@APP.route("/search", methods=['GET'])
def search():

    token = request.args.get('token')
    query_str = str(request.args.get('query_str'))

    return dumps(search_fn(token, query_str))