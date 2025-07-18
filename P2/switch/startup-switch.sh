#!/bin/bash
echo "🔧 Switch P2 - OSPF + VXLAN"

# Démarrer FRR
source /usr/lib/frr/frrcommon.sh
/usr/lib/frr/watchfrr $(daemon_list) &
sleep 15

HOSTNAME=$(hostname)
echo "Switch hostname: $HOSTNAME"

case $HOSTNAME in
    *switch-1*)
        echo "📡 Configuration Switch 1..."
        /sbin/ip addr add 10.0.1.1/24 dev eth0
        /sbin/ip link set eth0 up
        vtysh -c "configure terminal" -c "router ospf" -c "ospf router-id 1.1.1.1" -c "network 10.0.1.0/24 area 0" -c "exit" -c "interface eth0" -c "ip ospf area 0" -c "exit" -c "exit" -c "write"
        sleep 25
        /sbin/ip link add br0 type bridge
        /sbin/ip link add vxlan10 type vxlan id 10 remote 10.0.1.2 local 10.0.1.1 dev eth0 dstport 4789
        /sbin/ip link set vxlan10 master br0 && /sbin/ip link set eth1 master br0
        /sbin/ip link set vxlan10 up && /sbin/ip link set br0 up && /sbin/ip link set eth1 up
        echo "✅ Switch 1 configuré"
        ;;
    *switch-2*)
        echo "📡 Configuration Switch 2..."
        /sbin/ip addr add 10.0.1.2/24 dev eth0
        /sbin/ip link set eth0 up
        vtysh -c "configure terminal" -c "router ospf" -c "ospf router-id 2.2.2.2" -c "network 10.0.1.0/24 area 0" -c "exit" -c "interface eth0" -c "ip ospf area 0" -c "exit" -c "exit" -c "write"
        sleep 25
        /sbin/ip link add br0 type bridge
        /sbin/ip link add vxlan10 type vxlan id 10 remote 10.0.1.1 local 10.0.1.2 dev eth0 dstport 4789
        /sbin/ip link set vxlan10 master br0 && /sbin/ip link set eth1 master br0
        /sbin/ip link set vxlan10 up && /sbin/ip link set br0 up && /sbin/ip link set eth1 up
        echo "✅ Switch 2 configuré"
        ;;
    *)
        echo "⚠️ Switch hostname non reconnu: $HOSTNAME"
        ;;
esac

echo "✅ Switch configuration terminée"
tail -f /dev/null