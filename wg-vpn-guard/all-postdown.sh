#!/bin/sh

# Reset ipv6
## system
sysctl -w net.ipv6.conf.all.disable_ipv6=0
sysctl -w net.ipv6.conf.default.disable_ipv6=0
sysctl -w net.ipv6.conf.lo.disable_ipv6=0

## iptables
ip6tables -A OUTPUT -j ACCEPT
ip6tables -A INPUT -j ACCEPT

# provide fault tolerance
while true; do
	# flush rules
	ip6tables -F WG3_V6_DROP
	iptables  -F OUTPUT_WG3_V4
	iptables  -F INPUT_WG3_V4

	# There are problems with deleting the chains if there
	# are references to them.
	## delete references to chains
	iptables  -D INPUT  -j INPUT_WG3_V4
	iptables  -D OUTPUT -j OUTPUT_WG3_V4
	ip6tables -D OUTPUT -j WG3_V6_DROP
	ip6tables -D INPUT  -j WG3_V6_DROP
	## allow time for the deletion to take effect
	sleep 0.5
	## delete chains and repeat the loop until successful
	ip6tables -X WG3_V6_DROP   || continue
	iptables  -X OUTPUT_WG3_V4 || continue
	iptables  -X INPUT_WG3_V4  || continue
	## If deleting the chains didn't error, continue
	break
done
