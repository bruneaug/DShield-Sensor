#!/usr/bin/bash

# Guy Bruneau, guybruneau@outlook.com
# Date: 29 May 2026
# Version: 0.5

# This script is used to parse the TTY logs captured by the DShield Sensor.
# It take a daily list of all the TTY logs by its hash name and parse the 
# logs into text to be transformed into a base64 file to be imported into
# Elasticsearh.
#
# Add this script to the root account to parse the logs
# 58 23 * * * /home/guy/scripts/daily_tty.sh > /dev/null 2>1&

# List the files by day save in the /srv/cowrie/var/lib/cowrie/tty directory.

TODAY=$(date "+%b %d")
YESTERDAY=$(date -d "1 day ago" '+%Y-%m-%d')
DIRECTORY="/srv/ttylog"
TTYLOG_DATA="$HOME/ttylog_data"

# Check if directory exist and create it if doesn't
# This is used to process temporary data
if [ ! -d "$TTYLOG_DATA" ]; then
   mkdir -p "$TTYLOG_DATA"
fi

# Check if directory exist and create it if doesn't
# This is used to save the results of the TTY logs
if [ ! -d "$DIRECTORY" ]; then
   mkdir -p "$DIRECTORY"
fi

# This first step is to get the previous day's logs list
# Clean up $HOME/ttylog_data directory

rm -f $HOME/ttylog_data/*

array=`cat /srv/cowrie/var/log/cowrie/cowrie.json.$YESTERDAY | jq -r | grep "Closing TTY Log" | sort | uniq | sed "s/.*message.*tty\/\(.*\) after.*/\1/g" | awk '{ print "python3 /srv/cowrie/bin/playlog -b /srv/cowrie/var/lib/cowrie/tty/"$1" | base64 -w 0 > $HOME/ttylog_data/"$1"" }'` 

   echo "${array[@]}" > $HOME/scripts/daily_list.sh
   chmod 755 $HOME/scripts/daily_list.sh
   $HOME/scripts/daily_list.sh

# Adding TTY log hash to the base64 content

# ./insert_name.sh ../ttylog_data/

DIR="$HOME/ttylog_data"
cd $DIR

# Target directory (defaults to current directory)
# This second step is to add the hash TTY log filename into the 
# base64 has as the first line to match the actor's traffic while
# logged in the DShield sensor

TARGET_DIR="${1:-.}"

# Loop through all text files
for file in "$TARGET_DIR"/*; do
    # Check if files exist
    [ -e "$file" ] || continue
    
    # Get only the file name
    name=$(basename -- "$file")
    
    # Insert name at line 1
#    sed -i "1i\\$name" "$file"
    sed -i "1i transaction.id: $name" "$file"
    
    echo "Updated: $name"
done

sed -i "2s/^/event.hash: /" $DIR/*

# This last step merge the TTY logs into a single file for processing
# by filebeat to be sent to logstash on a daily basis

awk 'FNR==0{print ""}{print}' $DIR/* > $HOME/ttylog.txt

# Convert file to JSON format

cat $HOME/ttylog.txt | jq -R . | jq -s '_nwise(2)' > $DIRECTORY/ttylog.json
