#!/bin/bash
# This will perform a timestamped weekly backup of the /home/ folders
# Created on 6 September 2013
# Erik Knechtel

# Edited Jan 2014 because these backups are getting to be 200+ Megs, 
# so I need to add some error checking to see if it should delete old
# backups to make room for the new ones.

#TODO:
# Have it put the backups onto a USB key stuck in my router. Check 
# available room on the stick to see if it should send me an email.

# tar cannot estimate what the resulting archive will look like so the
# most we could do is delete the previous backup, if it exists, if the 
# available space is less than 250M. And I don't want this to delete
# the previous backups.
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

tar -cpzf $DESDIR/$FILENAME $SRCDIR

