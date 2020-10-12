#!/usr/bin/env bash

# Please Use Google Shell Style: https://google.github.io/styleguide/shell.xml

# ---- Start unofficial bash strict mode boilerplate
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -o errexit  # always exit on error
set -o errtrace # trap errors in functions as well
set -o pipefail # don't ignore exit codes when piping output
set -o posix    # more strict failures in subshells
# set -x          # enable debugging

IFS=$'\n\t'
# ---- End unofficial bash strict mode boilerplate

cd "$(dirname "${BASH_SOURCE[0]}")"

defcfg_thinkpad='
input  (device-file "/dev/input/by-path/platform-i8042-serio-0-event-kbd")
  output (uinput-sink "kmonad-thinkpad")
'

defcfg_ergodox_linux='
input  (device-file "/dev/input/by-id/usb-ErgoDox_EZ_ErgoDox_EZ_0-event-kbd")
  output (uinput-sink "kmonad-ergodox")
'

defcfg_macbook='
input (iokit-name "Apple Internal Keyboard / Trackpad")
  output (kext)
'

defcfg_ergodox_macos='
input (iokit-name "Infinity_Ergodox/QMK")
  output (kext)
'

modifiers='
caps @tap-escape-hold-control
lsft @tap-snippet-hold-shift
rsft @tap-snippet-hold-shift
lctl @tap-escape-hold-control
rctl @tap-escape-hold-control
lmet @tap-fuzzball-hold-super
rmet @tap-fuzzball-hold-super
ssrq @tap-fuzzball-hold-super
spc @tap-space-hold-navigation XX
'

letters_macos='
a @tap-a-hold-hyper
; @tap-semi-hold-hyper
'

letters_linux="
- [
= ]
q '
w , bspc
e . spc
r p del
t y
y f
u g
i c
o r
p l
[ /
] =
\\ \\

a @tap-a-hold-hyper
s o lft
d e up
f u rght
g i
h d
j h
k t
l n
; @tap-s-hold-hyper
' -

z ;
x q home
c j down
v k end
b x
n b
m m
, w
. v
/ z
"

# NAME=ergodox \
#   DEVICE='/dev/input/by-id/usb-ErgoDox_EZ_ErgoDox_EZ_0-event-kbd' \
#   envsubst < main.kbd.tpl > "${NAME}.kbd"
# NAME=thinkpad \
#   DEVICE='/dev/input/by-path/platform-i8042-serio-0-event-kbd' \
#   envsubst < main.kbd.tpl > "${NAME}.kbd"

for name in thinkpad macbook ergodox-linux ergodox-macos; do
  case "${name}" in
  thinkpad)
    defcfg="${defcfg_thinkpad}"
    letters="${letters_linux}"
    ;;
  ergodox-linux)
    defcfg="${defcfg_ergodox_linux}"
    letters="${letters_linux}"
    ;;
  macbook)
    defcfg="${defcfg_macbook}"
    letters="${letters_macos}"
    ;;
  ergodox-macos)
    defcfg="${defcfg_ergodox_macos}"
    letters="${letters_macos}"
    ;;
  esac

  echo -n >"${name}.kbd"

  (
    echo ";; DO NOT EDIT THIS FILE!
;; Edit $0 instead
(defcfg"
    echo "  ${defcfg}"
    echo "  fallthrough true
  allow-cmd false
)

(defalias
  hyper (around lctl lmet)
  tap-space-hold-shift (tap-hold-next-release 500 spc lsft)
  tap-space-hold-navigation (tap-hold-next-release 500 spc (layer-toggle navigation))
  tap-a-hold-hyper (tap-hold-next-release 500 a @hyper)
  tap-s-hold-hyper (tap-hold-next-release 500 s @hyper)
  tap-semi-hold-hyper (tap-hold-next-release 500 ; @hyper)
  tap-escape-hold-control (tap-hold-next-release 150 esc lctl)
  tap-snippet-hold-shift (tap-hold-next-release 150 C-2 lsft)
  tap-fuzzball-hold-super (tap-hold-next-release 150 M-spc lmet)

)

(defsrc"

    echo -e "${modifiers}${letters}" | {
      while IFS= read -r mapping; do
        echo "${mapping}" | awk '{print "  " $1}'
      done
    }
    echo ")

(deflayer base"

    echo "${modifiers}${letters}" | {
      while IFS= read -r mapping; do
        echo -n "${mapping}" | awk '{print "  " $2 " ;; " $1}'
      done
    }
    echo ")

(deflayer navigation"

    echo "${modifiers}${letters}" | {
      while IFS= read -r mapping; do
        echo -n "${mapping}" | awk '{print "  " ($3==""?"_":$3) " ;; " $1}'
      done
    }
    echo ")"
    ) >>"${name}.kbd"
done
