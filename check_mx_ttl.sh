
#!/bin/bash

#Single purpose script to be used when changing MX TTL.
#Not super usefull :)

if [ $# -lt 2 ]
then
        echo "Run command like so: check_ttl.sh file_with_list_of_domains ns"
        exit 1
fi

#Run from command like a so:
#check_ttl.sh file_with_list_of_domains name_server

list_file=$1
name_server=$2

for f in `cat $list_file`;
  do  
	echo "Checking $f's MX TTL..."
	dig soa $f @$name_server | grep SOA | grep -v ';'
	dig mx $f @$name_server | grep MX | awk {' print "MX " $6 "TTL = " $2 '} 
  done 
  

