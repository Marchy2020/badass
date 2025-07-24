#!/bin/bash
echo "🚀 Déploiement configs P3..."

# Détecter les containers par image GitHub Actions
echo "🔍 Détection des containers..."

# Lister tous les containers router par image
ROUTER_CONTAINERS=($(docker ps --filter "ancestor=ghcr.io/marchy2020/badass-router:latest" --format "{{.Names}}" | sort))

if [ ${#ROUTER_CONTAINERS[@]} -lt 4 ]; then
    echo "❌ Seulement ${#ROUTER_CONTAINERS[@]} containers router détectés, il en faut 4"
    echo "📋 Containers trouvés :"
    docker ps --filter "ancestor=ghcr.io/marchy2020/badass-router:latest" --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
    exit 1
fi

# Assigner les containers (dans l'ordre alphabétique)
RR_CONTAINER=${ROUTER_CONTAINERS[0]}
VTEP1_CONTAINER=${ROUTER_CONTAINERS[1]}
VTEP2_CONTAINER=${ROUTER_CONTAINERS[2]}
VTEP3_CONTAINER=${ROUTER_CONTAINERS[3]}

echo "📋 Containers assignés :"
echo "RR: $RR_CONTAINER"
echo "VTEP1: $VTEP1_CONTAINER"
echo "VTEP2: $VTEP2_CONTAINER"
echo "VTEP3: $VTEP3_CONTAINER"

# Vérification que tous les containers sont détectés
if [ -z "$RR_CONTAINER" ] || [ -z "$VTEP1_CONTAINER" ] || [ -z "$VTEP2_CONTAINER" ] || [ -z "$VTEP3_CONTAINER" ]; then
    echo "❌ Impossible de détecter tous les containers nécessaires"
    exit 1
fi

# Nettoyage des IPs existantes pour éviter les conflits
echo "🧹 Nettoyage des IPs existantes..."
docker exec $RR_CONTAINER ip addr flush dev eth0 2>/dev/null || true
docker exec $VTEP1_CONTAINER ip addr flush dev eth0 2>/dev/null || true
docker exec $VTEP2_CONTAINER ip addr flush dev eth0 2>/dev/null || true
docker exec $VTEP3_CONTAINER ip addr flush dev eth0 2>/dev/null || true

# Configuration propre des IPs
echo "🌐 Configuration IPs propre..."
docker exec $RR_CONTAINER ip addr add 10.0.0.100/24 dev eth0
docker exec $VTEP1_CONTAINER ip addr add 10.0.0.1/24 dev eth0
docker exec $VTEP2_CONTAINER ip addr add 10.0.0.2/24 dev eth0
docker exec $VTEP3_CONTAINER ip addr add 10.0.0.3/24 dev eth0

# Vérification IPs après configuration
echo "🔍 Vérification IPs..."
echo "RR: $(docker exec $RR_CONTAINER ip addr show eth0 | grep 'inet ' | awk '{print $2}' | head -1)"
echo "VTEP1: $(docker exec $VTEP1_CONTAINER ip addr show eth0 | grep 'inet ' | awk '{print $2}' | head -1)"
echo "VTEP2: $(docker exec $VTEP2_CONTAINER ip addr show eth0 | grep 'inet ' | awk '{print $2}' | head -1)"
echo "VTEP3: $(docker exec $VTEP3_CONTAINER ip addr show eth0 | grep 'inet ' | awk '{print $2}' | head -1)"

# Test connectivité de base
echo "🔍 Test connectivité de base..."
docker exec $VTEP1_CONTAINER ping -c 2 10.0.0.100 && echo "✅ Ping VTEP1->RR OK" || echo "❌ Ping VTEP1->RR KO"

# Si la connectivité échoue, diagnostiquer
if ! docker exec $VTEP1_CONTAINER ping -c 1 10.0.0.100 >/dev/null 2>&1; then
    echo "⚠️ Problème de connectivité détecté !"
    echo "🔍 Diagnostic rapide..."
    echo "Interfaces RR:"
    docker exec $RR_CONTAINER ip addr show eth0 | grep "inet "
    echo "Interfaces VTEP1:"
    docker exec $VTEP1_CONTAINER ip addr show eth0 | grep "inet "
    echo "👉 Vérifiez la topologie GNS3 (liens verts ?)"
fi

# Configuration FRR
echo "📡 Configuration FRR..."

echo "Config RR..."
docker cp config/frr-rr.conf $RR_CONTAINER:/etc/frr/frr.conf

echo "Config VTEP1..."
docker cp config/frr-vtep-1.conf $VTEP1_CONTAINER:/etc/frr/frr.conf

echo "Config VTEP2..."
docker cp config/frr-vtep-2.conf $VTEP2_CONTAINER:/etc/frr/frr.conf

echo "Config VTEP3..."
docker cp config/frr-vtep-3.conf $VTEP3_CONTAINER:/etc/frr/frr.conf


# Rechargement FRR en douceur
echo "🔄 Rechargement FRR..."
docker exec $RR_CONTAINER vtysh -c "configure terminal" -c "router bgp 65001" -c "exit" -c "write memory" 2>/dev/null || true
docker exec $VTEP1_CONTAINER vtysh -c "configure terminal" -c "router bgp 65001" -c "exit" -c "write memory" 2>/dev/null || true
docker exec $VTEP2_CONTAINER vtysh -c "configure terminal" -c "router bgp 65001" -c "exit" -c "write memory" 2>/dev/null || true
docker exec $VTEP3_CONTAINER vtysh -c "configure terminal" -c "router bgp 65001" -c "exit" -c "write memory" 2>/dev/null || true

echo "✅ Configurations appliquées !"

# Pause pour laisser BGP s'établir
echo "⏳ Attente établissement des sessions BGP..."
sleep 15

# Vérification finale
echo "🔍 Vérification finale..."

echo "=== Route Reflector BGP ==="
docker exec $RR_CONTAINER vtysh -c "show bgp summary"

echo ""
echo "=== VTEP1 BGP ==="
docker exec $VTEP1_CONTAINER vtysh -c "show bgp summary"

echo ""
echo "=== VTEP1 L2VPN EVPN ==="
docker exec $VTEP1_CONTAINER vtysh -c "show bgp l2vpn evpn summary"

echo ""
echo "🔍 Test connectivité finale..."
docker exec $VTEP1_CONTAINER ping -c 2 10.0.0.100 && echo "✅ VTEP1->RR OK" || echo "❌ VTEP1->RR KO"
docker exec $VTEP2_CONTAINER ping -c 2 10.0.0.100 && echo "✅ VTEP2->RR OK" || echo "❌ VTEP2->RR KO"
docker exec $VTEP3_CONTAINER ping -c 2 10.0.0.100 && echo "✅ VTEP3->RR OK" || echo "❌ VTEP3->RR KO"

echo ""
echo "🎉 Déploiement P3 terminé !"