P3/
├── conf/
│   ├── interfaces-rr         # Config réseau Route Reflector
│   ├── frr-rr.conf           # Config BGP Route Reflector
│   ├── interfaces-vtep-1     # Config réseau VTEP 1 (OSPF underlay)
│   ├── frr-vtep-1.conf       # Config BGP EVPN VTEP 1
│   ├── interfaces-vtep-2     # Config réseau VTEP 2
│   └── frr-vtep-2.conf       # Config BGP EVPN VTEP 2
├── P3.gns3project            # Topologie 5 nœuds
└── README-P3.md              # Instructions manuelles



                       [mcherkao-rr-1] (Route Reflector)
                                10.0.0.100
                                     |
        ┌─────────────--------------─┼────────────----- ──┐
        |                            |                    |
   [mcherkao-vtep-1]       [mcherkao-vtep-2]    [mcherkao-vtep-3]
   10.0.0.1                10.0.0.2                    10.0.0.3
       |                        |                          |
   [mcherkao-host-1]       [mcherkao-host-2]    [mcherkao-host-3]
   30.1.1.1                  30.1.1.2                   30.1.1.3