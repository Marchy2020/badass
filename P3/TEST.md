# Vérifications P3 – VXLAN EVPN avec Route Reflector (RR)

Voici les commandes à exécuter sur chaque routeur et host pour vérifier que la configuration VXLAN EVPN fonctionne correctement avec BGP et le Route Reflector.

---

## 1. Vérifier les interfaces réseau

Sur chaque **VTEP** et le **Route Reflector** :
```sh
ip addr
ip link show
```
- Vérifie que `eth0`, `lo`, `vxlan10` et `br0` sont bien présents et UP.

---

## 2. Vérifier la présence de l’interface VXLAN

```sh
ip -d link show vxlan10
```
- Vérifie que l’interface existe et est bien UP.

---

## 3. Vérifier la table de routage

```sh
ip route
```
- Vérifie que les routes vers les réseaux des hosts et des loopbacks sont présentes.

---

## 4. Vérifier le bridge

```sh
brctl show
bridge link
```
- Vérifie que `br0` contient bien `vxlan10` et l’interface du host local (ex : `eth1`).

---

## 5. Vérifier la connectivité entre hosts

Depuis **host_mcherkao_1** :
```sh
ping 30.1.1.2
ping 30.1.1.3
```
- Les pings doivent répondre depuis les autres hosts.

---

## 6. Vérifier les voisins OSPF

Sur chaque routeur :
```sh
vtysh -c 'show ip ospf neighbor'
```
- Vérifie que tous les voisins attendus sont présents et dans l’état FULL.

---

## 7. Vérifier les voisins BGP

Sur chaque routeur :
```sh
vtysh -c 'show bgp summary'
```
- Vérifie que les sessions BGP avec le Route Reflector (et entre VTEP si configuré) sont en état Established.

---

## 8. Vérifier la base EVPN

Sur chaque routeur :
```sh
vtysh -c 'show bgp l2vpn evpn'
```
- Vérifie que les MAC/IP des hosts sont bien apprises et propagées via EVPN.

---

## 9. Vérifier le trafic VXLAN (optionnel)

Sur un VTEP, pour voir le trafic VXLAN :
```sh
tcpdump -i eth0 udp port 4789
```
- Tu dois voir des paquets VXLAN échangés entre les VTEP.

---

## 10. Vérifier les logs système (optionnel)

```sh
dmesg | grep vxlan
```
- Vérifie qu’il n’y a pas d’erreur lors de la création de l’interface VXLAN.

---

**Si toutes ces vérifications sont OK, ta configuration VXLAN EVPN avec Route Reflector fonctionne correctement sur P3 !**



vtysh -c 'show running-config'