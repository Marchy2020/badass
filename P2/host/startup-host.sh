#!/bin/bash
echo "Host P2 - Configuration IP"

HOSTNAME=$(hostname)
sleep 35  # Attendre VXLAN

case $HOSTNAME in
    *host-1*)
        /sbin/ip addr add 192.168.10.1/24 dev eth0
        /sbin/ip link set eth0 up
        echo "Host 1: 192.168.10.1/24"
        ;;
    *host-2*)
        /sbin/ip addr add 192.168.10.2/24 dev eth0
        /sbin/ip link set eth0 up
        echo "Host 2: 192.168.10.2/24"
        ;;
esac

tail -f /dev/null