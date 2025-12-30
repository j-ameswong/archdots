#!/bin/bash

while true; do
    # 1. Check if we have internet (ping Google DNS)
    if ping -q -c 1 -W 1 8.8.8.8 >/dev/null; then
        
        # 2. Check if NordVPN is connected
        STATUS=$(nordvpn status | grep "Status" | awk '{print $2}')
        
        if [[ "$STATUS" == "Disconnected" ]]; then
            nordvpn connect
            # Notify user (optional, requires libnotify)
            notify-send "NordVPN" "Auto-connected to VPN"
        fi
    fi
    
    # Check every 10 seconds
    sleep 10
done
