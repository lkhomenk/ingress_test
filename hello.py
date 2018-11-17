#!/usr/bin/python
import subprocess,os
from BaseHTTPServer import BaseHTTPRequestHandler,HTTPServer

PORT_NUMBER = 8080

class Handler(BaseHTTPRequestHandler):

  #Handler for the GET requests
  def do_GET(self):
    self.send_response(200)
    self.send_header('Content-type','text/html')
    self.end_headers()
    # Send the html message
    self.wfile.write("\n")
    self.wfile.write("Hostname is : " + subprocess.check_output("uname -n", shell=True))
    self.wfile.write("\n")
    return

try:
  #Create a web server and define the handler
  web_server = HTTPServer(('', PORT_NUMBER), Handler)
  print 'Starting httpserver on port ' , PORT_NUMBER

  #Wait forever for incoming http requests
  web_server.serve_forever()

except KeyboardInterrupt:
  print '^C received, shutting down the web server'
  server.socket.close()
