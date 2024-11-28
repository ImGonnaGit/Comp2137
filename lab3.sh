#!/bin/bash

server1="server1-mgmt"
server2="server2-mgmt"
remote_path="/root"
host1_name="loghost"
host2_name="webhost"
host1_ip="192.168.16.3"
host2_ip="192.168.16.4"

verbose=""
if [[ "$1" == "-verbose" ]]; then
  verbose="-verboose"
  echo "Verbose enabled."
fi

#Serv1
scp configure-host.sh remoteadmin@$server1:$remote_path
if [[ $? -ne 0 ]]; then
  echo "Error: Could not copy script to $server1"
  exit 1
fi
ssh remoteadmin@$server1 -- "$remote_path/configure-host.sh -name $host1_name -ip $host1_ip -hostentry $host2_name $host2_ip $verbose"

#Serv2
scp configure-host.sh remoteadmin@$server2:$remote_path
if [[ $? -ne 0 ]]; then
  echo "Error: Could not copy script to $server2"
  exit 1
fi
ssh remoteadmin@$server2 -- "$remote_path/configure-host.sh -name $host2_name -ip $host2_ip -hostentry $host1_name $host1_ip $verbose"

#Update /etc/
echo "Updating local /etc/hosts file..."
./configure-host.sh -hostentry $host1_name $host1_ip $verbose
if [[ $? -ne 0 ]]; then
  echo "Error: Failed to update local hosts file for $host1_name"
  exit 1
fi

./configure-host.sh -hostentry $host2_name $host2_ip $verbose
if [[ $? -ne 0 ]]; then
  echo "Error: Failed to update local hosts file for $host2_name"
  exit 1
fi

echo "Script compleated"
