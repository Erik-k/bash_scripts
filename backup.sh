#!/bin/bash
# This will perform a timestamped weekly backup of the /home/ folders
# Created on 6 September 2013
# Erik Knechtel

# Edited Jan 2014 because these backups are getting to be 200+ Megs, 
# so I need to add some error checking to see if it should delete old
# backups to make room for the new ones.

# TODO: First check to see what the estimated size of the backup will 
# be, then compare it with df to see if it'll fit. If it will, do it,
# otherwise estimate whether deleting the oldest backup will make room.
# Ideally it would scp the backup onto my other systems but that would
# required hard coding my password in to a script. :-(

TIME=`date +"%Y-%b-%d"` 			 # Get timestamp
FILENAME="home-backups-$TIME.tar.gz" # Create filename with timestamp
SRCDIR="/home"
DESDIR="/backups"
tar -cpzf $DESDIR/$FILENAME $SRCDIR

