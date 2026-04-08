#!/bin/bash

# Gateway status check script
# Sends WhatsApp notification when gateway is online

export PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export HOME="/home/deav"

LOG_FILE="/home/deav/.openclaw/workspace/logs/gateway-check.log"
WHATSAPP_JID="919971353403@s.whatsapp.net"

# Log start time
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Script started" >> "$LOG_FILE"

# Check gateway status
GATEWAY_STATUS=$(/home/linuxbrew/.linuxbrew/bin/openclaw gateway status 2>&1)
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Gateway status: $GATEWAY_STATUS" >> "$LOG_FILE"

if echo "$GATEWAY_STATUS" | grep -q "running"; then
    # Gateway is running - send notification
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Gateway is running, sending message..." >> "$LOG_FILE"
    timeout 25 /home/linuxbrew/.linuxbrew/bin/wacli send text --to "$WHATSAPP_JID" --message "I'm online sir" >> "$LOG_FILE" 2>&1
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Message send completed" >> "$LOG_FILE"
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Gateway NOT running" >> "$LOG_FILE"
fi
