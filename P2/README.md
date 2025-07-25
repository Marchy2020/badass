# Topologie P2 – VXLAN avec Switch Central

```
           [host_mcherkao_1]         [host_mcherkao_2]         [host_mcherkao_3]
                |                         |                         |
             [br0]                     [br0]                     [br0]
                |                         |                         |
        [routeur_mcherkao-1]      [routeur_mcherkao-2]      [routeur_mcherkao-3]
                \                      |                      /
                 \_____________________|____________________/
                              |
                         [SWITCH CENTRAL]
```

## Fonctionnement

- **Chaque routeur** possède :
  - Une interface VXLAN (`vxlan10`) connectée au switch central (via `eth0` ou une interface dédiée)
  - Un bridge (`br0`) qui relie le host local et l’interface VXLAN
- **Le switch central** permet à tous les VXLAN de communiquer (multicast ou unicast selon la config)
- **Chaque host** (`30.1.1.1`, `30.1.1.2`, `30.1.1.3`) est sur le même réseau overlay grâce au VXLAN

---

## Underlay & Overlay

- **Underlay** : le switch central + les liens `eth0` entre chaque routeur et le switch (ex : `10.0.0.1`, `10.0.0.2`, `10.0.0.3`)
- **Overlay** : VXLAN entre tous les routeurs, reliant les hosts comme s’ils étaient sur le même LAN

---

## Exemple de schéma simplifié

```
[host_mcherkao_1]      [host_mcherkao_2]      [host_mcherkao_3]
      |                      |                      |
    [br0]                  [br0]                  [br0]
      |                      |                      |
 [routeur_1]            [routeur_2]            [routeur_3]
      |                      |                      |
   eth0:10.0.0.1         eth0:10.0.0.2         eth0:10.0.0.3
      \_____________________|_____________________/ 
                 |         |         |
              [SWITCH CENTRAL] (underlay)
```

---

## Overlay (VXLAN)

- Chaque routeur crée une interface `vxlan10` (VNI 10) reliée à `eth0`.
- Le bridge `br0` relie le host local et `vxlan10`.
- Les hosts (`30.1.1.1`, `30.1.1.2`, `30.1.1.3`) sont sur le même réseau virtuel grâce au VXLAN.

---

## VXLAN Multicast

Pour le VXLAN multicast :  
Sur chaque routeur, la création de `vxlan10` doit utiliser une adresse multicast (ex : `group 239.1.1.1`) pour que tous les VXLAN se découvrent via le switch central.

**Exemple de commande :**
```sh
ip link add name vxlan10 type vxlan id 10 dev eth0 group 239.1.1.1 dstport 4789
```

Ainsi, tous les hosts sont sur le même LAN virtuel, même s’ils sont physiquement séparés.

---

## VXLAN Unicast vs Multicast

- **Unicast** :  
  Chaque VTEP (routeur) connaît explicitement l’adresse IP de tous les autres VTEP (option `remote`).  
  Exemple :
  ```sh
  ip link add name vxlan10 type vxlan id 10 dev eth0 remote 10.0.0.2 dstport 4789
  ```
  Limité : il faut ajouter une interface VXLAN par pair de VTEP, ce qui ne scale pas bien.

- **Multicast** :  
  Tous les VTEP rejoignent un groupe multicast (ex : `239.1.1.1`).  
  Les trames VXLAN sont envoyées à l’adresse multicast, et tous les VTEP du groupe les reçoivent automatiquement.  
  Exemple :
  ```sh
  ip link add name vxlan10 type vxlan id 10 dev eth0 group 239.1.1.1 dstport 4789
  ```
  Scalable : il suffit que tous les VTEP soient membres du même groupe multicast.

**Résumé** :  
- Unicast : tu configures explicitement chaque pair de VTEP (peu scalable).
- Multicast : tous les VTEP partagent une même adresse multicast pour la découverte automatique (plus simple et scalable).
- Les adresses IP des routeurs (`eth0`) restent dans le même réseau underlay dans les deux cas.
- La différence est dans la façon dont VXLAN distribue les trames (`remote` vs `group`).

---

## Définir le groupe multicast

Le groupe multicast pour VXLAN est défini dans la commande de création de l’interface VXLAN sur chaque routeur.

**Dans `/etc/network/interfaces` :**
```ini
auto vxlan10
iface vxlan10 inet manual
    pre-up ip link add name vxlan10 type vxlan id 10 dev eth0 group 239.1.1.1 dstport 4789
    post-down ip link del vxlan10
```

- **À faire sur chaque routeur** :  
  Tous les routeurs doivent utiliser exactement la même adresse multicast (ex : `239.1.1.1`) dans la commande de création de `vxlan10`.