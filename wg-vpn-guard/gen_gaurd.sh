#!/bin/bash
current_dir="$(cd "$(dirname "$0")" && pwd)"
base_postdown_file="$current_dir/all-postdown.sh"
base_postup_file="$current_dir/postup.frame"
postdown_file='/etc/wireguard/all-postdown.sh'

if [ ! -f "$base_postdown_file" ]; then
	echo "ERROR: $base_postdown_file not found"
	exit 1
fi
if [ ! -f "$base_postup_file" ]; then
	echo "ERROR: $base_postup_file not found"
	exit 1
fi

if [ ! -f "$postdown_file" ]; then
	echo "Creating $postdown_file"
	cp "$base_postdown_file" "$postdown_file" || exit 1
	chmod +x "$postdown_file" || exit 1
fi

for file in /etc/wireguard/wg*.conf; do
	postup_file="$file-postup.sh"

	if [ -f "$postup_file" ]; then
		echo "Replacing $postup_file"
		rm "$postup_file" || exit 1
	else 
		echo "Creating $postup_file"
	fi

	address=$(grep -oP '(?<=Endpoint = )[0-9.]*' "$file")
	port=$(grep -oP '(?<=:)[0-9]*' "$file")
	printf '#!/bin/sh\n' > "$postup_file" || exit 1
	printf 'VPN_SERVER=%s\nPORT=%s\n' \
		   "$address" "$port" \
		   >> "$postup_file" || exit 1
	cat "$base_postup_file" >> "$postup_file" || exit 1

	chmod +x "$postup_file" || exit 1

	postup_line="Postup = $postup_file" 
	postdown_line="Postdown = $postdown_file"
	if ! grep -q "$postup_line" "$file"; then
		sed -i "/\[Interface\]/a $postup_line" "$file" || exit 1
	fi
	if ! grep -q "$postdown_line" "$file"; then
		sed -i "/\[Interface\]/a $postdown_line" "$file" || exit 1
	fi
done
