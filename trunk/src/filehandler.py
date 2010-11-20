import re
from datetime import datetime
from balbec.objects import Host, Hostgroup, Result, Service

# file parsing code inspired by matt joyce's nagiocity (http://code.google.com/p/nagiosity).

class FileHandler:

    directive_counter = 0
    host_counter = 0
    hostgroup_counter = 0
	
    def __init__(self, objectFilename, statusFilename):

        # read file contents

        try:

            file = open(statusFilename)
            self.statusContent = file.read().replace("\t"," ")
            file.close()
        except IOError, e:

            raise Exception("Couldn't fetch status information from file: "+str(
e.args[1]))

        try:

            file = open(objectFilename)
            self.objectContent = file.read().replace("\t"," ")
            file.close()
        except IOError, e:

            raise Exception("Couldn't fetch object information from file: "+str(e.args[1]))

    def getCurrentDateTime(self):

        return datetime.now()

    def getLastCheck(self):

        # get last check time

        regexp = 'programstatus \{([\S\s]*?last_command_check=(\S+)\n[\S\s]*?)\}'
        pat = re.compile(regexp, re.DOTALL)
        definitions = pat.findall(self.statusContent)

        try:

            deftuple = definitions[0]
            lastCheck = float(deftuple[1])
        except IndexError:

            raise Exception('No programstatus block found status file.')

        return datetime.fromtimestamp(lastCheck)        

    def getHostgroups(self, names):

        #self.hostgroup_counter = self.hostgroup_counter + 1

        regexp = 'define hostgroup \{([\S\s]*?hostgroup_name\s+([\S ]+)\n[\S\s]*?members\s+([\S ]+)\n[\S\s]*?)\}'
        pat = re.compile(regexp,re.DOTALL)
        definitions = pat.findall(self.objectContent)

        idHostgroupMap = {}

        for deftuple in definitions:

            name = deftuple[1]
          
            if name not in names:

                continue

            idHostgroupMap[name] = Hostgroup(name)

            memberString = deftuple[2]
            members = memberString.split(',')
            for member in members:

               idHostgroupMap[name].addHostObjectId(member)

        return idHostgroupMap.values()

    def getHosts(self, hostgroup):

        #self.host_counter = self.host_counter + 1

        regexp = 'hoststatus'+' \{([\S\s]*?host_name=(\S+)\n[\S\s]*?current_state=(\S+)\n[\S\s]*?plugin_output=([\S ]+)\n[\S\s]*?)\}' 

        # get hosts

        hosts = {}
        pat = re.compile(regexp,re.DOTALL)
        definitions = pat.findall(self.statusContent)

        for deftuple in definitions:

            hostname = deftuple[1]
            
            if hostname not in hostgroup.hostObjectIds:

                continue
            definition = deftuple[0]

            status = int(deftuple[2])
            output = deftuple[3]
            #status = int(self.getDirective(definition,"current_state").strip())
            #output = self.getDirective(definition,"plugin_output").strip()
            host = Host(hostname)
            host.setResult(Result(status, output))
            hosts[hostname] = host

        # get services

        regexp = 'servicestatus'+' \{([\S\s]*?host_name=(\S+)\n[\S\s]*?service_description=([\S ]+)\n[\S\s]*?current_state=(\S+)\n[\S\s]*?plugin_output=([\S ]+)\n[\S\s]*?)\}'
        pat = re.compile(regexp, re.DOTALL)
        definitions = pat.findall(self.statusContent)

        for deftuple in definitions:

            hostname = deftuple[1]

            if hostname not in hostgroup.hostObjectIds:

                continue
            definition = deftuple[0]
           
            description = deftuple[2] 
            status = int(deftuple[3])
            output = deftuple[4]
            host = Host(hostname)

            service = Service(description)
            service.setResult(Result(status, output))
            hosts[hostname].addService(service)

        return hosts.values();
