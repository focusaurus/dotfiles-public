export GOBIN=~/go/bin
alias gmvt="go mod vendor && go mod tidy"
##### gvm (go version manager) #####
# placeholder gvm shell function
# On first use, it will set gvm up properly which will replace the `gvm`
# shell function with the real one
gvm() {
  gvmsetup="${HOME}/.gvm/scripts/gvm"
  if [[ -f "${gvmsetup}" ]]; then
    # shellcheck disable=SC1090
    source "${gvmsetup}"
    gvm "$@"
    return
  fi
  echo "gvm is not installed" >&2
}
