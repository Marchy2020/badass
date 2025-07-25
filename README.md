**`README.md`** 

```markdown
# Projet réseau badass

Ce projet est divisé en 3 parties :

- P1 : Mise en place de routeurs sous Docker et GNS3 (2 images dockers)
- P2 : Implémentation de VXLAN pour le réseau overlay
- P3 : Configuration BGP EVPN pour le réseau multi-sites




vtysh << EOF
configure terminal
interface eth0
 no ip ospf area 0
exit
interface eth1
 no ip ospf area 0
exit
interface eth2
 no ip ospf area 0
exit
interface lo
 no ip ospf area 0
exit
router ospf
 network 0.0.0.0/0 area 0
exit
EOF
