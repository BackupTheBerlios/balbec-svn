#!/usr/bin/python
# -*- coding: utf-8 -*-

from balbec.xmlhandler import XmlHandler
from balbec.htmlhandler import HtmlHandler

import SimpleHTTPServer
import SocketServer
import os
import sys
import signal
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
            
            print e
            self.send_response(503, 'Service Unavailable')

handler = BalbecServer

#handler = XmlHandler(CWD)
#output = handler.xml() 

try:

    httpd = SocketServer.TCPServer(("", PORT), handler)
    
    def signal_handler(signal, frame):

        httpd.socket.close()
        print "Balbec http server stopped."
        sys.exit(0)

    signal.signal(signal.SIGTERM, signal_handler)
    signal.signal(signal.SIGINT, signal_handler)
    
    httpd.serve_forever()
except socket.error, e:

    print "Error:", e[1]
    sys.exit(1)

