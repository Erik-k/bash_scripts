#!/bin/bash
#Erik Knechtel, 29 April 2014
#This script will benchmark the creation of a large file from /dev/urandom
#and the gzipping of that file, over and over.

#NOTES: the time redirect to a file wont work if you use !/bin/sh. It
#must be !/bin/bash.

#TODO: test for enough space, make more robust, etc
echo "-----------------" >> results.txt
echo "Running a test:" >> results.txt
date >> results.txt
echo "Creating a 100M file:" >> results.txt
echo >> results.txt
(time dd if=/dev/urandom of=hugetestfile bs=100M count=1) 1>/dev/null 2>> results.txt
echo "Gzipping and tarring that file:" >> results.txt
echo >> results.txt
(time tar czf hugetestfile.tgz hugetestfile) 1>/dev/null 2>> results.txt
echo "Finished test." >> results.txt
echo "----------------" >> results.txt
echo >> results.txt

