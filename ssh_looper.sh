#!/bin/bash

#Purpose Simple for loop designed to loop through servers via ssh and run a bash script
#Version: 0.1
#Author: Robert Lupinek
#Date Modified by: 2/17/2015 Robert Lupinek
#Usage: ./ssh_looper.sh path_of_server_list path_of_bash_script optional_header_to_echo 

if [ $# -lt 3 ]
then 
  echo "Provide a file with servers listed and a bash script to run as arguments."
  echo "Optionally, you can provide a third argument for a header to print."
  exit 1
fi

if [ ! -f $1 ]
then
  echo "Provide a file to loop through."
  exit 1
fi

#Print header if it exists
echo $3

#Loop through servers in server list
for h in $(cat $1)
do
  ssh -q -oBatchMode=yes -oStrictHostKeyChecking=no -oConnectTimeout=1 -oConnectionAttempts=1 $h 'bash -s' < $2 || echo "$h, unable to authenticate to host using key.  Investigate manually."	
done

