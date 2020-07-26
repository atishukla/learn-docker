#!/bin/bash

# This script takes the date in format YYYYMMDD
# By default we do backup everyday so timestamp will be unique

if [ $# -ne 1 ]
then
  echo 'Run the script as restore.sh <YYYYMMDD> which is the backup date to restore to..'
  exit 1
else
  TIMESTAMP=$(date --date="$1" +%Y%m%d)
  echo "The requested timestamp is $TIMESTAMP..."
fi