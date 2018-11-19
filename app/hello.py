#!/usr/bin/python
import redis
import subprocess,os
from BaseHTTPServer import BaseHTTPRequestHandler,HTTPServer

REDIS_HOST = os.environ.get('REDIS_HOST', 'localhost')
REDIS_PORT = os.environ.get('REDIS_PORT', 6379)
SERVICE_NAME = os.environ.get('SERVICE_NAME', "I_have_no_name")
PORT_NUMBER = os.environ.get('SERVICE_PORT', 8080)
redis_client = redis.Redis(host=REDIS_HOST, port=REDIS_PORT, db=0)

class Handler(BaseHTTPRequestHandler):

  #Handler for the GET requests
  def do_GET(self):
    counter = redis_client.get(SERVICE_NAME) or 0

    counter = int(counter) + 1
    redis_client.set(SERVICE_NAME, counter)
    self.send_response(200)
    self.send_header('Content-type','text/html')
    self.end_headers()
    # Send the html message
    self.wfile.write("\n")
    self.wfile.write("Service: " + SERVICE_NAME + " " + str(counter))
    return

try:
  #Create a web server and define the handler
  web_server = HTTPServer(('', PORT_NUMBER), Handler)
  print('Starting httpserver on port ' , PORT_NUMBER)

  #Wait forever for incoming http requests
  web_server.serve_forever()

except KeyboardInterrupt:
  print('^C received, shutting down the web server')
  web_server.socket.close()
