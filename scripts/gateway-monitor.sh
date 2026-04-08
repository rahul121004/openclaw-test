#!/bin/bash
# Gateway Start Notification Script
# Sends WhatsApp message when gateway comes online

STATE_FILE="/home/deav/.openclaw/workspace/memory/gateway-state.json"
PHONE="919971353403"

# Create state file if it doesn't exist
if [ ! -f "$STATE_FILE" ]; then
    echo '{"wasRunning": false}' > "$STATE_FILE"
fi

# Check current gateway status
STATUS=$(openclaw gateway status 2>&1)
IS_RUNNING=false

if echo "$STATUS" | grep -q "Runtime: running"; then
    IS_RUNNING=true
fi

# Read previous state
WAS_RUNNING=$(cat "$STATE_FILE" | grep -o '"wasRunning": [a-z]*' | cut -d' ' -f2 | tr -d ',')

# Detect transition: was offline, now online
if [ "$IS_RUNNING" = true ] && [ "$WAS_RUNNING" = "false" ]; then
    # Gateway just started!
    wacli send text --to "$PHONE" --message "🤖 I'm online sir! Gateway has started on port 18789."
    echo "Sent notification - gateway came online"
elif [ "$IS_RUNNING" = false ] && [ "$WAS_RUNNING" = "true" ]; then
    # Gateway just went down
    wacli send text --to "$PHONE" --message "⚠️ Gateway went offline!"
    echo "Sent notification - gateway went offline"
fi

# Update state file
echo "{\"wasRunning\": $IS_RUNNING}" > "$STATE_FILE"
