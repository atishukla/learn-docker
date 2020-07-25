#!/bin/bash
# Check if the parameters are there
if [ $# -ne 1 ]
then
  echo "Invalid argument."
  echo "Usage is backup.sh <name>"
  echo "where <name> is the -p parameter value passed to the compose command or the folder underwhich docker-compose file resides"
  exit 1
fi
NAME=$1
echo "Backup of $NAME"
BACKUP_RC=0

BACKUP_PATH=/home/vagrant/backups
TIMESTAMP=$(date +%Y%m%d%H%M%S)

echo $TIMESTAMP

# Loop through all the containers
# When you start the compose without container name it will use the folder name for the container name
for CONTAINER in $(docker ps -a --format={{.Names}} | grep $NAME)
do
  echo "CONTAINER is $CONTAINER"
  # Get the number of mounts
  MOUNTSNUM=$(docker inspect --format '{{json .Mounts}}' $CONTAINER | jq '. | length')
  echo "Mount number is $MOUNTSNUM"
  volumesfromcontainer=$(docker inspect --format '{{json .Mounts}}' $CONTAINER | jq '.')
  for (( i=0; i <= $((MOUNTSNUM-1)); i++ ))
  do
    echo "Analyzing mount #$i"
    echo $volumesfromcontainer | jq '.['$i']'
  done
done



