#!/bin/bash

echo "=== Fixing Schiit Modi on Thunderbolt Hub ==="

# Reload USB audio modules
echo "Reloading USB audio drivers..."
sudo modprobe -r snd_usb_audio
sleep 1
sudo modprobe snd_usb_audio

# Find the Modi device
MODI_DEVICE=$(lsusb | grep "0d8c:0066" | head -n1 | awk '{print $2":"$4}' | sed 's/:/\//' | sed 's/://')

if [ -z "$MODI_DEVICE" ]; then
    echo "Modi not found in lsusb. Trying to reset all USB hubs..."
    # Reset all hubs as fallback
    for hub in /sys/bus/usb/drivers/hub/*:*; do
        if [ -e "$hub" ]; then
            hub_id=$(basename "$hub")
            echo "Resetting hub: $hub_id"
            echo "$hub_id" | sudo tee /sys/bus/usb/drivers/hub/unbind > /dev/null 2>&1
            sleep 0.5
            echo "$hub_id" | sudo tee /sys/bus/usb/drivers/hub/bind > /dev/null 2>&1
        fi
    done
else
    echo "Found Modi at: $MODI_DEVICE"

    # Find the parent hub by traversing up the device tree
    DEVICE_PATH="/sys/bus/usb/devices/$MODI_DEVICE"

    # Go up to find parent hub
    CURRENT_PATH="$DEVICE_PATH"
    while [ "$CURRENT_PATH" != "/sys/bus/usb/devices" ]; do
        CURRENT_PATH=$(dirname "$CURRENT_PATH")
        DEVICE_NAME=$(basename "$CURRENT_PATH")

        # Check if this device is a hub
        if [ -d "$CURRENT_PATH" ] && [ -e "$CURRENT_PATH/bDeviceClass" ]; then
            DEVICE_CLASS=$(cat "$CURRENT_PATH/bDeviceClass" 2>/dev/null)
            # Class 09 is USB Hub
            if [ "$DEVICE_CLASS" = "09" ]; then
                # Find the hub interface
                for interface in "$CURRENT_PATH"/*:*; do
                    if [ -e "$interface" ]; then
                        HUB_INTERFACE=$(basename "$interface")
                        echo "Found parent hub interface: $HUB_INTERFACE"
                        echo "Resetting hub..."
                        echo "$HUB_INTERFACE" | sudo tee /sys/bus/usb/drivers/hub/unbind > /dev/null
                        sleep 1
                        echo "$HUB_INTERFACE" | sudo tee /sys/bus/usb/drivers/hub/bind > /dev/null
                        break 2
                    fi
                done
            fi
        fi
    done
fi

sleep 2
echo ""
echo "Done! Checking if Modi is detected..."
lsusb | grep -i "modi\|0d8c"
