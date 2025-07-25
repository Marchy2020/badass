# Topologie P3 – VXLAN EVPN avec Route Reflector (RR)

```
                    [host_mcherkao_1]         [host_mcherkao_2]         [host_mcherkao_3]
                |                         |                         |
             [br0]                     [br0]                     [br0]
                |                         |                         |
        [routeur_mcherkao_2]      [routeur_mcherkao_3]      [routeur_mcherkao_4]
        br0:30.1.1.1/24           br0:30.1.1.2/24           br0:30.1.1.3/24
        lo:  1.1.1.2              lo:  1.1.1.3              lo:  1.1.1.4
        br0:10.1.1.2/30           br0:10.1.1.4/30           br0:10.1.1.10/30
                \                      |                      /
                 \_____________________|____________________/
                              |
                        [routeur_mcherkao-1] (Route Reflector)
                        eth0: 10.1.1.1/30
                        eth1: 10.1.1.5/30
                        eth2: 10.1.1.9/30
                        lo:   1.1.1.1/32
```

---

## Fonctionnement

- **Chaque VTEP (routeur_mcherkao_2, _3, _4)** possède :
  - Une interface VXLAN (`vxlan10`) pour l’overlay, connectée à un bridge (`br0`) avec le host local.
  - Une interface physique (`eth0`) pour l’underlay (réseau de transport, ex : `10.1.1.x`).
  - Une interface loopback (`lo`) utilisée comme router-id BGP/EVPN (ex : `1.1.1.x`).

- **Le Route Reflector (routeur_mcherkao-1)** :
  - Sert d’élément central pour l’échange des routes EVPN (BGP).
  - Possède aussi une interface physique (`eth0: 10.1.1.100`) et une loopback (`lo: 1.1.1.1`).

- **Les hosts** (`30.1.1.1`, `30.1.1.2`, `30.1.1.3`) sont sur le même réseau overlay grâce à VXLAN EVPN.

---

## Underlay & Overlay

- **Underlay** : le réseau physique/IP reliant tous les routeurs (interfaces `eth0`, ex : `10.1.1.x`).
- **Overlay** : le réseau virtuel VXLAN, reliant les hosts via les bridges et tunnels VXLAN, avec l’apprentissage des MAC/IP assuré par EVPN/BGP.
---

## Overlay (VXLAN EVPN)

- Chaque VTEP crée une interface `vxlan10` (VNI 10) reliée à `eth0`.
- Le bridge `br0` relie le host local et `vxlan10`.
- Les hosts (`30.1.1.1`, `30.1.1.2`, `30.1.1.3`) sont sur le même réseau virtuel grâce à VXLAN EVPN.
- L’apprentissage des MAC/IP et la signalisation des tunnels sont assurés dynamiquement par BGP EVPN via le Route Reflector.

---

## Résumé

- **Underlay** : réseau physique (10.0.0.x) pour le transport des paquets VXLAN et le routage OSPF/BGP.
- **Overlay** : VXLAN EVPN reliant les hosts comme s’ils étaient sur le même LAN, avec signalisation dynamique via BGP EVPN et le Route Reflector.