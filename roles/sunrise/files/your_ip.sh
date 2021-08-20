#!/bin/sh
printf "\t\t\t\t Your IP: "
echo $SSH_CONNECTION | awk '{printf("%s\n"), $1;}'
