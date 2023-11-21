#!/bin/sh
current_dir="$(cd "$(dirname "$0")" && pwd)"

# This file is used to reset iptables and sysctl after the vpn
# is disconnected. The postdown file will be the same for all vpns.
base_postdown_file="$current_dir/all-postdown.sh"

# This includes iptables and sysctl config to disable ipv6 and block
# everything that is not going through the VPN. The postup file will
# be modified for each VPN.
base_postup_file="$current_dir/postup.frame"

# Location for the postdown file. The location will also be the same
# for all vpns.
postdown_file='/etc/wireguard/all-postdown.sh'

# Make sure the base postdown file exists
if [ ! -f "$base_postdown_file" ]; then
	echo "ERROR: $base_postdown_file not found"
	exit 1
fi

# Make sure the base postup file exists
if [ ! -f "$base_postup_file" ]; then
	echo "ERROR: $base_postup_file not found"
	exit 1
fi

# If the postdown file we would be writting to exists, proceed. Otherwise
# leave it.
if [ ! -f "$postdown_file" ]; then
	echo "Creating $postdown_file"
	# WG-VPN-Guard/all-postdown.sh -> /etc/wireguard/all-postdown.sh
	cp "$base_postdown_file" "$postdown_file" || exit 1
	# Make sure the file is executable
	chmod +x "$postdown_file" || exit 1
fi

# For each vpn config file, create a postup file and line the config
# to the postup and postdown files (at connection and at disconnection,
# respectively).
for file in /etc/wireguard/wg*.conf; do
	# e.g. /etc/wireguard/wg0.conf-postup.sh
	postup_file="$file-postup.sh"

	# If the postup file exists, delete it and create a new one.
	if [ -f "$postup_file" ]; then
		echo "Replacing $postup_file"
		rm "$postup_file" || exit 1
	else 
		echo "Creating $postup_file"
	fi

	# Get the address and port from the config file
	address=$(grep -oP '(?<=Endpoint = )[0-9.]*' "$file")
	port=$(grep -oP '(?<=:)[0-9]*' "$file")

	# Create the postup file
	## Sha-bang to the shell
	printf '#!/bin/sh\n' > "$postup_file" || exit 1
	## Create the proper variables for the postup file
	## to reference
	printf 'VPN_SERVER=%s\nPORT=%s\n' \
		   "$address" "$port" \
		   >> "$postup_file" || exit 1
	## Add the base postup file to the postup file
	cat "$base_postup_file" >> "$postup_file" || exit 1

	## Make sure the file is executable
	chmod +x "$postup_file" || exit 1

	# Make the wg<#>.conf file run the postup file at connection
	# and postdown at disconnection.
	## Create postup and postdown lines for the config
	## file (e.g /etc/wireguard/wg0.conf)
	postup_line="Postup = $postup_file" 
	postdown_line="Postdown = $postdown_file"

	## If the postup or postdown lines are not in the config
	## file, add them.
	if ! grep -q "$postup_line" "$file"; then
		## Add the postup line after the [Interface] line
		sed -i "/\[Interface\]/a $postup_line" "$file" || exit 1
	fi
	if ! grep -q "$postdown_line" "$file"; then
		## Add the postdown line after the [Interface] line
		sed -i "/\[Interface\]/a $postdown_line" "$file" || exit 1
	fi
done
