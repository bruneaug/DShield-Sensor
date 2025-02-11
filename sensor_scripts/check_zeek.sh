#/usr/bin/bash
# 
# Guy Bruneau
# Date: 11 Feb 2025
# Version: 1.0
#
# Change your home directory accordingly 
# Check Zeek status hourly
#0 * * * * /home/ubuntu/scripts/check_zeek.sh > /dev/null 2>1&
#
RESTART=`sudo zeekctl restart`
CRASHED=`sudo zeekctl status |awk '{ print $4 }' | tail +2`

if [ $CRASHED == "crashed" ]; then
 echo "System $CRASHED"
 $RESTART

fi

