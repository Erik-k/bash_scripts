#!/bin/bash
#Erik Knechtel, 29 April 2014
#This script will benchmark the creation of a large file from /dev/urandom
#and the gzipping of that file, over and over.

#NOTES: the time redirect to a file wont work if you use !/bin/sh. It
#must be !/bin/bash.

#TODO: test for enough space, make more robust, etc
#Add command line parameters for the size of the hugetestfile and the name 
#of the results file and the number of times to run the whole script.
#Example: $./benchmark.sh -size=500M -n=2 -o=new_results.txt

#$SIZE=1
#$NUMBER_OF_RUNS=1
#$OUTPUT_FILE=results.txt
#For this project I'm running Tor in the background to simulate network usage.
#$TOR=0

echo "-----------------" >> results.txt
echo "Running a test:" >> results.txt

#Display free memory at start of test, for reference:
cat /proc/meminfo | head -n 2 | tail -n 1 >> results.txt

#Is tor running in the background?
#The -w arg for grep ensures we don't get false alarms from other processes
#which have the letters tor, like *storage or *creator.
if ps -e | grep -w tor; then $TOR=1; echo "FYI Tor is running in background.">>results.txt; fi

date >> results.txt

echo "Creating a 100M file:" >> results.txt
echo >> results.txt
(time dd if=/dev/urandom of=hugetestfile bs=100M count=1) 1>/dev/null 2>> results.txt
echo >> results.txt

echo "Gzipping and tarring that file:" >> results.txt
(time tar czf hugetestfile.tgz hugetestfile) 1>/dev/null 2>> results.txt
echo >> results.txt

echo "Finished test." >> results.txt
echo "----------------" >> results.txt

#Cleanup our mess
rm hugetestfile hugetestfile.tgz
