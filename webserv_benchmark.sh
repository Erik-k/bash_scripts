#!/bin/bash
# Erik Knechtel 29 June 2015
# This will use wget to stress-test a website hosted on another system.
# The purpose of this test is to demonstrate web-hosting capability (data
# throughput) on both the local network between the beaglebone and the 
# user system, as well as through the router, and also over the clear web
# and over tor. 

#NOTES: the time redirect to a file wont work if you use !/bin/sh. It
#must be !/bin/bash.

FILENAME=results_webserv.txt
TARGETFILE=testfile
#TESTCOMMAND=(wget -r --delete-after 192.168.1.2:8080/$TARGETFILE)
TESTCOMMAND='echo hi'
NUMBER_OF_PROCS=50

echo "-----------------" >> $FILENAME
echo "Running a test:" >> $FILENAME

date >> $FILENAME

#Display free memory at start of test, for reference:
cat /proc/meminfo | head -n 2 | tail -n 1 >> $FILENAME

# Start one wget process after another until slowdown is noticed or until the program
# is shut off. What criteria to use to know when to quit? Have the program do that or 
# have the user watch it and shut it off manually when some feedback from the program
# demonstrates the slowdown has been reached? What exactly is the criteria I'm looking
# for to determine that I'm seeing slowdown?

# declare is a bash builtin which I'm using to create dynamic variable names. I can't 
# just write PID$NUMBER="..." and then echo "Started process $PID$NUMBER".

declare -A PIDNUMBER=()

# Since brace expansion happens before variable expansion I cant just write 
# for i in {1..$VARIABLE}, I have to use eval to force the variable to be expanded
# first, before the braces. 
for i in $(eval echo {1..$NUMBER_OF_PROCS})
do
	$TESTCOMMAND &
	PIDNUMBER[$NUMBER_OF_PROCS]="$!"
	echo "Started process ${PIDNUMBER[$NUMBER_OF_PROCS]}"
	sleep 5
done 

# trap is a bash builtin. It can be found in the bash man pages.
trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

echo "Finished test." >> $FILENAME
echo "----------------" >> $FILENAME

