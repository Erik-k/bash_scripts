#!/bin/bash
# Ping the router, modem, gateway, and google and record the results

ROUTER=192.168.2.1
MODEM=24.147.9.39	# This is also my IP address as the world sees it
GOOGLE=www.google.com

TIME=`date +"%Y-%d-%b"`
DIR="/home/root/ping_logs"
FILENAME_R="router_$TIME.log"
FILENAME_M="modem_$TIME.log"
FILENAME_G="google_$TIME.log"
HOUR=`date +%H`		# I'd like to add this to the log. Not sure how.

echo "Hour: $HOUR" | tee -a $DIR/$FILENAME_R | tee -a $DIR/$FILENAME_M | tee -a $DIR/$FILENAME_G
ping -c 5 $ROUTER | grep rtt | awk '{ print $2" = "$4" ms"}' >> $DIR/$FILENAME_R
ping -c 5 $MODEM | grep rtt | awk '{ print $2" = "$4" ms"}' >> $DIR/$FILENAME_M
ping -c 5 $GOOGLE | grep rtt | awk '{ print $2" = "$4" ms"}' >> $DIR/$FILENAME_G
