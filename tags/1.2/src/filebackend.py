import re
from datetime import datetime
from balbec.objects import Host, Hostgroup, Result, Service

# file parsing code inspired by matt joyce's nagiocity (http://code.google.com/p/nagiosity).

class FileBackend:

    directive_counter = 0
    host_counter = 0
    hostgroup_counter = 0
    
    def __init__(self, objectFilename, statusFilename):

        # read file contents

        try:

            file = open(statusFilename)
            statusContent = file.read().replace("\t"," ")
            file.close()
        except IOError, e:

            raise Exception("Couldn't fetch status information from file: "+str(
e.args[1]))

        try:

            file = open(objectFilename)
            objectContent = file.read().replace("\t"," ")
            file.close()
        except IOError, e:

            raise Exception("Couldn't fetch object information from file: "+str(e.args[1]))

        # parse definitions
       
        self.hostgroupDefinitions = self.parseHostgroups(objectContent)
        self.hoststatusDefinitions = self.parseHosts(statusContent)
        self.servicestatusDefinitions = self.parseServicestati(statusContent)
        self.lastCheck = self.parseLastcheck(statusContent)
        
    def getCurrentDateTime(self):

        return datetime.now()

    def parseLastcheck(self, text):

        # get last check time

        pattern = re.compile('programstatus \{[\S\s]*?last_command_check=(\S+)\n[\S\s]*?\}', re.DOTALL)
        match = re.search(pattern, text)        

        try:

            lastCheck = float(match.group(1)) 
        except Exception:

            raise Exception('No programstatus block found status file.')

        return datetime.fromtimestamp(lastCheck)        

    def getLastCheck(self):

        return self.lastCheck;

    def parseHostgroups(self, text):

        pattern = re.compile('define hostgroup \{[\S\s]*?hostgroup_name\s+([\S ]+)\n[\S\s]*?members\s+([\S ]+)\n[\S\s]*?\}', re.DOTALL)

        definitions = []
        for match in pattern.finditer(text):

            name = match.group(1)
            members = match.group(2).split(',')
            definitions.append((name, members))
        return definitions

    def parseHosts(self, text):

        pattern = re.compile('hoststatus'+' \{[\S\s]*?host_name=(\S+)\n[\S\s]*?current_state=(\S+)\n[\S\s]*?plugin_output=([\S ]+)\n[\S\s]*?\}', re.DOTALL) 

        definitions = []
        for match in pattern.finditer(text):

            hostname = match.group(1)
            status = int(match.group(2))
            output = match.group(3)
            definitions.append((hostname, status, output))
        return definitions

    def parseServicestati(self, text):

        pattern = re.compile('servicestatus'+' \{[\S\s]*?host_name=(\S+)\n[\S\s]*?service_description=([\S ]+)\n[\S\s]*?current_state=(\S+)\n[\S\s]*?plugin_output=([\S ]+)\n[\S\s]*?\}', re.DOTALL)

        definitions = []
        for match in pattern.finditer(text):
            
            hostname = match.group(1)          
            description = match.group(2)
            status = int(match.group(3))
            output = match.group(4) 
            
            definitions.append((hostname, description, status, output))
        return definitions

    def getHostgroups(self, names):

        idHostgroupMap = {}
        
        for name, members in self.hostgroupDefinitions:
        
            if name not in names:
 
                continue
            idHostgroupMap[name] = Hostgroup(name)
            for member in members:
            
                idHostgroupMap[name].addHostObjectId(member)
        return idHostgroupMap.values()


    def getHosts(self, hostgroup):

        #self.host_counter = self.host_counter + 1

        hosts = {}

        for hostname, status, output in self.hoststatusDefinitions:         
 
            if hostname not in hostgroup.hostObjectIds:

                continue

            host = Host(hostname)
            host.setResult(Result(status, output))
            hosts[hostname] = host

        for hostname, description, status, output in self.servicestatusDefinitions:

            if hostname not in hostgroup.hostObjectIds:

                continue
            
            host = Host(hostname)

            service = Service(description)
            service.setResult(Result(status, output))
            hosts[hostname].addService(service)

        return hosts.values();
