**`README.md`** 

```markdown
# Projet réseau badass

Ubridge et wireshark doivent etre installé sur votre machine.

apt install ubridge wireshark

Ce projet est divisé en 3 parties :

- P1 : configuratuion avec GNS3 (2 images dockers)
- P2 : Implémentation de VXLAN pour le réseau overlay
- P3 : Configuration BGP EVPN pour le réseau multi-sites

***P1 : Configuration GNS3 avec Docker

Nous avons crée un Github Action qui build les dockers automatiquement et en adequation avec l'architecture de chacun de nos ordinateurs (AMD64 et ARM64).


### **P1** : Base multi-protocoles
- On crés un routeur capable de parler **tous les protocoles** (daemons FRR : bgpd, ospfd, isisd, zebra)

bgpd=yes      # Pour P3 (BGP EVPN) - Écoute sur le port 179
ospfd=yes     # Pour P2/P3 (connectivité de base)
isisd=yes     # Bonus/alternative à ospfd
zebra=always  # Obligatoire (auto-démarré)

- Prêt pour P2 (VXLAN) et P3 (BGP EVPN)


### **P2** : OSPF pour l'underlay
- OSPF assure la connectivité IP de base
- VXLAN utilise cette connectivité pour créer les tunnels

#### Test configuration mcherkao-1_switch
- Interface eth0 : UP ✅
- IP : 10.0.1.1/24 ✅  
- OSPF Area 0 : ✅
- Router ID : 1.1.1.1 ✅
- État : DR (Designated Router) ✅

#### Commandes de vérification validées
```bash
ip addr show eth0
vtysh -c "show ip ospf interface eth0"
vtysh -c "show ip ospf"
```

### **P3** : BGP EVPN pour le réseau multi-sites
- BGP étendu pour échanger des infos MAC/IP
- OSPF + BGP EVPN = architecture datacenter moderne



