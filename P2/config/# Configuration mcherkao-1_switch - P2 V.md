# Configuration mcherkao-1_switch - P2 VXLAN

## Objectif
Configuration du premier switch avec OSPF underlay pour préparer le tunnel VXLAN.

## Configuration Interface IP

```bash
# Nettoyer les adresses IP existantes (si conflit)
ip addr flush dev eth0

# Configuration IP interface underlay
ip addr add 10.0.1.1/24 dev eth0
ip link set eth0 up

# Vérification interface
ip addr show eth0
ip link show eth0
```

## Configuration OSPF via FRR

```bash
# Entrer dans l'interface FRR
vtysh

# Mode configuration
configure terminal

# Configuration routeur OSPF
router ospf
 ospf router-id 1.1.1.1
 network 10.0.1.0/24 area 0
exit

# Configuration interface eth0
interface eth0
 ip address 10.0.1.1/24
 ip ospf area 0
exit

# Sortir du mode configuration
exit

# Sauvegarder la configuration
write

# Sortir de vtysh
exit
```

## Vérifications effectuées

### Test 1 : Interface réseau
```bash
# Commande
ip link show eth0

# Résultat ✅
36: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel qlen 1000
    link/ether 02:42:44:32:89:00 brd ff:ff:ff:ff:ff:ff
```

### Test 2 : Adresse IP
```bash
# Commande
ip addr show eth0

# Résultat ✅ (après nettoyage)
36: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel qlen 1000
    link/ether 02:42:44:32:89:00 brd ff:ff:ff:ff:ff:ff
    inet 10.0.1.1/24 brd 10.0.1.255 scope global eth0
    inet6 fe80::42:44ff:fe32:8900/64 scope link
```

### Test 3 : Configuration OSPF
```bash
# Commande
vtysh -c "show ip ospf interface eth0"

# Résultat ✅
eth0 is up
  ifindex 36, MTU 1500 bytes, BW 10 Mbit <UP,LOWER_UP,BROADCAST,RUNNING,MULTICAST>
  Internet Address 10.0.1.1/24, Broadcast 10.0.1.255, Area 0.0.0.0
  MTU mismatch detection: enabled
  Router ID 1.1.1.1, Network Type BROADCAST, Cost: 10000
  Transmit Delay is 1 sec, State DR, Priority 1
  No backup designated router on this network
  Multicast group memberships: OSPFAllRouters OSPFDesignatedRouters
  Timer intervals configured, Hello 10s, Dead 40s, Wait 40s, Retransmit 5
    Hello due in 4.348s
  Neighbor Count is 0, Adjacent neighbor count is 0
  Graceful Restart hello delay: 10s
  LSA retransmissions: 0
```

### Test 4 : Sauvegarde configuration
```bash
# Commande
write

# Résultat ✅
Note: this version of vtysh never writes vtysh.conf
Building Configuration...
Integrated configuration saved to /etc/frr/frr.conf
[OK]
```

## État actuel du switch 1

### ✅ Éléments configurés
- Interface eth0 : UP avec IP 10.0.1.1/24
- OSPF activé sur Area 0
- Router ID : 1.1.1.1
- État DR (Designated Router)
- Configuration sauvegardée

### ⏳ En attente
- Voisinage OSPF (Neighbor Count = 0)
- Configuration du switch 2 pour établir l'adjacence
- Tests de connectivité underlay

## Prochaines étapes

1. Configuration identique sur mcherkao-2_switch (avec IP 10.0.1.2/24 et router-id 2.2.2.2)
2. Vérification voisinage OSPF entre les deux switches
3. Test ping underlay : 10.0.1.1 ↔ 10.0.1.2
4. Configuration VXLAN overlay sur les deux switches

## Commandes de diagnostic utiles

```bash
# Vérifier processus FRR
ps aux | grep -E "(zebra|ospfd)"

# Voir configuration running
vtysh -c "show running-config"

# Voir état OSPF global
vtysh -c "show ip ospf"

# Voir table de routage
vtysh -c "show ip route"
ip route show

# Test connectivité locale
ping 10.0.1.1
```

## Notes importantes

- ⚠️ Problème résolu : Conflit d'IP (10.0.1.1 et 10.0.1.2 sur même interface)
- ✅ Solution : `ip addr flush dev eth0` puis reconfiguration propre
- ✅ La commande `write memory` n'existe pas → utiliser `write`
- ✅ Configuration sauvée dans


# Depuis mcherkao-1_host
ping 192.168.10.2

# Depuis mcherkao-2_host
ping 192.168.10.1

# Sur les switches après les pings
bridge fdb show

# Sur un switch
tcpdump -i eth0 port 4789 -v
# Puis faire ping entre hosts


## Configuration VXLAN Overlay

### Sur mcherkao-1_switch
```bash
# Utiliser /sbin/ip pour les commandes avancées
/sbin/ip link add vxlan10 type vxlan \
    id 10 \
    remote 10.0.1.2 \
    local 10.0.1.1 \
    dev eth0 \
    dstport 4789

/sbin/ip link add br0 type bridge
/sbin/ip link set vxlan10 master br0
/sbin/ip link set eth1 master br0
/sbin/ip link set vxlan10 up
/sbin/ip link set br0 up
/sbin/ip link set eth1 up
```

### Vérifications VXLAN
```bash
/sbin/ip -d link show vxlan10
bridge link show
```


Parfait ! ip existe ! Utilisons le chemin complet.

## **Configuration VXLAN avec /sbin/ip**

### **Sur mcherkao-1_switch :**

````bash
# Créer le tunnel VXLAN avec VNI 10
/sbin/ip link add vxlan10 type vxlan \
    id 10 \
    remote 10.0.1.2 \
    local 10.0.1.1 \
    dev eth0 \
    dstport 4789

# Vérifier la création VXLAN
/sbin/ip -d link show vxlan10

# Créer le bridge Layer 2
/sbin/ip link add br0 type bridge

# Connecter VXLAN et interface host au bridge
/sbin/ip link set vxlan10 master br0
/sbin/ip link set eth1 master br0

# Activer toutes les interfaces
/sbin/ip link set vxlan10 up
/sbin/ip link set br0 up
/sbin/ip link set eth1 up

# Vérifications
/sbin/ip link show br0
bridge link show
````

### **Sur mcherkao-2_switch :**

````bash
# Créer le tunnel VXLAN avec VNI 10 (symétrique)
/sbin/ip link add vxlan10 type vxlan \
    id 10 \
    remote 10.0.1.1 \
    local 10.0.1.2 \
    dev eth0 \
    dstport 4789

# Vérifier la création VXLAN
/sbin/ip -d link show vxlan10

# Créer le bridge Layer 2
/sbin/ip link add br0 type bridge

# Connecter VXLAN et interface host au bridge
/sbin/ip link set vxlan10 master br0
/sbin/ip link set eth1 master br0

# Activer toutes les interfaces
/sbin/ip link set vxlan10 up
/sbin/ip link set br0 up
/sbin/ip link set eth1 up

# Vérifications
/sbin/ip link show br0
bridge link show
````

## **Mise à jour de ton fichier .md**

````markdown
## Configuration VXLAN Overlay

### Sur mcherkao-1_switch
```bash
# Utiliser /sbin/ip pour les commandes avancées
/sbin/ip link add vxlan10 type vxlan \
    id 10 \
    remote 10.0.1.2 \
    local 10.0.1.1 \
    dev eth0 \
    dstport 4789

/sbin/ip link add br0 type bridge
/sbin/ip link set vxlan10 master br0
/sbin/ip link set eth1 master br0
/sbin/ip link set vxlan10 up
/sbin/ip link set br0 up
/sbin/ip link set eth1 up
```

### Vérifications VXLAN
```bash
/sbin/ip -d link show vxlan10
bridge link show
```
````

**Cdans switch 1 `/sbin/ip -d link show vxlan10` !** 


Test final 
# Depuis mcherkao-1_host
ping 192.168.10.2

# Depuis mcherkao-2_host
ping 192.168.10.1
