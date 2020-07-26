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