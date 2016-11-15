#!/bin/sh
host=`hostname`
#Set the default exit code to no error.
exit_code=0
echo "Checking for Read Only File Systems:"
for mountpoint in `mount | awk '{ print $3}'  | grep -vE '^/boot|swap|tmpfs|devpts|sysfs|proc|^/sys|^/dev' `
do
  test_file=$mountpoint/ro_test_file
  touch $test_file
  if [ $? -eq 0 ]
  then
    rm -f $test_file;
  else
    echo "$mountpoint is read only on $host."
    exit_code=1
  fi

done

if [ $exit_code = 0 ]
then
  echo "  No read only file systems found on $host."
fi
exit $exit_code
