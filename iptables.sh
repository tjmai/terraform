#!/bin/bash

# setup basic chains and allow all or we might get locked out while the rules are running...
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

# clear rules
iptables -F

# allow HTTP inbound and replies
iptables -A INPUT -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT

# allow HTTPS inbound and replies
iptables -A INPUT -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 443 -m state --state ESTABLISHED -j ACCEPT

# limit ssh connects to 10 every 10 seconds
iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --set
iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --update --seconds 10 --hitcount 10 -j DROP

# allow SSH inbound and replies from bastion host
# change the port 22 if ssh is listening on a different port (which it should be)
#iptables -A INPUT -p tcp -s 172.28.100.15 --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
#iptables -A OUTPUT -p tcp --sport 22 -d 172.28.100.15 -m state --state ESTABLISHED -j ACCEPT

# allow SSH inbound and replies from bastion host at 22234
iptables -A INPUT -p tcp -s 172.28.100.15 --dport 22234 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 22234 -d 172.28.100.15 -m state --state ESTABLISHED -j ACCEPT

# throttle Web traffic to 60 per minute
iptables -A INPUT -p tcp -m multiport --dport 80,443 -i eth0 -m state --state NEW -m recent --set
iptables -A INPUT -p tcp -m multiport --dport 80,443 -i eth0 -m state --state NEW -m recent --update --seconds 60 --hitcount 60 -j DROP 

# root can initiate HTTP/S outbound (for yum)
iptables -A OUTPUT -p tcp --dport 80 -m owner --uid-owner root -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --dport 443 -m owner --uid-owner root -m state --state NEW,ESTABLISHED -j ACCEPT
# anyone can receive replies (ok since connections can't be initiated)
iptables -A INPUT -p tcp --sport 80 -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp --sport 443 -m state --state ESTABLISHED,RELATED -j ACCEPT

# allow DNS search and ICMP for troubleshooting
iptables -A OUTPUT -p udp --dport 53 -d 172.28.100.2 -j ACCEPT
iptables -A INPUT -p udp --sport 53 -s 172.28.100.2 -j ACCEPT
iptables -A INPUT  -p icmp -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -p icmp -j ACCEPT

# allow NTP Sync
iptables -A INPUT -p udp --sport 123 -m state --state ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p udp --sport 123 -j ACCEPT

# log dropped connection for review
iptables -A INPUT  -j LOG  -m limit --limit 12/min --log-level 4 --log-prefix 'IP INPUT drop: '
iptables -A OUTPUT  -j LOG  -m limit --limit 12/min --log-level 4 --log-prefix 'IP OUTPUT drop: '

# drop everything else
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

# save config
/sbin/service iptables save