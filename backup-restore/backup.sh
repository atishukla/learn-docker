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
    # the mounts volume for our action would be named volume and will have a name
    nameetdest=$(echo $volumesfromcontainer | jq -r '.['$i'] | .Name,.Destination')
    DVNAME=$(echo $nameetdest | awk '{print $1}')
    DVDEST=$(echo $nameetdest | awk '{print $2}')
    # For the ones which are not data the name will be null
    if [ "$DVNAME" != 'null' ]
    then
      # docker compose copies folder name or project name to volume
      if grep "$NAME" <<<"$DVNAME"
      then
        echo "Volume is $DVNAME, mount location is $DVDEST"
        TARNAME=$TIMESTAMP-$CONTAINER-$DVNAME.tar
        echo "Creating the tarball $BACKUP_PATH/$TARNAME"
        docker run --rm --volumes-from $CONTAINER -v $BACKUP_PATH:/backup alpine tar -czvf /backup/$TARNAME -C $DVDEST .
        the_rc=$?
        if [ $the_rc -ne 0 ]
        then
          echo "docker run command failed with return code $the_rc"
          # We assign one to BACKUP_RC
          BACKUP_RC=1
        fi
      else
        echo "Did not find any relevant volume, may be its not from compose file.."
      fi
    else
      echo "This volume is not data volume can be socket mapping etc with TYPE BIND.."
    fi
  done
done

if [ $BACKUP_RC -ne 0 ]
then
  echo "Backup failed"
  rm -f $TIMESTAMP*
  exit 1
else
  echo "Back up is successful"
  exit 0



