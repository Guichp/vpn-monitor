#!/bin/bash

# This script is used to fix the VPN connection by restarting the VPN container with wireguard easy.
# It is intended to be run as a cron job.

# Load environment variables from .env file
echo "$(dirname "$0")"
cd "$(dirname "$0")" # Change to the directory where the script is located to get the correct path to .env
source .env
# this has loaded the TOKEN and CHAT_ID variables for the telegram bot
# also the VPN_DIR variable which is the directory where the docker-compose.yml file is located

# Verify environment variables
if [ -z "$TOKEN" ] || [ -z "$CHAT_ID" ] || [ -z "$VPN_DIR" ]; then
    echo "Error: Required environment variables not set."
    exit 1
fi

# Check if the public IP has changed checking the file public_ip.txt
if [ -f "$VPN_DIR/public_ip.txt" ]; then
  OLD_IP=$(cat "$VPN_DIR/public_ip.txt")
else
  echo "No previous public IP found. Creating public_ip.txt with current IP."
  OLD_IP=$(curl -s https://api.ipify.org)
  echo "$OLD_IP" > "$VPN_DIR/public_ip.txt"
fi

if ! CURRENT_IP=$(curl -s --max-time 10 https://api.ipify.org); then
    echo "Error: Failed to get current IP address."
    exit 1
fi

if [ "$CURRENT_IP" != "$OLD_IP" ]; then
  echo "Public IP has changed from $OLD_IP to $CURRENT_IP."
  echo "$CURRENT_IP" > "$VPN_DIR/public_ip.txt"

  

  # Update Docker Compose file with new IP
  sed -i "s/WG_HOST=.*/WG_HOST=$CURRENT_IP/" "$VPN_DIR/compose.yml"

  # Restart the container
  cd $VPN_DIR
  docker compose down
  docker compose up --build -d

  MESSAGE="Public IP has changed from $OLD_IP to $CURRENT_IP. VPN connection restarted."

  curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
    -d chat_id="$CHAT_ID" \
    -d text="$MESSAGE"

else
  echo "Public IP has not changed. Current IP is still $OLD_IP."
  exit 0
fi

