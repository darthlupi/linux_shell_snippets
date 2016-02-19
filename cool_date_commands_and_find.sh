#!/bin/bash


# Task:  Remove files from $directory leaving the last 15 days intact for host esu4v036
# Author: Robert Lupinek - 2/5/2015

#Set the target directory
directory="/apps/scope/mst/print/output"

#Get epoch times
from_date=`date --date="Sep 2 09:00:00 BST 2014" +%s`
to_date=`date +%s`
#Convert difference to days or days between the two dates
days=$(((to_date-from_date)/86400))
days_to_remain=15

echo "We are going to start deleting $days back."
echo "We will leave $days_to_remain intact."

#Start looping through the days running the find command for each
for ((d=$days; d>=$days_to_remain; d--))
do
        echo "Working on $d days out at " `date`
		#Change +$d to $d to find files that are exactly that many days old vs that many days old and older.
        find $directory -mtime +$d -exec ls -la {} \;
        echo "Finished $d days out at " `date`
        sleep 5
done



#Output of script


	mv /apps/scope/mst/print/output /apps/scope/mst/print/output.old
	mkdir /apps/scope/mst/print/output
	rm -rf /apps/scope/mst/print/output.old
	
