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

for CONTAINER in $(docker ps -a --format={{.Names}} | grep $NAME)
do
  echo "CONTAINER is $CONTAINER"
done



