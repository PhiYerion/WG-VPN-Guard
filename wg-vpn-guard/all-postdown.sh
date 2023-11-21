ip6tables -A OUTPUT -j ACCEPT
ip6tables -A INPUT -j ACCEPT
sysctl -w net.ipv6.conf.all.disable_ipv6=0
sysctl -w net.ipv6.conf.default.disable_ipv6=0
sysctl -w net.ipv6.conf.lo.disable_ipv6=0

while true; do
	ip6tables -F WG3_V6_DROP
	iptables  -F OUTPUT_WG3_V4
	iptables  -F INPUT_WG3_V4
	iptables  -D INPUT  -j INPUT_WG3_V4
	iptables  -D OUTPUT -j OUTPUT_WG3_V4
	ip6tables -D OUTPUT -j WG3_V6_DROP
	ip6tables -D INPUT  -j WG3_V6_DROP
	sleep 0.5
	ip6tables -X WG3_V6_DROP   || continue
	iptables  -X OUTPUT_WG3_V4 || continue
	iptables  -X INPUT_WG3_V4  || continue
	break
done
