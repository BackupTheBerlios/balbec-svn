import re
from datetime import datetime
from balbec.objects import Host, Hostgroup, Result, Service

# file parsing code inspired by matt joyce's nagiocity (http://code.google.com/p/nagiosity).

class FileHandler:

    def __init__(self, objectFilename, statusFilename):

        self.objectFilename = objectFilename
        self.statusFilename = statusFilename

    def getDirective(self, item, directive):

        pat = re.compile(' '+ directive + '[\s= ]*([\S, ]*)\n')
        m = pat.search(item)
        if m:

            return m.group(1)

    def getCurrentDateTime(self):

        return datetime.now()

    def getLastCheck(self):

        # read file content

        try:

            file = open(self.statusFilename)
            content = file.read().replace("\t"," ")
            file.close()
        except IOError, e:

            raise Exception("Couldn't fetch status information from file: "+str(e.args[1]))

        # get last check time

        regexp = 'programstatus'+' \{([\S\s]*?)\}'
        pat = re.compile(regexp, re.DOTALL)
        definitions = pat.findall(content)

        try:

            lastCheck = float(self.getDirective(definitions[0],"last_command_check").strip())
        except IndexError:

            raise Exception('No programstatus block found status file.')

        return datetime.fromtimestamp(lastCheck)        

    def getHostgroups(self, names):

        try:

            file = open(self.objectFilename)
            content = file.read().replace("\t"," ")
            file.close()
        except IOError, e:

            raise Exception("Couldn't fetch object information from file: "+str(e.args[1]))

        regexp = 'define hostgroup'+' \{([\S\s]*?)\}'
        pat = re.compile(regexp,re.DOTALL)
        definitions = pat.findall(content)

        idHostgroupMap = {}

        for definition in definitions:

            name = self.getDirective(definition, 'hostgroup_name').strip()
            if name in names:

                idHostgroupMap[name] = Hostgroup(name)

                memberString = self.getDirective(definition, 'members').strip()
                members = memberString.split(',')
                for member in members:

                    idHostgroupMap[name].addHostObjectId(member)

        return idHostgroupMap.values()

    def getHosts(self, hostgroup = None):

        # read file content

        try:

            file = open(self.statusFilename)
            content = file.read().replace("\t"," ")
            file.close()
        except IOError, e:

            raise Exception("Couldn't fetch status information from file: "+str(e.args[1]))

        # get hosts

        hosts = {}
        regexp = 'hoststatus'+' \{([\S\s]*?)\}'
        pat = re.compile(regexp,re.DOTALL)
        definitions = pat.findall(content)

        for definition in definitions:

            hostname = self.getDirective(definition,"host_name").strip()

            if hostgroup == None or hostname in hostgroup.hostObjectIds:

                status = int(self.getDirective(definition,"current_state").strip())
                output = self.getDirective(definition,"plugin_output").strip()
                host = Host(hostname)
                host.setResult(Result(status, output))
                hosts[hostname] = host

        # get services

        services = {}
        regexp = 'servicestatus'+' \{([\S\s]*?)\}'
        pat = re.compile(regexp, re.DOTALL)
        definitions = pat.findall(content)

        for definition in definitions:

            hostname = self.getDirective(definition,"host_name").strip()

            if hostgroup == None or hostname in hostgroup.hostObjectIds:

                description = self.getDirective(definition,"service_description").strip()
                status = int(self.getDirective(definition,"current_state").strip())
                output = self.getDirective(definition,"plugin_output").strip()
                host = Host(hostname)

                service = Service(description)
                service.setResult(Result(status, output))
                hosts[hostname].addService(service)

        return hosts.values();
