#!/bin/bash

# Get the current mode
current_mode=$(makoctl mode)

# Output status for Waybar
if makoctl mode | grep -q "dnd"; then
    echo $'\xef\x87\xb6'
else
    echo $'\xef\x83\xb3'
fi
