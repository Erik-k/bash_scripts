#!/bin/bash
# This will perform a timestamped weekly backup of the /home/ folders
# Created on 6 September 2013
# Erik Knechtel

TIME=`date +"%Y-%b-%d"` 			 # Get timestamp
FILENAME="home-backups-$TIME.tar.gz" # Create filename with timestamp
SRCDIR="/home"
if [ -d /mnt/USBstick ]
then
	# The preferred location: a usb stick
	DESDIR="/mnt/USBstick/backups"
	SPACE_AVAIL=`df -h | tail -n 1 | awk '{print $5}' | sed "s/%$//"`
else
	# The alternative location: somewhere else on the 'bone
	DESDIR="/usr/backups"
	SPACE_AVAIL=`df -h | tail -n 1 | awk '{print $5}' | sed "s/%$//"`
fi

# Note that "space_avail" is actually a misnomer because I started using
# the percentage of space currently used. So we want to make sure its not
# greater than about 90%

if [ $SPACE_AVAIL -gt 90 ]
then
	echo "Not enough space available for backup."
	echo "Amount already used is $SPACE_AVAIL %"
	exit 1;
fi

# Check to see if a backup for today already exists. If so, append (1).
if [ -f $DESDIR/$FILENAME ]
then
	APPEND="(1)"
	FILENAME=$FILENAME$APPEND
else
	tar -czf $DESDIR/$FILENAME $SRCDIR
fi

