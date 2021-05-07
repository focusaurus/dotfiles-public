alias qmkc="(cd ~/github.com/focusaurus/qmk_firmware && ./util/docker_build.sh ergodox_ez:focusaurus)"
alias qmkcf="qmkc && qmkf"
# busted at the moment due to C lib issues
# alias qmkf="qmk flash"
qmkf() {
  echo "Hold left thumb layer and hit the top left ESC key to reset the teensy"
  echo "Hit ENTER when ready to flash"
  # shellcheck disable=SC2034
  read -r _ignore
  teensy-loader-cli --mcu=atmega32u4 ~/github.com/focusaurus/qmk_firmware/.build/ergodox_ez_focusaurus.hex
}
alias cdqmk="cd ~/github.com/focusaurus/qmk_firmware/ergodox_ez"
