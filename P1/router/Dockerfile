# syntax=docker/dockerfile:1

FROM alpine:3.22
RUN apk add --no-cache frr tini

COPY ./daemons /etc/frr/daemons

RUN mkdir -p /var/run/frr
RUN chown -R frr:frr /etc/frr /var/run/frr

ENTRYPOINT ["/sbin/tini", "--"]

COPY ./docker-start.sh /usr/lib/frr/docker-start.sh
RUN chmod +x /usr/lib/frr/docker-start.sh
CMD ["/usr/lib/frr/docker-start.sh"]
