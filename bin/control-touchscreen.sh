#!/usr/bin/env sh
# control-touchscreen.sh - script to control touchscreen device in Linux
# Copyright (C) 2024 Peter Willis
# 
# This script is designed to try to detect a Touchscreen device in Linux.
# If it detects one, it allows you to bind or unbind it to the HID Generic
# driver, which should enable or disable the touchscreen.
# Works on Wayland, should work on X11 as well (but untested).
#
# SOFTWARE LICENSE:
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License along
#    with this program; if not, see <https://www.gnu.org/licenses/>.

set -eu
[ "${DEBUG:-0}" = "1" ] && set -x

# Uncomment to hard-code your touchscreen device if it isn't detected
# TOUCHSCREEN_DEVICE="0018:056A:52E8.0004"
TOUCHSCREEN_DEVICE="003:2A94:464D.0003"

# Uncomment to set the default driver so 'enable' works without having to pass an extra option
TOUCHSCREEN_DRIVER="${TOUCHSCREEN_DRIVER:-hid-multitouch}"

_log () { printf "%s: %s\n" "$(basename "$0")" "$*" 1>&2 ; } 
_die () { _log "$*" ; exit 1 ; }

_cmd_detect_line () {
    msg="$1"
    if [ -n "$msg" ] ; then
        make="$(echo "$msg" | awk '{print $1}')"
        id="$(echo "$msg" | awk '{print $2}')"
        device_id="$(echo "$msg" | sed -E 's/^.*Touchscreen as // ; s/\//\n/g' | grep -F "$id")"
        _log "Possible touchscreen: Make '$make' id '$id' device_id '$device_id'"
        if [ -e "/sys/bus/hid/devices/$device_id" ] ; then
            _log "Detected Touchscreen HID device: '$device_id'"
            TOUCHSCREEN_DEVICE="$device_id"
        fi
    fi
}

_cmd_detect_logs () {
    return
    # Look at both dmesg and syslog. Syslog last because it should have the latest messages.
    # (on my system, my touchscreen device id changed!)
    cat /var/log/dmesg /var/log/syslog | grep 'Touchscreen as' | tail -1 | sed -E 's/^.*kernel: input: //'
}

_cmd_detect_proc () {
    both="$(grep '^[NS]:' /proc/bus/input/devices | grep 'Touch' -A1)"
    name="$(echo "$both" | grep '^N:' | sed -E 's/^N: Name=\"(.+)\"$/\1/')"
    sysfs="$(echo "$both" | grep '^S:' | sed -E 's/^S: Sysfs=(.+)$/\1/')"
    [ -n "$name" -a -n "$sysfs" ] || return 1
    echo "$name as $sysfs"
}

_cmd_detect_device () {
    for driverdir in /sys/bus/hid/drivers/* ; do
        [ -d "$driverdir" ] || continue
        if [ -e "$driverdir/$TOUCHSCREEN_DEVICE" ] ; then
            driver="$(basename "$driverdir")"
            _log "Detected touchscreen driver '$driver'"
            TOUCHSCREEN_DRIVER="$driver"
            break
        fi
    done

}

_cmd_detect () {
    if [ -z "${TOUCHSCREEN_DEVICE:-}" ] ; then
        # Try to detect the device id from either /proc/bus or system logs
        line="$(_cmd_detect_proc || _cmd_detect_logs)"
        _cmd_detect_line "$line"
    fi

    if [ -n "${TOUCHSCREEN_DEVICE:-}" ] && [ -z "${TOUCHSCREEN_DRIVER:-}" ] ; then
        _cmd_detect_device
    fi
}

_checkvars () {
    [ -n "${1:-}" ] || _die "Could not detect device id; please pass -d option"
    [ -n "${2:-}" ] || _die "Could not detect driver name; please pass -D option (currently loaded HID drivers: $(ls /sys/bus/hid/drivers/ 2>/dev/null))"
}
_checkdriver () {
    if [ ! -d "/sys/bus/hid/drivers/$1" ] ; then
        _die "Error: no such HID driver '$1' found"
    fi
}

_cmd_disable () {
    device="${1:-$TOUCHSCREEN_DEVICE}" driver="${2:-$TOUCHSCREEN_DRIVER}"
    _checkvars "$device" "$driver"
    _log "Disabling touchscreen device '$device' with driver '$driver' ..."
    _checkdriver "$driver"
    sudo sh -c "printf \"%s\n\" \"$device\" > /sys/bus/hid/drivers/$driver/unbind"
}

_cmd_enable () {
    device="${1:-${TOUCHSCREEN_DEVICE:-}}" driver="${2:-${TOUCHSCREEN_DRIVER:-}}"
    _checkvars "$device" "$driver"
    _log "Enabling touchscreen device '$device' with driver '$driver' ..."
    _checkdriver "$driver"
    sudo sh -c "printf \"%s\n\" \"$device\" > /sys/bus/hid/drivers/$driver/bind"
}

if [ $# -lt 1 ] ; then
    cat <<EOF
Usage: $0 [OPTIONS] COMMAND [ARGS ..]

Disables or enables a touchscreen, by binding or unbinding a device ID from a driver.
Attempts to detect the device ID automatically, but allows you to pass it manually.

If you disable the device (unbind it from the driver), this script will not be able
to detect the proper driver to re-bind it to, so you will need to pass the driver,
or edit this script to use the correct driver by default.

Default driver is '${TOUCHSCREEN_DRIVER:-}'.

Options:
    -d DEVICE        Device ID of the Touchscreen
    -D DRIVER        Driver to bind/unbind the device to

Commands:
    enable            Enable the touchscreen/bind to driver
    disable            Disable the touchscreen/unbind to driver
    detect            Just try to detect the touchscreen

If you specify DEVICE, it must be the device ID name, like '0018:056A:52E8.0004'.
If you specify DRIVER, it must be the name of the driver to bind/unbind the device
from.
EOF
    exit 1
fi

while getopts "d:D:" arg ; do
    case "$arg" in
        d)    TOUCHSCREEN_DEVICE="$OPTARG" ;;
        D)    TOUCHSCREEN_DRIVER="$OPTARG" ;;
        *)    _log "Error: unknown arg '$arg'" ; exit 1 ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${TOUCHSCREEN_DEVICE:-}" ] ; then
    _cmd_detect
fi

cmd="$1"; shift
_cmd_"$cmd" "$@"
