#!/bin/bash

#Purpose: parse 
#Version:
#Author:
#Date:
#Usage:

#Function to validate if local user has  valid shell.
users_with_shells ()
{
  #Set $IFS to line breaks and returns vs spaces
  SAVEIFS=$IFS
  IFS=$(echo -en "\n\b")
  #Set the password file to loop through
  passwd_file="/etc/passwd"
  users=""
  user_exceptions="root|nagios"
  #Loop through password file to build a user deny list
  #ignoring the user exceptions.
  for line in $(cat $passwd_file | grep -Eiv $user_exceptions )
  #Alternatively you can use while read vs all the set $IFS stuff.  
  #It doesn't behave as expected if there are errors.
  #cat $passwd_file | while read line
  do
      can_login="false"
  	p_user=$(echo $line| awk -F: '{print $1}')
  	p_shell=$(echo $line | awk -F: '{print $7}')
  	#Set the shell to SOMETHING if it isn't.  Saves us from infinite grep.
  	if [ -z $p_shell ]
  	then
  	  p_shell="noshell"
  	fi
  	#Check to see if the shell is legit or not
  	if grep -v nologin /etc/shells | grep -q $p_shell 
  	then
  	  can_login="true"
  	  #Append this user to user list of known local accounts that can login
  	  users=`echo $users $p_user`
  	else
  	  #Cannot login
  	  can_login="false"
  	fi
  	#Uncomment below line if you want to echo some minor debug information.
	#echo $p_user":"$p_shell  " - Can login:" $can_login
  done
  # restore $IFS
  IFS=$SAVEIFS
}

#Generate a list of users with local shells
users_with_shells
echo $users

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
echo `hostname` ",$deny_users,$users,$status"
