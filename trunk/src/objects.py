#!/usr/bin/python
# -*- coding: utf-8 -*-

class Filter:

    def __init__(self, name):
    
        self.name = name
        self.revert = False
        self.hostgroups = []

class Map:

    def __init__(self, name):

        self.name = name
        self.expressions = []
        
class HostgroupExpression:

    def __init__(self, name):
    
        self.name = name

class AndExpression:

    def __init__(self, expressions):
    
        self.expressions = expressions

class NotExpression:

    def __init__(self, expressions):

        self.expressions = expressions

class Result:

    def __init__(self, status, output):

        self.status = status
        self.output = output        
        
class Hostgroup:

    def __init__(self, name):

        self.name = name
        self.hostObjectIds = []
        self.hosts = []
    def addHostObjectId(self, id):

        self.hostObjectIds.append(id)

class Host:

    def __init__(self, hostname):

        self.hostname = hostname
        self.result = None
        self.services = []
    def setResult(self, result):

        self.result = result
    def addService(self, service):

        self.services.append(service)

class Service:  

    def __init__(self, servicename):

        self.servicename = servicename
        self.result = None
    def setResult(self, result):

        self.result = result

