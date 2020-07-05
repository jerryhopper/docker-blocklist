#!/bin/sh

set -e

# Helper command to manipulate both the IPv4 and IPv6 tables.
ip46tables() {
  iptables -w "$@"
  ip6tables -w "$@"
}

cleanup() {
  echo "Cleanup..."
  ip46tables -D INPUT -j blocklist 2> /dev/null || true
  ip46tables -F blocklist 2> /dev/null || true
  ip46tables -X blocklist 2> /dev/null || true
  echo "...done."
  exit 0
}

# Redownload the lists if they are at least a day old
if [ $(stat -c%Y /lists/drop.txt) -le $(( $(date +%s) - 86400 )) ]; then
    curl https://www.spamhaus.org/drop/drop.txt 2> /dev/null | sed 's/;.*//' > /lists/drop.txt
fi
if [ $(stat -c%Y /lists/dropv6.txt) -le $(( $(date +%s) - 86400 )) ]; then
    curl https://www.spamhaus.org/drop/dropv6.txt 2> /dev/null | sed 's/;.*//' > /lists/dropv6.txt
fi

trap cleanup TERM

ip46tables -D INPUT -j blocklist 2> /dev/null || true
ip46tables -F blocklist 2> /dev/null || true
ip46tables -X blocklist 2> /dev/null || true

ip46tables -N blocklist

echo "Configuring IPv4 blocklist..."
for ip in $(cat /lists/drop.txt); do
  iptables -A blocklist -s $ip -j DROP
done
iptables -A blocklist -j RETURN

echo "Configuring IPv6 blocklist..."
for ip in $(cat /lists/dropv6.txt); do
  ip6tables -A blocklist -s $ip -j DROP
done
ip6tables -A blocklist -j RETURN

ip46tables -I INPUT -j blocklist

echo "...done."

tail -f /dev/null
