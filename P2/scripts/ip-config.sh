#!/bin/bash

# Switch 1
if [ "$1" = "1" ]; then
    ip addr add 10.0.1.1/24 dev eth0
    ip link set eth0 up
    echo "IP 10.0.1.1/24 configurée sur eth0"
fi

# Switch 2  
if [ "$1" = "2" ]; then
    ip addr add 10.0.1.2/24 dev eth0
    ip link set eth0 up
    echo "IP 10.0.1.2/24 configurée sur eth0"
fi