#!/bin/env bash

# 1. Determine Launcher (Defaults to Rofi if Walker isn't active)
launcher=$(cat $HOME/.config/ml4w/settings/launcher 2>/dev/null || echo "rofi")

# 2. Get VPN Status
ACTIVE_VPN=$(nmcli -t -f TYPE,NAME,STATE connection show --active | grep "^wireguard" | cut -d: -f2)

# 3. Menu Logic
if [[ "$1" == "menu" ]]; then
  # Get all Wireguard VPN names
  mapfile -t VPNS < <(nmcli -t -f TYPE,NAME connection show | grep "^wireguard" | cut -d: -f2)

  # Create the display list
  listNames=""
  if [ -n "$ACTIVE_VPN" ]; then
    listNames="󰅖 Disconnect: $ACTIVE_VPN\n"
  fi

  for vpn in "${VPNS[@]}"; do
    if [[ "$vpn" != "$ACTIVE_VPN" ]]; then
      listNames+="$vpn\n"
    fi
  done
  listNames=$(echo -e "$listNames" | sed '/^$/d')

  # 4. Show Menu
  if [ "$launcher" == "walker" ]; then
    choice=$(echo -e "$listNames" | $HOME/.config/walker/launch.sh -d -p "VPN Selector")
  else
    choice=$(echo -e "$listNames" | rofi -dmenu -replace -i \
      -config ~/.config/rofi/config-themes.rasi \
      -no-show-icons -p "VPN" \
      -theme-str '
                window { 
                    width: 300px; 
                    location: north east; 
                    anchor: north east; 
                    x-offset: -10px; 
                    y-offset: 50px; 
                }
                inputbar { enabled: false; }
                listview { lines: 6; }
                element-text { padding: 8px; }
            ')
  fi

  # 5. Connect/Disconnect Action
  if [ -n "$choice" ]; then
    if [[ "$choice" == *"Disconnect:"* ]]; then
      nmcli connection down "$ACTIVE_VPN"
    else
      [ -n "$ACTIVE_VPN" ] && nmcli connection down "$ACTIVE_VPN"
      nmcli connection up "$choice"
    fi
    # Instantly refresh Waybar icon
    pkill -RTMIN+8 waybar
  fi
  exit 0
fi

# 6. Waybar Output
if [ -n "$ACTIVE_VPN" ]; then
  echo "{\"text\": \" $ACTIVE_VPN\", \"class\": \"active\", \"tooltip\": \"Tunnel Active\"}"
else
  echo "{\"text\": \" Off\", \"class\": \"inactive\", \"tooltip\": \"Direct Connection\"}"
fi
