#!/bin/bash

# Lancer tous les services de routage nécessaires
echo "Lancement de FRRouting..."

mkdir -p /var/run/frr
chown -R frr:frr /var/run/frr

# Lancer zebra
/usr/lib/frr/zebra -d -f /etc/frr/zebra.conf -z /var/run/frr/zebra.vty -i /var/run/frr/zebra.pid

# Lancer bgpd
/usr/lib/frr/bgpd -d -f /etc/frr/bgpd.conf -z /var/run/frr/zebra.vty -i /var/run/frr/bgpd.pid

# Lancer ospfd
/usr/lib/frr/ospfd -d -f /etc/frr/ospfd.conf -z /var/run/frr/zebra.vty -i /var/run/frr/ospfd.pid

# Lancer isisd
/usr/lib/frr/isisd -d -f /etc/frr/isisd.conf -z /var/run/frr/zebra.vty -i /var/run/frr/isisd.pid

# Garder le container actif
tail -f /dev/null
