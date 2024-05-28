#!/bin/bash

ip="$1"
echo "The ip address: $ip"
regex='^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1->

if [[ $ip =~ $regex ]]; then
echo "Valid IP address"
else
echo "Invalid IP address"
fi
unset ip regex
