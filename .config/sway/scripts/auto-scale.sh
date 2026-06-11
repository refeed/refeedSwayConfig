#!/bin/bash

set_edp_scale() {
    local external
    external=$(swaymsg -t get_outputs | jq -r '.[] | select(.name != "eDP-1" and .active == true) | .name' | head -1)
    if [ -n "$external" ]; then
        swaymsg output eDP-1 scale 1.5
    else
        swaymsg output eDP-1 scale 1.25
    fi
}

set_edp_scale

swaymsg -t subscribe '["output"]' | while IFS= read -r _; do
    set_edp_scale
done
