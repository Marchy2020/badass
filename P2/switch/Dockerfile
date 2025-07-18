FROM ubuntu:22.04

# Installation FRR + outils VXLAN
RUN apt-get update && apt-get install -y \
    frr \
    iproute2 \
    bridge-utils \
    iputils-ping \
    tcpdump \
    net-tools \
    && rm -rf /var/lib/apt/lists/*

# Configuration FRR
COPY daemons /etc/frr/daemons
RUN chown -R frr:frr /etc/frr/

# Script switch
COPY startup-switch.sh /startup.sh
RUN chmod +x /startup.sh

CMD ["/startup.sh"]