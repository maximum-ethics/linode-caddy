#!/bin/sh
printf "\t\t\t\t Your IP: "
who am i | awk '{printf("%s\n"), $5;}' | sed 's/[()]//g'
