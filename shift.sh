#!/bin/bash 
A="."
while [ $# -gt 0 ]; do
echo $B$1
B=${B}$A
shift
#./$0 $@
done