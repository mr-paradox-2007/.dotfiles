#!/usr/bin/env bash

# -n 2 reads 2 samples, -s 200 checks across a 0.2 second window
json_data=$(sudo intel_gpu_top -J -s 200 -n 2 2>/dev/null)

# Isolate the final sample and extract the active Render utilization integer
gpu_val=$(echo "$json_data" | awk '/"Render\/3D\/0":/ || /"Render":/ {print $2}' | tr -d ',\"' | tail -n 1 | cut -d. -f1)

# Ensure blank/null defaults are caught safely
if [[ -n "$gpu_val" && "$gpu_val" =~ ^[0-9]+$ ]]; then
    echo "  ${gpu_val}%"
else
    echo "  0%"
fi
