#!/usr/bin/python
# -*- coding: utf-8 -*-

from lxml import etree
import re
import datetime
from balbec.objects import Map, Hostgroup, Filter, NotExpression, AndExpression, HostgroupExpression

HOST_UP = 0
HOST_DOWN = 1
HOST_UNREACHABLE = 2
HOST_UNREACHABLE_2 = 3

SERVICE_OK = 0
SERVICE_WARNING = 1
SERVICE_CRITICAL = 2
SERVICE_UNKNOWN = 3

hostStatus = {HOST_UP : "Up", HOST_DOWN : "Down", HOST_UNREACHABLE : "Unreachable", HOST_UNREACHABLE_2 : "Unreachable"}
serviceStatus = {SERVICE_OK : "Ok", SERVICE_WARNING : "Warning", SERVICE_CRITICAL : "Critical", SERVICE_UNKNOWN : "Unknown"}

class XmlHandler:

    def __init__(self, documentRoot):

        self.documentRoot = documentRoot

    def readConfig(self):

        maps = []

        schemaFile = open(self.documentRoot+'/schema/config.xsd', 'r')
        schemaDoc = etree.parse(schemaFile)
        schema = etree.XMLSchema(schemaDoc)

        configFile = open(self.documentRoot+'/config.xml', 'r')
        try:
            doc = etree.parse(configFile)
            schema.assertValid(doc)
        except etree.XMLSyntaxError, e:
            
            raise Exception('Invalid Config file: "'+str(e)+'"')
        except etree.DocumentInvalid, e:

            raise Exception('Invalid Config file: "'+str(e)+'"')

        mysqlNodes = doc.xpath("/balbec/nagios/ndo2db")
        if len(mysqlNodes) == 1:

            from balbec.mysqlbackend import MysqlBackend

            mysql = MysqlBackend()

            mysqlNode = doc.xpath("/balbec/nagios/ndo2db")[0]

            databaseNodes = mysqlNode.xpath('database')
            if len(databaseNodes) == 1:

                mysql.database = databaseNodes[0].text
            hostnameNodes = mysqlNode.xpath('hostname')
            if len(hostnameNodes) == 1:

                mysql.hostname = hostnameNodes[0].text
            usernameNodes = mysqlNode.xpath('username')
            if len(usernameNodes) == 1:

                mysql.username = usernameNodes[0].text
            passwordNodes = mysqlNode.xpath('password')
            if len(passwordNodes) == 1 and passwordNodes[0] != None:

                mysql.password = passwordNodes[0].text  
            prefixNodes = mysqlNode.xpath('prefix')
            if len(prefixNodes) == 1 and prefixNodes[0] != None:

                mysql.prefix = prefixNodes[0].text

            mysql.connect()
            backend = mysql
        else:

            from balbec.filebackend import FileBackend

            objectFilename = doc.xpath("/balbec/nagios/files/object_file")[0].text      
            statusFilename = doc.xpath("/balbec/nagios/files/status_file")[0].text     

            backend = FileBackend(objectFilename, statusFilename)

        mapNames = []
        mapNodes = doc.xpath("/balbec/map")
        for mapNode in mapNodes:

            mapName = mapNode.get("name")
            if mapName in mapNames:
            
                raise Exception('Map "'+mapName+'" is defined more than once.')
            else:
            
                mapNames.append(mapName)
            
            map = Map(mapName) 

            hostgroups = []
            
            expressions = self.buildExpression(mapNode)
            #self.printExpressions(expressions)

            map.expressions = expressions
            maps.append(map)
        
        return maps, backend

    def buildExpression(self, node):
    
            expressions = []
    
            hostgroupNodes = node.xpath("hostgroup")
            for hostgroupNode in hostgroupNodes:

                name = hostgroupNode.text
                expressions.append(HostgroupExpression(name))
            andNodes = node.xpath("and")
            for andNode in andNodes:

                andExpressions = self.buildExpression(andNode)
                expressions.append(AndExpression(andExpressions))
            notNodes = node.xpath("not")
            for notNode in notNodes:

                notExpressions = self.buildExpression(notNode)
                expressions.append(NotExpression(notExpressions))    
                
            return expressions

    def printExpressions(self, expressions):
    
        for expression in expressions:
        
            if isinstance(expression, AndExpression):
            
                print '&('
                self.printExpressions(expression.expressions)
                print ')'
            elif isinstance(expression, NotExpression):
            
                print '!('
                self.printExpressions(expression.expressions)
                print ')'
            elif isinstance(expression, HostgroupExpression):
            
                print '|' + expression.name

    def getFilteredObjectIds(self, backend, expressions):
    
        hostgroupNames = []
        andIds = None
        notIds = None
        for expression in expressions:
        
            if isinstance(expression, AndExpression):
            
                andIds = self.getFilteredObjectIds(backend, expression.expressions)
            elif isinstance(expression, NotExpression):
            
                notIds = self.getFilteredObjectIds(backend, expression.expressions)
            elif isinstance(expression, HostgroupExpression):
            
                hostgroupNames.append(expression.name)
        allIds = []
        hostgroups = backend.getHostgroups(hostgroupNames)
        for hostgroup in hostgroups:
        
            allIds = allIds + hostgroup.hostObjectIds
        
        ids = []
        for id in allIds:
        
            if (andIds == None or id in andIds) and (notIds == None or id not in notIds):
            
                ids.append(id)
        return ids
        
    def xml(self):       

        maps, backend = self.readConfig()
        dt = backend.getLastCheck()
        lastCheck = dt.strftime('%s')
        dt = backend.getCurrentDateTime()
        currentTime=dt.strftime('%s')        

        nagiosNode = etree.Element('nagios', currentTime=str(currentTime), lastCheck=str(lastCheck))

        for map in maps:
        
            mapNode = etree.SubElement(nagiosNode, 'map', name = map.name)

            expressions = map.expressions

			# Use the expressions from the config file to compile a list of 
			# valid object ids.
            
            filteredHostObjectIds = self.getFilteredObjectIds(backend, expressions)

			# Get the hostgroups for the map.

            hostgroupNames = []
            for expression in expressions:
            
                if isinstance(expression, HostgroupExpression):
                
                    hostgroupNames.append(expression.name)
            hostgroups = backend.getHostgroups(hostgroupNames)

            for hostgroup in hostgroups:

				# Remove a hostgroup's object ids, when they are not in the
				# valid object id list.

                hostObjectIds = hostgroup.hostObjectIds
                newHostObjectIds = []
                for hostObjectId in hostObjectIds:
                
                    if hostObjectId in filteredHostObjectIds:
                    
                        newHostObjectIds.append(hostObjectId)
                hostgroup.hostObjectIds = newHostObjectIds

				# Skip if the hostgroup has no (valid) object ids.

                if len(hostgroup.hostObjectIds) == 0:

                    continue 
                hostgroup.hosts = backend.getHosts(hostgroup)
                hostgroupNode = etree.SubElement(mapNode, "hostgroup", name=hostgroup.name)

                for host in hostgroup.hosts:

                    hostNode = etree.SubElement(hostgroupNode, "host", name=host.hostname)
                    if host.result:

                        statusText = hostStatus[host.result.status]
                        statusCode = host.result.status
                    else:

                        statusText = serviceStatus[SERVICE_UNKNOWN]
                        statusCode = SERVICE_UNKNOWN

                    statusNode = etree.SubElement(hostNode, "status")
                    codeNode = etree.SubElement(statusNode, "code")
                    codeNode.text = str(statusCode)
                    textNode = etree.SubElement(statusNode, "text")
                    textNode.text = str(statusText)

                    for service in host.services:

                        serviceNode = etree.SubElement(hostNode, "service", name=service.servicename)
                        if service.result:

                            statusText = serviceStatus[service.result.status]
                            statusCode = service.result.status
                        else:

                            statusText = serviceStatus[SERVICE_UNKNOWN]
                            statusCode = SERVICE_UNKNOWN

                        statusNode = etree.SubElement(serviceNode, "status")
                        codeNode = etree.SubElement(statusNode, "code")
                        codeNode.text = str(statusCode)
                        textNode = etree.SubElement(statusNode, "text")
                        textNode.text = str(statusText)
            
        tree = etree.ElementTree(nagiosNode)
        return etree.tostring(tree, encoding='UTF-8', pretty_print=True, xml_declaration=True)
        
      
        
