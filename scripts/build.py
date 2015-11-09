#!/usr/bin/python
import yaml
import subprocess
import argparse
from pprint import pprint

CONTAINER_DIR='/root/Dockerfiles/contrail/'

parser = argparse.ArgumentParser(description='')
parser.add_argument('-b','--base',
                   action='store_true')
parser.add_argument('-s','--sub',
                   action='store_true')
parser.add_argument('-c','--container',
                   help='')
args = parser.parse_args()

f = open('structure.yaml','r')
configFile = f.read().strip()
configYaml = yaml.load(configFile)

def buildsub():
    for basecontainer in configYaml['containers'].keys():
        if configYaml['containers'][basecontainer]:
            for subcontainer in configYaml['containers'][basecontainer]:
                subcon = basecontainer+'-'+subcontainer
                print subcon
                print 'cd ' + CONTAINER_DIR + subcon + ' && docker build -t localhost:5100/' + subcon + ':' + configYaml['version'] + ' .  && docker push localhost:5100/' + subcon + ':' + configYaml['version']
                subprocess.call('cd ' + CONTAINER_DIR + subcon + ' && docker build -t localhost:5100/' + subcon + ':' + configYaml['version'] + ' .  && docker push localhost:5100/' + subcon + ':' + configYaml['version'], shell=True)

def buildbase():
    for basecontainer in configYaml['containers'].keys():
        print basecontainer
        subprocess.call('cd ' + CONTAINER_DIR + basecontainer + ' && docker build -t localhost:5100/' + basecontainer + ':' + configYaml['version'] + ' . && docker push localhost:5100/' + basecontainer + ':' + configYaml['version'], shell=True)

def buildcon():
    print 'cd ' + CONTAINER_DIR + args.container + ' && docker build -t localhost:5100/' + args.container + ':' + configYaml['version'] + ' . && docker push localhost:5100/' + args.container + ':' + configYaml['version']
    subprocess.call('cd ' + CONTAINER_DIR + args.container + ' && docker build -t localhost:5100/' + args.container + ':' + configYaml['version'] + ' . && docker push localhost:5100/' + args.container + ':' + configYaml['version'], shell=True)


if args.base == True:
    buildbase()
if args.sub == True:
    buildsub()
if args.container:
    buildcon()
