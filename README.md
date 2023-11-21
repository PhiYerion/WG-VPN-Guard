# WG-VPN-Guard
Many wireguard connections that are shipped to the client don't reroute or block ipv6 and it doesn't block traffic that is not routing through the VPN. This script goes through your /etc/wireguard/ directory, and forces each connection to disable ipv6 and block all traffic besides packets going to your VPN's ip address and port via UDP.

## Dependencies
iptables, ip6tables

## Usage
Get your VPN file (e.g. wg0.conf)
Put it in /etc/wireguard/
`mv ./wg0.conf /etc/wireguard/`
Get the code
`git clone https://github.com/PhiYerion/WG-VPN-Gaurd/`
(Optional) Go into the repo
`cd WG-VPN-Gaurd`
Audit the code (this is going to be run as sudo)
`less *`, `nano gen_gaurd.sh`, `nvim .`, `vim .`
Run the script as root
`sudo ./gen_gaurd.sh`
Start the VPN
`sudo wg-quick up wg0`

## (Unexpected) Effects
This blocks all conventional internet traffic (this excludes ARP and DHCP at the very least), including your local network. You will not be able to ping your router or other devices on your network.
Additionally, ipv6 is blocked. Some VPNs like Mullvad have ipv6 support, so if you want to use that you will have to modify the script or not use it.

## Testing
Testing was done via iftop and wireshark and monitoring changes in connections over time on my machine. The only responses not using wireguard from my machine's MAC address was via ARP and DHCP. There were several requests sent to my machine after turning on the vpn connection (usually part of an ongoing connection prior to turning on the vpn), but there were no responses.

## Desired changes
- Detect if ipv6 is supported on the VPN
- Optionally allow local network
- Allow lo by default
- Have options on what vpn connections to apply this to
