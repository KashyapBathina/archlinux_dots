#!/bin/bash
# A lightweight power menu leveraging Walker's native index output (-i)
choice=$(echo -e "󰐥 Shutdown\n󰜉 Reboot\n󰤄 Sleep\n󰗽 Logout" | $HOME/.config/walker/launch.sh -d -i -p "Power Menu")

case "$choice" in
0) systemctl poweroff ;;
1) systemctl reboot ;;
2) systemctl suspend ;;
3) niri msg action quit ;;
esac
