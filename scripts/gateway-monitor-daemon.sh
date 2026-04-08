#!/bin/bash
# Gateway Start/Stop Notification Monitor
# Runs in background, checks every 30 seconds

STATE_FILE="/home/deav/.openclaw/workspace/memory/gateway-state.json"
PHONE="919971353403"
CHECK_INTERVAL=30

mkdir -p "$(dirname "$STATE_FILE")"

# Initialize state
if [ ! -f "$STATE_FILE" ]; then
    echo '{"wasRunning": false}' > "$STATE_FILE"
fi

echo "🔍 Gateway monitor started (checking every ${CHECK_INTERVAL}s)..."

while true; do
    # Check current gateway status
    STATUS=$(openclaw gateway status 2>&1)
    IS_RUNNING=false
    
    if echo "$STATUS" | grep -q "Runtime: running"; then
        IS_RUNNING=true
    fi
    
    # Read previous state
    WAS_RUNNING=$(cat "$STATE_FILE" 2>/dev/null | grep -o '"wasRunning": [a-z]*' | cut -d' ' -f2 | tr -d ',' || echo "false")
    
    # Detect transition: was offline, now online
    if [ "$IS_RUNNING" = true ] && [ "$WAS_RUNNING" = "false" ]; then
        # Gateway just started!
        wacli send text --to "$PHONE" --message "🤖 I'm online sir! Gateway has started on port 18789." 2>/dev/null
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] ✓ Gateway came ONLINE - notification sent"
    elif [ "$IS_RUNNING" = false ] && [ "$WAS_RUNNING" = "true" ]; then
        # Gateway just went down
        wacli send text --to "$PHONE" --message "⚠️ Gateway went offline!" 2>/dev/null
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] ✗ Gateway went OFFLINE - notification sent"
    fi
    
    # Update state file
    echo "{\"wasRunning\": $IS_RUNNING}" > "$STATE_FILE"
    
    sleep $CHECK_INTERVAL
done
