#!/bin/bash

#This script will monitor total CPU usage on a server.
#Usage to warn at CPU >= 90%: ./cpu_check.sh 90

arg_check () 
{
  arg_count=$1
  arg_count_expected=$2
  fail_text=$3
  if [ $arg_count -lt $arg_count_expected ]
  then
    echo -e $fail_text
    exit 1
  fi
}


main()
{
  max_cpu=$1 
  current_cpu_float=`grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage}'`
  current_cpu_int=${current_cpu_float%.*}
  echo $current_cpu_int 
  if [ $current_cpu_int -ge $max_cpu ]
  then
    echo "Warning: CPU Utilization of $current_cpu_int is greater than or equan to $max_cpu."
    exit 1
  fi
}

arg_check $# 1 "Syntax Error:\n Usage to warn at CPU >= 90%: ./mst_cpu_check.sh 90"
main $1
