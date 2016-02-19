#Creates and entry in rc.local and the runonce.sh script that is called from rc.local.
#The runonce.sh scipt will run what ever commands you instruct it to and remove
#itself from rc.local and then remove actual script.

#Create an entry in the rc.local file that will be deleted
#by the runonce.sh script that it is running.
#The key is the #DELETE THIS FIRSTBOOT ENTRY
#Every line with that comment will be deleted from rc.local
echo "/tmp/runonce.sh #DELETE THIS FIRSTBOOT ENTRY" >> /etc/rc.local

#Create the run once script
cat > /tmp/runonce.sh << EOF
#!/bin/bash
#This script will run once, remove itself from the rc.local file, and remove itself.
#Modified by: Robert Lupinek 2/8/2016
#This script is created by kickstart.
#Run what ever you want to run once...
echo "Testing 123..." > /var/tmp/test.txt

#Clean up rc.local and this file to make this "Run once"
sed -i '/DELETE THIS FIRSTBOOT ENTRY/d' /etc/rc.local
rm -f $0
EOF
