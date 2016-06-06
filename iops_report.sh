#!/bin/bash
#
#  Description:
#    This script will run iostat -xdN until the user issues
#    the ctrl-c key sequence.  It will then part the log file
#    for the top IOPs usage.
#  Last Modified By: Robert Lupinek 5/25/2016
#  Usage: ./iops_report.sh sda

function controlled_exit() {
  #Ctrl C was pressed so run the reports
  average_reads=`cat $iops_tmp_file | awk '{ sum += $3; n++ } END { if (n > 0) print sum / n; }'`
  top_reads=`cat $iops_tmp_file | awk '{ print $3 }' | sort -ug | tail -n1`
  average_writes=`cat $iops_tmp_file | awk '{ sum += $5; n++ } END { if (n > 0) print sum / n; }'`
  top_writes=`cat $iops_tmp_file | awk '{ print $5 }' | sort -ug | tail -n1`
  echo
  echo "------------------------"
  echo "IOPs report for $device:"
  echo "------------------------"
  echo "Top read IOPs:  $top_reads  Average read IOPs: $average_reads"
  echo "Top write IOPs: $top_writes  Average writes IOPs: $average_writes"

  #Print Disk info
  echo "-------------------------------------------"
  echo "Disk report for $(hostname)"
  echo "-------------------------------------------"
  sar -p -d -f $sar_tmp_file | head -n3 | tail -n1 | sed 's/^.........../           /'
  sar -p -d -f $sar_tmp_file | grep Average | grep $


  #Print CPU info
  echo "-------------------------------------------"
  echo "CPU report for $(hostname)"
  echo "-------------------------------------------"
  sar -f $sar_tmp_file | head -n3 | tail -n1 | sed 's/^.........../           /'
  sar -f $sar_tmp_file | grep Average
  echo "-------------------------------------------"
  echo "Memory report for $(hostname)"
  echo "-------------------------------------------"
  sar -r -f $sar_tmp_file | head -n3 | tail -n1 | sed 's/^.........../           /'
  sar -r -f $sar_tmp_file | grep Average

  #Clean up the log file...
  #rm -f $iops_tmp_file
  #rm -f $sar_tmp_file
  echo
  echo "For full reports see these files: "
  echo "iostat report: $iops_tmp_file"
  echo "sar binary report: $sar_tmp_file ( Hint: Use sar -f $sar_tmp_file )"
}



#Make sure a disk device was provided as an argument
if [ $# -eq 0 ]
  then
    echo
    echo "You must provide a disk device name."
    echo "Usage: ./perf_report.sh sda"
    echo
    exit
fi

#Temp log filename
iops_tmp_file=/var/tmp/`hostname -s`-iostat.`date +%F:%H:%M:%S`
sar_tmp_file=/var/tmp/`hostname -s`-sar.`date +%F:%H:%M:%S`
#Device name get the iops of
device=$1

#Give instructions on how to quit
echo "Press CTRL + C to finish collecting IOPs data on device $device."
#Collect the stats in a temporary file
iostat -xdN 1 | awk "/$device/"'{ print $1," r/s:" , $4, "w/s" , $5; fflush(stdout) }' 2>&1 | tee $iops_tmp_file &
iostat_pid=$!

#NOTE: The disown command removes the most recently spawned process from the watched "jobs" list.
#      This means no debug messages will be displayed when killing the process.
#Collect custom sar report
sar -r -P ALL 1 -o $sar_tmp_file &
sar_pid=$!
disown

#Trap for ctrl-c, kill the iostat background processs, kill the sar process, and run controlled exit function, exit with 1.
#The waits are their to suppress kill reporting the pids killedness.
trap "kill $iostat_pid $sar_pid;controlled_exit; exit 1" INT

#Keep this process running so that it can be terminated manually.
#If we did not, then the script will exit
wait
