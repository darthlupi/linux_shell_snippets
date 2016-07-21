#!/bin/bash

#########################
#  Purpose:
#    This script will create a new backup directory in a directory you specify.
#    It will then fire off any backup process and place the results in the BACKUPDIR.
#    The script will remove any directories older than the DAYS_TO_RETAIN setting.
#    This script is useful to place files for an application or process into a specific directory prior to running offsite backups.
#  Last Modified by:
#    Robert Lupinek 6/6/2016
#  Example:
#    backup.sh
#########################

# If any command fails, stop this script.
set -e


TAG=`basename $0`

main () {
  DATE=$(date '+%Y%m%d.%H%M')
  BACKUPBASE=/var/opt/backup/
  BACKUPDIR=$BACKUPBASE/backup-$DATE
  #Set the number days to retain backups.
  DAYS_TO_RETAIN=30
  mkdir $BACKUPDIR
  cd $BACKUPDIR
 
  # Backup a postgres database
  su - postgres -c "pg_dump -Fc foreman > $BACKUPDIR/foreman.dump"
 
  # Create tars and stuff in the backup directory
  tar -czvf $BACKUPDIR/etc_puppet_dir.tgz /etc/puppet
 
  #Delete old backup directories
  echo "Searching for directories older than $DAYS_TO_RETAIN to remove..."
  find $BACKUPBASE -type d -mtime +$DAYS_TO_RETAIN -exec rm -rf {} \;
}

#Run the backup and pipe STDERR and STDOUT to the syslog
main 2>&1 | /usr/bin/logger -t $TAG
