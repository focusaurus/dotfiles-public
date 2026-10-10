export GOBIN=~/go/bin
alias gmvt="go mod vendor && go mod tidy"

##### gvm (Go version manager) #####
# placeholder gvm shell function, same lazy-load pattern as nvm() in node.sh.
# On first use it sources the real gvm setup (which defines the real `gvm`
# function, overrides `cd` for .go-version auto-switching, etc.) and then
# replays the call. This avoids paying gvm's startup cost (mkdirs, reading
# VERSION, munging PATH) on every shell when `gvm` itself is rarely invoked.
gvm() {
  if [[ -s "${HOME}/.gvm/scripts/gvm" ]]; then
    # shellcheck disable=SC1091
    source "${HOME}/.gvm/scripts/gvm"
    gvm "$@"
    return
  fi
  echo "gvm is not installed" >&2
}
