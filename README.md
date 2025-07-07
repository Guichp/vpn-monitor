# WireGuard VPN IP Monitor

A Bash script that monitors your public IP address and automatically updates your WireGuard VPN server when your IP changes. This is particularly useful for home servers with dynamic IP addresses.

## Overview

This script:

1. Tracks changes to your public IP address
2. Updates your Docker Compose configuration with the new IP
3. Restarts the WireGuard VPN container to apply changes
4. Sends a notification via Telegram when your IP changes

## Requirements

- Linux environment
- Bash shell
- Docker and Docker Compose
- `curl` command-line tool
- WireGuard VPN server running in Docker (using wg-easy or similar)
- Telegram bot (for notifications)

## Installation

1. Clone this repository:

   ```bash
   git clone https://github.com/yourusername/vpn-ip-monitor.git
   cd vpn-ip-monitor
   ```
2. Create a `.env` file with your configuration:

   ```bash
   cp .env.example .env
   ```
3. Edit the `.env` file with your specific values:

   ```bash
   # Telegram Bot credentials
   TOKEN=your_telegram_bot_token
   CHAT_ID=your_telegram_chat_id

   # VPN directory path
   VPN_DIR=/path/to/your/vpn/docker/directory
   ```

## Configuration

The script expects:
- A `.env` file in the same directory as the script
- Your Docker Compose file (`compose.yml`) to have an environment variable named `WG_HOST` that it will update
- Permission to create and update a `public_ip.txt` file in your VPN directory

Example Docker Compose file structure:

```yaml
services:
  wg-easy:
    image: weejewel/wg-easy
    environment:
      - WG_HOST=123.456.789.10
      - PASSWORD=yourpassword
    # ... other configuration ...
```
Look at the original [wg-easy repository](https://github.com/wg-easy/wg-easy) to set it up.

## Usage

### Manual Execution

Run the script manually:

```bash
bash fix_vpn.sh
```

### Automated Execution (Recommended)

Set up a cron job to run the script periodically:

1. Edit your crontab:

   ```bash
   crontab -e
   ```
2. Add a line to run the script every 15 minutes:

   ```
   */15 * * * * /path/to/fix_vpn.sh >> /var/log/vpn_ip_monitor.log 2>&1
   ```

## How It Works

1. The script reads the previously recorded public IP from `$VPN_DIR/public_ip.txt`
2. It fetches your current public IP from api.ipify.org
3. If the IP has changed:
   - It updates the saved IP in `$VPN_DIR/public_ip.txt`
   - Updates the `WG_HOST` value in your Docker Compose file
   - Restarts the Docker containers
   - Sends a notification via Telegram

## Troubleshooting

- **Script not detecting IP changes**: Check that `$VPN_DIR/public_ip.txt` exists and contains only your IP address
- **Telegram notifications not working**: Verify your Telegram bot token and chat ID in the `.env` file
- **Docker container not updating**: Ensure your compose file uses the variable name `WG_HOST=` exactly

## License

MIT License - See LICENSE file for details
