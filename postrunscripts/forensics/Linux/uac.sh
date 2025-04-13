#!/bin/bash

COAL=$(find / -type d -name 'COAL' -exec bash -c 'for dir; do if [ -d "$dir/coordinate-root" ] && [ -f "$dir/coordinate-root/config.json" ]; then echo "$dir"; fi; done' bash {} +)
COORD="$COAL/coordinate-root/coordinate"
CONFIG="$COAL/coordinate-root/config.json"
SCRIPT="$COAL/postrunscripts/forensics/Linux/collector.sh"

# Parse each entry and run the binary in the background
jq -c '.[]' "$CONFIG" | while read -r entry; do
  IP=$(echo "$entry" | jq -r '.IP')
  USER=$(echo "$entry" | jq -r '.Username')
  PASS=$(echo "$entry" | jq -r '.Password')
  echo "Launching: ./coordinate -t $IP -u $USER -p $PASS $SCRIPT"
  "$COORD" -t "$IP" -u "$USER" -p "$PASS" "$SCRIPT" &
done

# wait for all background process to finish
wait

