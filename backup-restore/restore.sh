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
  MOUNTSNUM=$(docker inspect --format '{{json .Mounts}}') $CONTAINER | jq '. | length')
  echo "Mount number is $MOUNTSNUM"
  volumesfromcontainer=$(docker inspect --format '{{json .Mounts}}' $CONTAINER | jq '.')
  for (( i=0; i <= $((MOUNTSNUM-1)); i++ ))
  do
    echo "Analyzing mount #$i"
    echo $volumesfromcontainer | jq '.['$i']'
  done
done