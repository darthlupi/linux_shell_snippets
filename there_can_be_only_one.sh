#there_can_be_only_one.sh
#Decription:
#  This script demos the functionality of the force_only_one function
#  which creates a pid file when run and removes it on exit.
#  If the pid file exists and the pid in it is running then exit the script.
#  If the pid or file does not exist then exit the script.
#Last Modified by: Robert Lupinek 4/4/2016 1:23PM

function force_only_one() {
  iam=`basename -- "$0"`
  LOCKFILE=/tmp/"$iam".pid
  #kill -0 doesn't deliver any signal but just checks if a process with the given PID exists.
  if [ -e ${LOCKFILE} ] && kill -0 `cat ${LOCKFILE}`; then
    echo "$iam already running."
    echo "See /tmp/$iam.pid for the process id."
    echo "Remove pid file if this is in error."
    exit
  fi
  # Make sure the lockfile is removed when we exit and then claim it
  trap "rm -f ${LOCKFILE}; exit" INT TERM EXIT
  echo $$ > ${LOCKFILE}

}

#Run the function that restricts how many instances of a script can be run.
force_only_one

#Put your script below this point
echo "Running an instance of " `basename -- "$0"`
echo "It will simply loop for 60 seconds and exit."
for i in `seq 1 60`
do
  sleep 1
done
