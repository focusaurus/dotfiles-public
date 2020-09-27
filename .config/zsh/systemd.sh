alias sysu-reload='systemctl --user daemon-reload'
alias sysu-log='journalctl --user --follow --unit'
sysu() {
  systemctl --user "$@"
}
