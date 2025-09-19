#!/bin/bash

# Check if YouTube Music window already exists
YT_WINDOW=$(hyprctl clients -j | jq -r '.[] | select(.title | test("YouTube Music")) | .address' 2>/dev/null | head -1)

if [ ! -z "$YT_WINDOW" ]; then
    # If window exists, focus it
    hyprctl dispatch focuswindow address:$YT_WINDOW
else
    # Open YouTube Music
    chromium --app="https://music.youtube.com" --window-size=400,600 &

    # Wait for window to load
    for i in {1..10}; do
        sleep 0.3
        NEW_WINDOW=$(hyprctl clients -j | jq -r '.[] | select(.title | test("YouTube Music")) | .address' 2>/dev/null | tail -1)
        if [ ! -z "$NEW_WINDOW" ]; then
            # Immediately float and position it
            hyprctl --batch "dispatch togglefloating address:$NEW_WINDOW; dispatch resizewindowpixel exact 400 600,address:$NEW_WINDOW; dispatch movewindowpixel 840 40,address:$NEW_WINDOW; dispatch pin address:$NEW_WINDOW"
            break
        fi
    done
fi