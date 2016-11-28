from __future__ import print_function

import json
import redis
import requests
import urllib3

urllib3.disable_warnings()

# will depend on stage var
redis_host = {
        'local' : '127.0.0.1',
        'pre': '172.31.20.176',
        'prod': '192.168.1.253'
        }

clousr_backend = {
        'local' : 'http://127.0.0.1:8080', # grails app / mock-server
        'pre': 'https://172.31.28.136',
        'prod': 'https://192.168.1.198'
        }

# Default config
config = {
        'status': 1,       # 1->on , 0->off
        'interval': 120,   # seconds
        'debug' :0,        # 1->on, 0->off
        'api_version': '1.0.0',
        'sdk_version': '12.5.2',
        }

def get_mandatory_params(event):
    if not 'appToken' in event['body'].keys():
        raise Exception('Missing mandatory parameter: appToken')
    app_token = event['body']['appToken']

    if not 'deviceId' in event['body'].keys():
        raise Exception('Missing mandatory parameter: deviceId')
    device_id = event['body']['deviceId']

    return (app_token, device_id)

def validate_token(app_token_data):
    if len(app_token_data) != 0:
        return str(app_token_data['active'].decode('utf8')) == 'true'
    return False

def cache_clousr_id_to_redis(app_token, device_id, clousr_id, redis_connection):
    redis_connection.set("{}{}".format(app_token, device_id), clousr_id)

def get_cached_clousr_id_from_redis(app_token, device_id, redis_connection):
    cache_hit = redis_connection.get("{}{}".format(app_token, device_id))
    if cache_hit:
        return cache_hit.decode('utf8')
    return None

def register_id_in_clousr(app_token, device_id, backend_url):
    payload = json.dumps({
      "deviceId"    : device_id,
      "appToken"    : app_token
      })

    api_endpoint_url = "{}/api/v1/register".format(backend_url)
    headers = { 'Content-Type': 'application/json', }
    r = requests.post(api_endpoint_url, data=payload, headers=headers, verify=False)
    try:
        return r.json()
    except Exception as e:
        return error_response("Backend is not available right now: {}".format(e))

def error_response(message):
    return {"status": "error", "message": message}

def handler(event, context):

    # We NEED a redis connection
    environment = 'pre'
    if 'stage' in event['context'].keys():
        environment = event['context']['stage']
    redis_connection = redis.StrictRedis(host=redis_host[environment])
    if not redis_connection:
        return error_response("Cannot connect to cache backend")


    # First, check if this app_token is valid
    try:
        app_token, device_id = get_mandatory_params(event)
        app_token_data = redis_connection.hgetall(app_token)
        if not validate_token(app_token_data):
            return error_response('Invalid app_token')
    except Exception as e:
        return error_response("FATAL: {}".format(e))


    # After that, check if there already exists a clousr ID for this device, register it if not
    clousr_id = get_cached_clousr_id_from_redis(app_token, device_id, redis_connection)
    if not clousr_id:
        register_response = register_id_in_clousr(app_token, device_id, clousr_backend[environment])
        if register_response['status'] == "error":
            return error_response(register_response['message'])

        clousr_id = register_response['clousr_id']
        if clousr_id == "":
            return error_response("Invalid ID received from backend") # Not quite sure what to do here
        cache_clousr_id_to_redis(app_token, device_id, clousr_id, redis_connection)

    # Then, Complete the config object
    for k in ['status', 'interval', 'debug']:
        if k in app_token_data:
            config[k] = str(app_token_data[k].decode('utf8'))
        else:
            redis_connection.hset(app_token, k, config[k])
    return {
            "status": "ok",
            "clousr_id": clousr_id,
            "config": config
            }
