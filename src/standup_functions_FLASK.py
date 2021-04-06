from json import dumps
from flask import Flask, request
from server import APP
from standup import standup_start,standup_active,standup_send


@APP.route("/standup/start",methods = ['POST'])
def start_standup():
    return dumps(standup_start(request.form.get('token'), int(request.form.get('channel_id')), int(request.form.get('length'))))

@APP.route("/standup/active",methods = ['GET'])
def active_standup():
    return dumps(standup_active(request.args.get('token'), int(request.args.get('channel_id'))))

@APP.route("/standup/send",methods = ['POST'])
def send_standup():
    return dumps(standup_send(request.form.get('token'), int(request.form.get('channel_id')), request.form.get('message')))