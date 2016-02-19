#!/bin/ksh

#Purpose: Build a list of users with valid shells and compare them to the contents of the DenyUsers clause of /etc/sshd_config.
#Version: 0.1
#Author: Robert Lupinek
#Date Modified by: 3/02/2015 Robert Lupinek
#Usage: ./denyusers_check.sh
#To see some minor debug info run it with the debug option:
#./denusers_check.sh debug
#Ouput: hostname, current DenyUsers, expected DenyUsers


#Parameter 1 is debug or not

#Set variables
user_exceptions="ftp ubd mccs mcom lotusnotes exad ssc exalytics tibco tibco2 controlm postgres isp chefsolo wms wmstest root nagios"
valid_shells="bash csh ksh pfbash pfcsh pfksh pfksh93 pfrksh pfrksh93 pfsh pftcsh pfzsh rbash remsh rksh rksh93 rsh sh  clsh tcsh wish zsh sh"
passwd_file="/etc/passwd"
users=""
#Get the OS
os=$(uname -s)

#Turn the user_exceptions string above into proper awk expression ie. !/string/ && !/string/ etc
user_exceptions=$(echo $user_exceptions  | sed 's/[^ ][^ ]*/! \/&\/ \&\&/g' | sed 's/&&$//g')

#Loop through password file to build a user deny list
#ignoring the user exceptions.

#if [[ "$os" = "Linux" ]]
#then
#echo $os
#fi

#  IFS=$'\n'       # make newlines the only separator
#for line in `cat "$passwd_file" | awk "$user_exceptions"`
cat "$passwd_file" | awk "$user_exceptions" | while read line
do
    can_login="false"
    p_user=$(echo $line| awk -F: '{print $1}')
    p_shell=$(echo $line | awk -F: '{print $7}' | awk -F/ '{print $NF}')
    #Set the shell to SOMETHING if it isn't.  Saves us from infinite grep.
    if [ -z "$p_shell" ]
    then
      p_shell="noshell"
    fi
    #Check to see if the shell is legit or not
    shell_check=$(echo $valid_shells | grep -w "$p_shell")
    if [ -z "$shell_check" ]
    then
      #Cannot login
      can_login="false"
    else
      can_login="true"
      #Append this user to user list of known local accounts that can login
      users=`echo "$users $p_user"`
    fi
    #Provide some extra output on a per user basis.
    if [[ $1 = debug ]]
    then
      echo $p_user":"$p_shell  " - Can login:" $can_login
    fi
done

#Create the awk friendly search pattern from the user list to allow for an AND match.
awk_users=`echo $users  | sed 's/[^ ][^ ]*/\/&\/ \&\&/g' | sed 's/&&$//g'`

#Gather the current settings of the sshd_config
deny_users=`grep ^DenyUsers /etc/ssh/sshd_config | tail -n 1`
matching=`grep ^DenyUsers /etc/ssh/sshd_config | awk "$awk_users"`

#Set the status
status="PASSED"

if [[ -z $deny_users || -z $matching ]]
then
  status="FAILED"
fi


#Create simple csv output
echo `hostname` ",$deny_users,DenyUsers $users,$status"