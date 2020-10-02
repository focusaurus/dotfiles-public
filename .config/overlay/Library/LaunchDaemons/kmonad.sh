#!/usr/bin/env bash

# Please Use Google Shell Style: https://google.github.io/styleguide/shell.xml

# ---- Start unofficial bash strict mode boilerplate
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -o errexit  # always exit on error
set -o errtrace # trap errors in functions as well
set -o pipefail # don't ignore exit codes when piping output
set -o posix    # more strict failures in subshells
# set -x          # enable debugging

IFS=$'
	'
# ---- End unofficial bash strict mode boilerplate

cd "$(dirname "${BASH_SOURCE[0]}")"
/sbin/kextload "/Library/Application Support/org.pqrs/Karabiner-VirtualHIDDevice/Extensions/org.pqrs.driver.Karabiner.VirtualHIDDevice.v061000.kext"
exec /usr/local/bin/kmonad macbook.kbd

