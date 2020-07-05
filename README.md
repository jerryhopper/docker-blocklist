# docker-blocklist

This is a container that adds a blocklist to your hosts iptables rules (when using the --cap-add=NET_ADMIN and --net=host options). It uses the DROP blocklist from spamhaus.org.

## Usage

```
docker run --name firewall -itd --restart=always --cap-add=NET_ADMIN --net=host pingiun/docker-blocklist:latest
```
