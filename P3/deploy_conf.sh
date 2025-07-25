#!/bin/bash

running_containers=$(docker ps -q)
if [[ -n $running_containers ]]; then
  for cid in $running_containers; do
    hname=$(docker exec $cid hostname)
    # Adapter ici selon tes vrais patterns de noms
    case $hname in
      host-mcherkao-*|routeur-mcherkao-*)
        filename="$hname"
        if [[ -f $filename ]]; then
          docker cp "$filename" "$cid":/
          docker exec "$cid" ash "/$filename"
          echo "Configuration is applied on $cid ($hname)"
        else
          echo "Fichier $filename introuvable pour $hname"
        fi
        ;;
      *)
        echo "Aucune configuration appliquée sur $cid ($hname)"
        ;;
    esac
  done
else
  echo "No running containers"
  exit 1
fi