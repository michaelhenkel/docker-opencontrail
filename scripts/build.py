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
        subprocess.call('cd ' + buildDir + '/' + basecontainer + ' && docker build -t ' + repo + '/' + basecontainer + ':' + version + ' . && docker push ' + repo + '/' + basecontainer + ':' + version, shell=True)

def buildcon(containerType, buildDir, version):
    subprocess.call('cd ' + buildDir + '/' + args.container + ' && docker build -t ' + repo + '/' + args.container + ':' + version + ' . && docker push ' + repo + '/' + args.container + ':' + version, shell=True)
        
def buildsub(containerType, buildDir, version):
    for basecontainer in configYaml['containers'][containerType].keys():
        if configYaml['containers'][containerType][basecontainer]:
            for subcontainer in configYaml['containers'][containerType][basecontainer]:
                subcon = basecontainer  + '-' + subcontainer
                subprocess.call('cd ' + buildDir + '/' + subcon + ' && docker build -t ' + repo + '/' + subcon + ':' + version + ' .  && docker push ' + repo + '/' + subcon + ':' + version, shell=True)
             
    
#def buildsub():
#    for basecontainer in configYaml['containers'].keys():
#        if configYaml['containers'][basecontainer]:
#            for subcontainer in configYaml['containers'][basecontainer]:
#                subcon = basecontainer+'-'+subcontainer
#                print subcon
#                print 'cd ' + containerDir + subcon + ' && docker build -t ' + repo + '/' + subcon + ':' + configYaml['version'] + ' .  && docker push ' + repo + '/' + subcon + ':' + configYaml['version']
#                subprocess.call('cd ' + containerDir + subcon + ' && docker build -t ' + repo + '/' + subcon + ':' + configYaml['version'] + ' .  && docker push ' + repo + '/' + subcon + ':' + configYaml['version'], shell=True)

#def buildbase():
#    for basecontainer in configYaml['containers'].keys():
#        print basecontainer
#        subprocess.call('cd ' + containerDir + basecontainer + ' && docker build -t ' + repo + '/' + basecontainer + ':' + configYaml['version'] + ' . && docker push ' + repo + '/' + basecontainer + ':' + configYaml['version'], shell=True)

#def buildcon():
#    print 'cd ' + containerDir + args.container + ' && docker build -t ' + repo + '/' + args.container + ':' + configYaml['version'] + ' . && docker push ' + repo + '/' + args.container + ':' + configYaml['version']
#    subprocess.call('cd ' + containerDir + args.container + ' && docker build -t ' + repo + '/' + args.container + ':' + configYaml['version'] + ' . && docker push ' + repo + '/' + args.container + ':' + configYaml['version'], shell=True)

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
