#!/bin/bash

if [ $# -ne 1 ]
then
  echo "Usage is keep_n_backups.sh <number of backups>"
  exit 1
fi

NUMBER_OF_BACKUPS=$1
echo "Number of backups to keep: $NUMBER_OF_BACKUPS"
echo "Start cleanup"

BACKUPPATH=/home/vagrant/backups
PREFIX=20

backups=$(find $BACKUPPATH -maxdepth 1 -type f -name "$PREFIX*.tar" -exec basename {} \; | sort -r | cut -c1-14 | awk '{for (i=1;i<=NF;i++) if (!a[$i]++) printf("%s%s",$i,"\n")}' | head -$NUMBER_OF_BACKUPS)

for backup in $backups
do
  echo $backup
  rename $backup keep_$backup $BACKUPPATH/*
done

find $BACKUPPATH -maxdepth 1 -name "*.tar" ! -name "keep_*" -type f -exec rm {} \;

rename keep_$PREFIX $PREFIX $BACKUPPATH/*

echo "Cleaned up"
exit 0