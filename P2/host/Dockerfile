FROM ubuntu:22.04

# Installation outils basiques (PAS de FRR)
RUN apt-get update && apt-get install -y \
    iproute2 \
    iputils-ping \
    net-tools \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Script host
COPY startup-host.sh /startup.sh
RUN chmod +x /startup.sh

CMD ["/startup.sh"]