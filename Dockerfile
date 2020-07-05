FROM alpine

RUN apk add --no-cache tini iptables ip6tables curl

ADD configure-firewall.sh /bin

RUN curl https://www.spamhaus.org/drop/drop.txt 2> /dev/null | sed 's/;.*//' > /drop.txt
RUN curl https://www.spamhaus.org/drop/dropv6.txt 2> /dev/null | sed 's/;.*//' > /dropv6.txt

ENTRYPOINT ["/sbin/tini", "--"]

CMD ["/bin/configure-firewall.sh"]
