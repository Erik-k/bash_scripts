Various Linux bash scripts that I and others have made. I use these across my Xubuntu desktop 
and my (Angstrom) beaglebone, as well as the various Linux systems at school, so they are 
generally robust.

benchmark.sh
This script uses dd and gzip to put stress on the disk and memory (with dd) and the CPU (with gzip)
and can be run repeatedly to simulate discrete loads. It writes the results to a file.

makeRand.sh
This program creates random strings of various length, optionally including all keyboard characters.

getIP
This program was made by M. Hirsch and curls a public website to get the user's outward-facing IP.
