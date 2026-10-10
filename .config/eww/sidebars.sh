#!/usr/bin/env bash

# Please Use Google Shell Style: https://google.github.io/styleguide/shell.xml

# ---- Start unofficial bash strict mode boilerplate
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -o errexit  # always exit on error
set -o errtrace # trap errors in functions as well
set -o pipefail # don't ignore exit codes when piping output
set -u          # error on reference to unknown variable
# set -x # enable debugging

IFS=$'\n\t'
# ---- End unofficial bash strict mode boilerplate

# Ensure exactly one sidebar window is open on each enabled niri output.
# Instances are named sidebar-<connector> (e.g. sidebar-DP-4). Safe to run
# repeatedly; it does nothing when the outputs haven't changed.
#
# eww 0.5 matches --screen against the GDK monitor model, which on wayland is
# the same as niri's "model" field (e.g. "DELL U2724DE"), not the connector.

# eww 0.5 clients start a brand new daemon (orphaning the old one and its
# windows) if the daemon is slow to answer, which happens during monitor
# changes. --no-daemonize makes them fail instead, and we retry.
eww() {
  command eww --no-daemonize "$@"
}

STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/eww-sidebars.state"
LOCK_FILE="${XDG_RUNTIME_DIR:-/tmp}/eww-sidebars.lock"

# Prints "connector<TAB>model" for each enabled output
enabled_outputs() {
  niri msg --json outputs |
    jq -r '.[] | select(.current_mode != null and .logical != null)
      | "\(.name)\t\(.model)"' |
    sort
}

open_sidebars() {
  local outputs="$1"
  local name model
  while IFS=$'\t' read -r name model; do
    eww open sidebar --id "sidebar-${name}" --screen "${model}" || return 1
  done <<<"${outputs}"
}

close_sidebars() {
  local id
  for id in $(eww active-windows 2>/dev/null | cut -d: -f1 | grep '^sidebar' || true); do
    eww close "${id}" || true
  done
}

all_open() {
  local outputs="$1"
  local active name
  active="$(eww active-windows | cut -d: -f1)" || return 1
  while IFS=$'\t' read -r name _; do
    grep -qx "sidebar-${name}" <<<"${active}" || return 1
  done <<<"${outputs}"
}

# The daemon may be starting up, or busy reacting to a monitor change
wait_for_daemon() {
  local i
  for i in $(seq 20); do
    eww ping >/dev/null 2>&1 && return 0
    sleep 0.5
  done
  echo "eww daemon not reachable" >&2
  return 1
}

main() {
  exec 9>"${LOCK_FILE}"
  flock 9

  local outputs
  outputs="$(enabled_outputs)"
  [[ -z "${outputs}" ]] && return 0
  wait_for_daemon || return 1

  if [[ "${outputs}" == "$(cat "${STATE_FILE}" 2>/dev/null)" ]] &&
    all_open "${outputs}"; then
    return 0
  fi

  echo "Outputs changed, reopening sidebars on: $(cut -f1 <<<"${outputs}" | tr '\n' ' ')"
  rm -f "${STATE_FILE}"
  # GDK can lag behind niri when a monitor appears, so retry briefly
  local attempt
  for attempt in 1 2 3 4 5 6; do
    close_sidebars
    if open_sidebars "${outputs}"; then
      echo "${outputs}" >"${STATE_FILE}"
      return 0
    fi
    sleep 1
  done
  echo "Failed to open sidebars after ${attempt} attempts" >&2
  return 1
}

main "$@"
