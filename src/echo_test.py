import json
import urllib.request
from urllib.error import HTTPError
import pytest
from .data import PORT
BASE_URL = "http://127.0.0.1:" + str(PORT)

def test_echo_success():
    response = urllib.request.urlopen(BASE_URL + '/echo?data=hi')
    payload = json.load(response)
    assert payload['data'] == 'hi'

def test_echo_failure():
    with pytest.raises(HTTPError):
        response = urllib.request.urlopen(BASE_URL + '/echo?data=echo')
