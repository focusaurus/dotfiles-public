alias sysur='systemctl --user daemon-reload'
sysu() {
  systemctl --user "$@"
}
