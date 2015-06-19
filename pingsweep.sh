#!/bin/bash

# A simple ping sweep program

for ip in $(seq 50 99); do
ping -c 1 128.197.127.$ip | grep "bytes from" | cut -d" " -f4 | cut -d ":" -f1 &
done

