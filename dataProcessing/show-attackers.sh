#!/bin/bash

FILE=$1

# Try to read first parameter which should be a file path
if [[ ! -e $FILE ]]
then 
 echo "Cannot open log file: $FILE" >&2
 exit 1
fi

echo 'Count,IP,Location'

cat $FILE| grep "Failed password for root from" $FILE | awk -F "Failed password for root from" '{print $2}' | awk -F 'port' '{print $1}' | sort -n | uniq -c | 
while read COUNT IP
do
 if [[ $COUNT -gt 10 ]]
 then
   LOCATION=$(geoiplookup $IP | awk -F "," '{print $2}') 
   echo $COUNT $IP $LOCATION
 fi
done


