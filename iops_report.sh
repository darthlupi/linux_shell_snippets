#!/bin/bash
#
#  Description:
#    This script will run iostat -xdN until the user issues
#    the ctrl-c key sequence.  It will then part the log file
#    for the top IOPs usage.
#  Last Modified By: Robert Lupinek 4/5/2016
#  Usage: ./iops_report.sh sda

#Make sure a disk device was provided as an argument
if [ $# -eq 0 ]
  then
    echo
    echo "You must provide a disk device name."
    echo "Usage: ./iops_report.sh sda"
    echo
    exit
fi

#Temp log filename
tmp_file=/var/tmp/`hostname -s`-iostat.`date +%F:%H:%M:%S`
#Device name get the iops of
device=$1
# trap ctrl-c and call ctrl_c()
trap ctrl_c INT
function ctrl_c() {
  #Ctrl C was pressed so run the reports
  average_reads=`cat $tmp_file | awk '{ sum += $3; n++ } END { if (n > 0) print sum / n; }'`
  top_reads=`cat $tmp_file | awk '{ print $3 }' | sort -ug | tail -n1`
  average_writes=`cat $tmp_file | awk '{ sum += $5; n++ } END { if (n > 0) print sum / n; }'`
  top_writes=`cat $tmp_file | awk '{ print $5 }' | sort -ug | tail -n1`
  echo
  echo "------------------------"
  echo "IOPs report for $device:"
  echo "------------------------"
  cat $tmp_file
  echo "Top read IOPs:  $top_reads  Average read IOPs: $average_reads"
  echo "Top write IOPs: $top_writes  Average writes IOPs: $average_writes"
  #Clean up the log file...
  rm -f $tmp_file
}


#Give instructions on how to quit
echo "Press CTRL + C to finish collecting IOPs data on device $device."
#Collect the stats in a temporary file
iostat -xdN 1 | awk "/$device/"'{ print $1," r/s:" , $4, "w/s" , $5; fflush(stdout) }' 2>&1 | tee $tmp_file
