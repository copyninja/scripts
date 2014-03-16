#!/bin/sh

# Copied from "Linux Kernel in a Nutshell" by Greg Kroah-Hartmann

for i in $(find /sys/ -name modalias -exec cat {} \;); do
    /sbin/modprobe --config /dev/null --show-depend "$i";
done | rev | cut -f 1 -d '/' | rev | sort -u
