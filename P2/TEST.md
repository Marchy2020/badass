# Vérifications P2 – VXLAN avec Switch Central

Voici les commandes à exécuter sur chaque routeur et host pour vérifier que la configuration VXLAN multicast fonctionne correctement.

---

## 1. Vérifier les interfaces réseau

Sur chaque **routeur** :
```sh
ip addr
ip link show
```
- Vérifie que `eth0`, `vxlan10` et `br0` sont bien présents et UP.

---

## 2. Vérifier la présence de l’interface VXLAN

```sh
ip -d link show vxlan10
```
- Vérifie que l’interface a bien le paramètre `group 239.1.1.1`.

---

## 3. Vérifier la table de routage

```sh
ip route
```
- Vérifie que les routes vers les réseaux des hosts existent et passent par `br0`.

---

## 4. Vérifier le bridge

```sh
brctl show
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

## 6. Vérifier le trafic VXLAN (optionnel)

Sur un routeur, pour voir le trafic VXLAN :
```sh
tcpdump -i eth0 udp port 4789
```
- Tu dois voir des paquets VXLAN échangés entre les routeurs.

---

## 7. Vérifier le groupe multicast (optionnel)

Sur chaque routeur :
```sh
ip maddr show dev eth0
```
- Vérifie que l’adresse multicast `239.1.1.1` apparaît dans la liste.

---

## 8. Vérifier les logs système (optionnel)

```sh
dmesg | grep vxlan
```
- Vérifie qu’il n’y a pas d’erreur lors de la création de l’interface VXLAN.

---

**Si toutes ces vérifications sont OK, ta configuration VXLAN multicast fonctionne correctement sur P2 !**