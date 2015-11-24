#!/bin/bash

# Public IP that will be Nat'ed thru to the swarm master
export EXTIP=5.198.141.210
# Network for the swarm cluster - this will be created
# (Note dependency on use of '192.168' in sed below)
export NETWORK=cpd.eduserv.org.uk_SDC1Z01-CUST
#export NETWORK=swarm-net
#export NETMASK=255.255.255.0
export DNS=8.8.8.8
export GATEWAY=192.168.3.1
#export GATEWAY=192.168.4.1
#export POOL=192.168.4.2-192.168.4.100
# vCloud Direct host and login credentials (username:password)
export VCDHOST=compute.cloud.eduserv.org.uk
export VCDLOGIN=andy.powell@eduserv.org.uk:Vbike43G
# vCloud Org and vDC
export ORG=cpd.eduserv.org.uk
export VDC=cpd.eduserv.org.uk_SDC_A01
# vApp name and hostname forthe swarm master
export MASTERVAPPNAME=coreos-swarm-master
export MASTERVMNAME=master
# Username, public key file, RAM and CPU for all swarm nodes
export USERNAME=core
export PUBKEYFILE=coreos-key.pub
export RAM=4096
export CPU=2
# Naming prefixes for the swarm node vApps and VMs
# For a prefix of 'node', nodes will be named node1, node2, node3
export NODEVAPPPREFIX=coreos-swarm-node
export NODEVMPREFIX=node
# vCloud catalog name (for the CoreOS template and uploaded cloud-config ISOs)
# These should already exist
export CATALOG=cpd.eduserv.org.uk
export TEMPLATE=CoreOS
