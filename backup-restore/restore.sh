#!/bin/bash

# This script takes the date in format YYYYMMDD
# By default we do backup everyday so timestamp will be unique

if [ $# -ne 1 ]
then
  echo 'Run the script as restore.sh with latest or date <YYYYMMDD> which is the backup date to restore to..'
  echo 'Usage: restore.sh <latest|20200725>'
  exit 1
else
  if [ "$1" == 'latest' ]
  then
    TIMESTAMP=$(date +%Y%m%d)
  else
    if [ "${#1}" -lt 8 ]; then echo "invalid date ..should have MM & dd"; exit 1; fi
    TIMESTAMP=$(date --date="$1" +%Y%m%d)
  fi
fi
echo "Target timestamp is **** $TIMESTAMP ****"

RESTORE_RC=0
BACKUP_PATH=/home/vagrant/backups

# To restore all the containers volumes

# The container would be run by compose and once running their data volume would be replaced by backup

for CONTAINER in $(docker ps -a --format={{.Names}})
do
  echo "All the containers running currently are $CONTAINER"
  # Check their mounts
  MOUNTSNUM=$(docker inspect --format '{{json .Mounts}}' $CONTAINER | jq '. | length')
  echo "Mount number is $MOUNTSNUM"
  volumesfromcontainer=$(docker inspect --format '{{json .Mounts}}' $CONTAINER | jq '.')
  for (( i=0; i <= $((MOUNTSNUM-1)); i++ ))
  do
    echo "Analyzing mount #$i"
    echo $volumesfromcontainer | jq '.['$i']'
    nameetdest=$(echo $volumesfromcontainer | jq -r '.['$i'] | .Name,.Destination')
    DVNAME=$(echo $nameetdest | awk '{print $1}')
    DVDEST=$(echo $nameetdest | awk '{print $2}')
    # For the ones which are not data the name will be null
    if [ "$DVNAME" != 'null' ]
    then
      echo "Vol is $DVNAME, and destination is $DVDEST"
      # Now from the backup dir we first take the one which match timestamp
      backup_tar=$(ls -lthr $BACKUP_PATH | grep "$TIMESTAMP" | grep "$DVNAME" | awk '{print $9}')
      echo "The backups are $backup_tar"
      docker run --rm --volumes-from jenkins -v $BACKUP_PATH:/backups alpine sh -c "cd $DVDEST && rm -r * && tar xvf /backups/$backup_tar"
      the_rc=$?
      if [ $the_rc -ne 0 ]
      then
        echo "docker run command failed with return code $the_rc"
        # We assign one to BACKUP_RC
        RESTORE_RC=1
      fi
    else
      echo "This is not the data volume....."
    fi
  done
done

if [ $RESTORE_RC -ne 0 ]
then
  echo "Backup failed"
  exit 1
else
  echo "Restore is successful....."
  exit 0
fi