import os
# import flask module
from flask import Flask

# instance of flask application
app = Flask(__name__)

# home route that returns below text
# when root url is accessed
@app.route("/")
def hello_world():
    return "<p>Hello, World!</p>"

if __name__ == '__main__':
  if os.path.isfile("/tmp/tls/tls.key") and os.path.isfile("/tmp/tls/tls.crt") :
    app.run(debug=True, host="0.0.0.0", port=os.environ.get('FLASK_EXAMPLE_1_SERVICE_PORT_TCP'), ssl_context=('/tmp/tls/tls.crt', '/tmp/tls/tls.key'))
  else:
    app.run(debug=True, host="0.0.0.0", port=os.environ.get('FLASK_EXAMPLE_1_SERVICE_PORT_TCP'))