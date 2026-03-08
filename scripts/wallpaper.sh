#!/bin/bash

# 1. Initialize swww if not already running
swww query || swww init

# 2. Path to your JJK folder
DIR="$HOME/.dotfiles/wallpapers/you-are-my-special"

# 3. The Loop
while true; do
    # Find random image (ignoring the .zip file)
    PIC=$(find "$DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.webp" -o -name "*.jpeg" \) | shuf -n 1)

    if [ -n "$PIC" ]; then
        # Using 'outer' transition for a cool expansion effect, or 'wipe'
        swww img "$PIC" --transition-type wipe --transition-step 90 --transition-fps 60
    fi
    
    # Wait 10 minutes
    sleep 600
done
