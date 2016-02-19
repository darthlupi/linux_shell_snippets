#!/bin/bash


#Quickly output the ownership of your pwd down
#in the form of a chown command.

find ./ | while read -r f
do
        echo "chown " `ls -lad $f | awk {'print $3 ":" $4'}` $f
done
