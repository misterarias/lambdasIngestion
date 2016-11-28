from flask import Flask, render_template, request, jsonify # ,redirect, url_for ,jsonify ,flash, session


app = Flask(__name__)
redisConnection = None

@app.route('/RequestEvents', strict_slashes=False, methods=['POST'])
def index():
    params = request.json
    try:
        app = params['eventType']
        return render_template('{}/tests/event.json'.format(app))
    except Exception as e:
        response = jsonify({'status': 'error', 'message': "Unexpected error: {}".format(e.message)})
        response.status_code = 503
        return response

@app.route('/api/v1/<resource>', strict_slashes=False, methods=['POST'])
def api(resource):
    params = request.json
    try:
        return render_template('api/{}/response.json'.format(resource))
    except Exception as e:
        response = jsonify({'status': 'error', 'message': "You are banned forever for '%s'" % resource})
        response.status_code = 403
        return response

if __name__ == '__main__':
    app.run(debug=True, threaded=True, host='0.0.0.0', port=80)
