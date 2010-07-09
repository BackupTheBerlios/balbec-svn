#!/usr/bin/python
# -*- coding: utf-8 -*-

from StringIO import StringIO
from lxml import etree
from balbec.xmlhandler import XmlHandler

class HtmlHandler(XmlHandler):

    def __init__(self, documentRoot):

        self.documentRoot = documentRoot

    def html(self):

        xml = self.xml()

        stylesheetFile = open(self.documentRoot+'/xslt/html.xsl', 'r')
        stylesheetDoc = etree.parse(stylesheetFile)
        stylesheet = etree.XSLT(stylesheetDoc)
        
        stringIO = StringIO(xml)
        doc = etree.parse(stringIO)
        result = stylesheet(doc)

        return str(result)
