#!/usr/bin/env bash
########## Add in the Work specific stuff ##########
# shellcheck disable=SC2043
shell_setup="${HOME}/work-reaction/common/shell-setup.sh"
if [[ -s "${shell_setup}" ]]; then
  # shellcheck disable=SC1090
  source "${shell_setup}"
fi
