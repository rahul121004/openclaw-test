#!/bin/bash
# Gateway startup notification script
# Sends WhatsApp message once per gateway start/restart

STATE_FILE="$HOME/.openclaw/workspace/.gateway_startup_state"
MESSAGE="I m online and and working lets start the work"
PHONE="+919971353403"
NOW=$(date +%s)
THRESHOLD=300  # 5 minutes - if last notification was >5min ago, assume gateway restart

# Read last notification time
LAST_SENT=0
if [ -f "$STATE_FILE" ]; then
    LAST_SENT=$(cat "$STATE_FILE" 2>/dev/null || echo 0)
fi

# Calculate time since last notification
ELAPSED=$((NOW - LAST_SENT))

# If we sent a notification within the last 5 minutes, skip (gateway already running)
if [ "$ELAPSED" -lt "$THRESHOLD" ] && [ "$LAST_SENT" -gt 0 ]; then
    exit 0  # Already notified recently
fi

# Send the WhatsApp message
wacli send text --to "$PHONE" --message "$MESSAGE"

# Update state with current timestamp
echo "$NOW" > "$STATE_FILE"
