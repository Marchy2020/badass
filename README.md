**`README.md`** 

```markdown
# Projet réseau badass

Ce projet est divisé en 3 parties :

- P1 : Mise en place de routeurs sous Docker avec Quagga et GNS3 (2 images dockers)
- P2 : Implémentation de VXLAN pour le réseau overlay
- P3 : Configuration BGP EVPN pour le réseau multi-sites

-Builder les dockers avant de lancer GNS3 

# Builder l'image host
docker build -t antoine-host:latest P1/host/

# Builder l'image router  
docker build -t antoine-router:latest P1/router/

