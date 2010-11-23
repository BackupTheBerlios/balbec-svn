#!/usr/bin/python
# -*- coding: utf-8 -*-

from balbec.xmlhandler import XmlHandler
from balbec.htmlhandler import HtmlHandler

import SimpleHTTPServer
import SocketServer
import os
import sys
import socket

PORT = 8100
CWD = os.getcwd()

class BalbecServer(SimpleHTTPServer.SimpleHTTPRequestHandler):

    def do_GET(self):
    
        accept = self.headers.getheader('Accept')

        try:
    
            if accept.find('text/html') != -1:
    
                handler = HtmlHandler(CWD)
                output = handler.html()
    
                self.send_response(200)
                self.send_header('Content-type', 'text/html')
                self.end_headers()
                self.wfile.write(output)
            else:
    
                handler = XmlHandler(CWD)
                output = handler.xml()  
    
                self.send_response(200)
                self.send_header('Content-type', 'text/xml')
                self.end_headers()
                self.wfile.write(output)
        except Exception, e:
            
            send_response(503, 'Service Unavailable')

Handler = BalbecServer

try:

    httpd = SocketServer.TCPServer(("", PORT), Handler)
    httpd.serve_forever()
except socket.error, e:

    print "Error:", e[1]
    sys.exit(1)
