#!/usr/bin/python
import yaml
import subprocess
import argparse
import sys
from pprint import pprint


parser = argparse.ArgumentParser(description='')
parser.add_argument('-b','--base',
                   action='store_true',help='switch to build all base images')
parser.add_argument('-s','--sub',
                   action='store_true',help='switch to build all sub images')
parser.add_argument('-c','--container',
                   help='specifies a container as listed in file')
parser.add_argument('-t','--containerType',
                   help='container type (openstack/contrail/common)')
parser.add_argument('-x','--serviceType',
                   help='version')
parser.add_argument('-v','--version',
                   help='version')
parser.add_argument('file',
                   help='yaml file containing the container structure')
args = parser.parse_args()
args = parser.parse_args()

f = open(args.file,'r')
configFile = f.read().strip()
configYaml = yaml.load(configFile)
containerDir = configYaml['containerpath'] + '/'
openstackContainerDir = containerDir + '/openstack/' + configYaml['openstackversion']
contrailContainerDir = containerDir + '/contrail/' + str(configYaml['contrailversion']) + '/' + str(configYaml['contrailbuild'])
commonContainerDir = containerDir + '/common/' + str(configYaml['commonversion'])
repo = configYaml['repo']

def buildbase(containerType, buildDir, version):
    for basecontainer in configYaml['containers'][containerType]:
        subprocess.call('cd ' + buildDir + '/' + basecontainer + ' && docker build -t ' + repo + '/' + basecontainer + ':' + version + ' --no-cache .', shell=True)
        #subprocess.call('cd ' + buildDir + '/' + basecontainer + ' && docker build -t ' + repo + '/' + basecontainer + ':' + version + ' --no-cache . && docker push ' + repo + '/' + basecontainer + ':' + version, shell=True)
        #subprocess.call('docker pull ' + repo + '/' + basecontainer + ':' + version, shell=True)

def buildcon(containerType, buildDir, version):
    subprocess.call('cd ' + buildDir + '/' + args.container + ' && docker build -t ' + repo + '/' + args.container + ':' + version + ' --no-cache .' , shell=True)
    #subprocess.call('cd ' + buildDir + '/' + args.container + ' && docker build -t ' + repo + '/' + args.container + ':' + version + ' --no-cache . && docker push ' + repo + '/' + args.container + ':' + version, shell=True)
    #subprocess.call('docker pull ' + repo + '/' + args.container + ':' + version, shell=True)
        
def buildsub(containerType, buildDir, version):
    for basecontainer in configYaml['containers'][containerType].keys():
        if configYaml['containers'][containerType][basecontainer]:
            for subcontainer in configYaml['containers'][containerType][basecontainer]:
                subcon = basecontainer  + '-' + subcontainer
                subprocess.call('cd ' + buildDir + '/' + subcon + ' && docker build -t ' + repo + '/' + subcon + ':' + version + ' --no-cache .', shell=True)
                #subprocess.call('cd ' + buildDir + '/' + subcon + ' && docker build -t ' + repo + '/' + subcon + ':' + version + ' --no-cache .  && docker push ' + repo + '/' + subcon + ':' + version, shell=True)
                #subprocess.call('docker pull ' + repo + '/' + subcon + ':' + version, shell=True)
             
def buildservice(containerType, serviceType, buildDir, version):
    print 'cd ' + buildDir + '/' + serviceType
    subprocess.call('cd ' + buildDir + '/' + serviceType + ' && docker build -t ' + repo + '/' + serviceType + ':' + version + ' --no-cache . && docker push ' + repo + '/' + serviceType + ':' + version, shell=True)
    for servicecontainer in configYaml['containers'][containerType][serviceType]:
        print 'cd ' + buildDir + '/' + servicecontainer
        subprocess.call('cd ' + buildDir + '/' + serviceType + '-' + servicecontainer + ' && docker build -t ' + repo + '/' + servicecontainer + ':' + version + ' --no-cache . && docker push ' + repo + '/' + servicecontainer + ':' + version, shell=True)
        subprocess.call('docker pull ' + repo + '/' + servicecontainer + ':' + version)

if args.containerType == 'openstack':
    buildDir = openstackContainerDir
    version = configYaml['openstackversion']
if args.containerType == 'contrail':
    buildDir = contrailContainerDir
    version = str(configYaml['contrailversion']) + '-' + str(configYaml['contrailbuild'])
if args.containerType == 'common':
    buildDir = commonContainerDir
    version = str(configYaml['commonversion'])

if args.base == True:
    buildbase(args.containerType, buildDir, version)
if args.sub == True:
    buildsub(args.containerType, buildDir, version)
if args.container:
    buildcon(args.containerType, buildDir, version)
if args.serviceType:
    buildservice(args.containerType, args.serviceType, buildDir, version)

