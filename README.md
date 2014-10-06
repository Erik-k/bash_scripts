Various Linux bash scripts that I and others have made. I use these across my Xubuntu desktop 
and my (Angstrom/Debian/Ubuntu) beaglebone, as well as the various Linux systems at school, so they are 
generally robust across those platforms.

benchmark.sh
This script uses dd and gzip to put stress on the disk and memory (with dd) and the CPU (with gzip)
and can be run repeatedly to simulate discrete loads. It writes the results to a file.

makeRand.sh
This program creates random strings of various length, optionally including all keyboard characters.

getIP
This program was made by M. Hirsch and curls a public website to get the user's outward-facing IP.

checkIP 
Also by M. Hirsch, it uses sendmail to email an account whenever a device's IP is changed. Put
this in a crontab with:
crontab -e

and then at the top add:
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin

and at the bottom add:
0 * * * * ~/scripts/checkIP

Taken from http://blogs.bu.edu/mhirsch/2013/11/get-email-upon-change-of-ip-address/
