#!/bin/bash

#Specify username
username=$1

#Clear user adding to group file
> /tmp/user2groups.ldif

for group in `ldapsearch -x -b "ou=LoginGroups,dc=seisint,dc=com" '(!( uniqueMember=uid=$username,ou=People,dc=seisint,dc=com))' cn | grep ^cn\: | awk '{ print $2}'`
do
cat >> /tmp/user2groups.ldif << EOF
dn: cn=$group,ou=LoginGroups,dc=seisint,dc=com
changetype: modify
add: uniqueMember
uniqueMember: uid=$username,ou=People,dc=seisint,dc=com

EOF
done

#Run the file in and add the user to the groups
ldapmodify -x -D "cn=Directory Manager" -f /tmp/user2groups.ldif -W
