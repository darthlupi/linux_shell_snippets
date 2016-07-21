#!/bin/bash

#########################
#  Purpose:
#    This script is a template.
#  Last Modified by:
#    Robert Lupinek 6/6/2016
#  Example:
#    template.sh anything
#########################


main () {
  $usage="template.sh anything"
  #Test command line arguments
  if [ $# -eq 0 ]
  then
    echo
    echo "You must provide an argument."
    echo $usage
    echo
    exit
  fi

  #Do stuff
  echo $1
  echo $#
}

main $1
