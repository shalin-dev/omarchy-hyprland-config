#!/bin/bash

APP="$1"

case "$APP" in
    "gmail")
        URL="https://mail.google.com"
        CLASS="webapp-gmail"
        TITLE="Gmail"
        ;;
    "youtube-music")
        URL="https://music.youtube.com"
        CLASS="webapp-ytmusic"
        TITLE="YouTube Music"
        ;;
    "calendar")
        URL="https://calendar.google.com"
        CLASS="webapp-calendar"
        TITLE="Calendar"
        ;;
    *)
        exit 1
        ;;
esac

# Check if window exists by class
WINDOW=$(hyprctl clients -j | jq -r --arg class "$CLASS" '.[] | select(.class == $class) | .address' | head -1)

# If not found by class, try by title
if [ -z "$WINDOW" ]; then
    WINDOW=$(hyprctl clients -j | jq -r --arg title "$TITLE" '.[] | select(.title | contains($title)) | .address' | head -1)
fi

if [ ! -z "$WINDOW" ]; then
    # Window exists - check if it's in a special workspace
    WORKSPACE=$(hyprctl clients -j | jq -r --arg addr "$WINDOW" '.[] | select(.address == $addr) | .workspace.name')

    if [[ "$WORKSPACE" == special:* ]]; then
        # It's minimized - bring it back to current workspace
        hyprctl dispatch movetoworkspace "e+0,address:$WINDOW"
        hyprctl dispatch focuswindow "address:$WINDOW"
    else
        # It's visible - minimize to special workspace
        hyprctl dispatch movetoworkspacesilent "special:$APP,address:$WINDOW"
    fi
else
    # Open new window (it will tile normally)
    chromium --class="$CLASS" --app="$URL" --new-window &
fi