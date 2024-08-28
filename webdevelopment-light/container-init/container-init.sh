#!/bin/bash

cleanup() {
    echo "Exiting..."
    exit 0
}

# Execute scripts in /etc/container-init/
if [ -d "/etc/container-init" ]; then
    for script in /etc/container-init/*; do
        if [ -x "$script" ]; then
            "$script" || echo "Error running $script"
        fi
    done
fi

# Execute scripts in /etc/container-init.d/
if [ -d "/etc/container-init.d" ]; then
    for script in /etc/container-init.d/*; do
        if [ -x "$script" ]; then
            "$script" || echo "Error running $script"
        fi
    done
fi

# Trap signals and call the cleanup function
trap cleanup SIGINT SIGTERM

# Infinite loop with a 1-second sleep interval for responsiveness
while true; do
    sleep 60
done
