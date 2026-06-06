#!/bin/bash

# Get the current mode
current_mode=$(makoctl mode)

# Output status for Waybar
if makoctl mode | grep -q "dnd"; then
    echo ""
else
    echo ""
fi

