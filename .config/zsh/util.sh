########## General utility stuff ##########
alias @bug="rg @bug"
alias cx="chmod +x"
alias edq='echo $?'
# shellcheck disable=SC2142
alias -g /ap1="| awk '{print \$1}'"
# shellcheck disable=SC2142
alias -g /ap2="| awk '{print \$2}'"
# shellcheck disable=SC2142
alias -g /ap3="| awk '{print \$3}'"
# shellcheck disable=SC2142
alias -g /ap4="| awk '{print \$4}'"
# shellcheck disable=SC2142
alias -g /ap5="| awk '{print \$5}'"
alias -g /x="| xargs"
syncthing-gui() {
  ssh_command=(ssh -L 8333:127.0.0.1:8384 zooz.peterlyons.com)
  echo "Manage local at http://localhost:8334"
  echo "Access zooz gui with ${ssh_command[*]}"
  echo "Then open http://localhost:8337"
  echo -n "Run ssh for you now? y/n"
  read -r -q response
  echo
  if [[ "${response}" == "y" ]]; then
    "${ssh_command[@]}"
  fi
}

mvoff() {
  mv "$1" "${1}.OFF"
}

ap1() {
  awk '{print $1}'
}
ap2() {
  awk '{print $2}'
}
ap3() {
  awk '{print $3}'
}
ap4() {
  awk '{print $4}'
}

sigusr1() {
  killall --user "$(id -u -n)" --signal USR1 "$@"
}

copy-dir-name() {
  dir=$(basename "${PWD}")
  echo -n "${dir}" | ~/bin/copy
  echo "✓ ${dir}"
}

# The unix utility /bin/paste gets in my namespace. Get out!
alias copy=~/bin/copy
alias paste=~/bin/paste

copy-recent-command() {
  fzf_args=(--no-sort --tac)
  if [[ -n "$*" ]]; then
    fzf_args+=(--query "$@")
  fi
  command=$(fc -l -50 -1 | awk '{$1=""; print $0}' | fzf "${fzf_args[@]}")
  if [[ -n "${command}" ]]; then
    echo "${command}" | tr -d "\n" | ~/bin/copy
    echo "copied!"
  fi
}

alias cal="cal -3m"
alias cdrom="mount /dev/cdrom"
alias cls="clear;ls"
alias l1="ls -1"
alias l="ls"
alias la="ls -a"
# alias x="eza -1 --all --group-directories-first --classify --git"
# alias xl="eza --all --long --group-directories-first --classify --git"
# alias xt="eza --tree --color=always | less --RAW-CONTROL-CHARS"
# alias xt="lla --tree"
xt() {
  eza --tree --color=always "$@" | less --RAW-CONTROL-CHARS
}
alias les="/usr/bin/less --ignore-case"
alias less="/usr/bin/less --ignore-case --quit-at-eof"
# This conflicts with lf terminal file navigation program
# alias lf="/usr/bin/less --ignore-case +F"
alias ll="ls -lh"
# alias lla="ls -alh"
alias lsl="ls|less"
alias md="mkdir -p"
alias ppf="pretty-print-files"
alias show-dns-servers="nmcli dev show |grep DNS"
# Useful when you know you are going to copy/paste
# some stuff to a journal or blog
alias noprompt="PS1=;RPROMPT="
ns() {
  case $(uname) in
  Linux)
    sudo ss -ntlHp | awk '{print $4, $6}' | sort
    ;;
  Darwin)
    netstat -an -f inet -p tcp | grep LISTEN | awk '{print $4}' | sort
    ;;
  esac
}

paste-fuzz() {
  choice=$(gpaste-client history | grep -E '^[0-9]+:' | fuzzy-filter "$@")
  [[ -z "${choice}" ]] && return
  number=$(echo "${choice}" | cut -d : -f 1)
  gpaste-client select "${number}"
}

alias nums="alias | grep '^[0-9]'"
alias rd="rmdir"
alias timestamp='date +%Y%m%d-%H%M%S'
alias ucdrom="umount /dev/cdrom"
alias veh="sudoedit  /etc/hosts"
alias myip="curl http://myip.dnsomatic.com;echo"
TAILER="/usr/bin/less"
if [[ -x "${TAILER}" ]]; then
  TAILER="${TAILER} -i +F"
else
  TAILER="tail -f"
fi

char-count() {
  echo -n "$@" | wc -c
}

dirs() {
  for DIR in "${@}"; do
    [ -d "${DIR}" ] || mkdir -p "${DIR}"
  done
}

serve-dir() {
  devd --open .
  # python2 -m SimpleHTTPServer "$@"
}

tstmp() {
  local DIR
  DIR="/tmp/$(timestamp)"
  mkdir -p "${DIR}/node_modules"
  cd "${DIR}" || return 1
}

scratch-daily() {
  scratch="${HOME}/scratch/$(date +%Y/%m-%d)"
  mkdir -p "${scratch}"
  cd "${scratch}" || return 1
}

whos-listening() {
  local port
  if [[ -n "$1" ]]; then
    port=":$1"
  fi
  lsof -n -P -i "TCP${port}" -i "UDP${port}" -s TCP:LISTEN
}

kill-listener() {
  local pid
  pid=$(whos-listening "$1" | tail -1 | awk '{print $2}')
  if [[ -z "${pid}" ]]; then
    echo "No process listening on $1"
    return
  fi
  whos-listening "$1"
  echo -n "ENTER to kill process ${pid} to free port $1. CTRL-c to abort."
  # shellcheck disable=SC2034
  read -r confirm
  kill "${pid}"
}

##### dotfiles read replication take 3 #####
if [ -e ~/.mirror_dotfiles ]; then
  ~/projects/dotfiles/bin/self-update &>/dev/null &
fi
alias mirror-dotfiles="touch ~/.mirror_dotfiles"

##### curl #####
alias hget="noglob curl -s -v"
hpost() {
  local body="$1"
  shift
  noglob curl -s -v -X post "@${body}" "$@"
}

##### httpie #####
alias ht="noglob http --timeout 600"

watch-movie() {
  find ~/Downloads -maxdepth 3 -type "f" -size +100M -not -iname '*.iso' | grep -v '\.zip$' | sort -n | {
    while IFS= read -r file_path; do
      echo -n "Watch $(basename "${file_path}")? y/n"
      read -r -q response
      echo
      if [[ "${response}" == "y" ]]; then
        open "${file_path}"

        echo -n "Mark $(basename "${file_path}") watched? y/n"
        read -r -q response
        echo
        if [[ "${response}" == "y" ]]; then
          watched="${HOME}/Downloads/watched"
          mkdir -p "${watched}"
          mv "${file_path}" "${watched}"
          return
        fi
      fi
    done
  }
}

hey() {
  local file_path="$1"
  if [[ -d "${file_path}" ]]; then
    ls -l "${file_path}"
    return
  fi
  less "${file_path}"
}

hex-to-dec() {
  echo $((16#$1))
}

dec-to-hex() {
  printf "%02x\n" "$1"
}

hex-to-ascii() {
  echo "$1" | xxd -p -r
}

# https://lobste.rs/s/vyfhpm/bash_aliases_are_great_so_is_dired
export RIPGREP_CONFIG_PATH=~/.ripgreprc

tar-year() {
  tar -t --verbose -f "${1}" | awk '{print $4}' | cut -d - -f 1 | sort | uniq | tail -1
}

comcast_file="/tmp/comcast-is-up.txt"
# Run this from a system at home
comcast-is-down() {
  while true; do
    ssh -o ConnectTimeout=5 zooz.peterlyons.com bash -c "date > ${comcast_file}"
    sleep 30
  done
}

# Run this from your alternative location that has working Internet
is-comcast-still-down() {
  watch --interval 30 ssh zooz.peterlyons.com tail -1 "${comcast_file}"
}
alias paste-stupid-unix=/usr/bin/paste
sort-file() {
  target="$1"
  temp=$(mktemp "$1.temp.XXX")
  sort "${target}" >"${temp}"
  mv "${temp}" "${target}"
}

# Usage: snake-search SOME_VAR
# Will do case-insensitive search for SOME_VAR case and someVar case
# Searches all files in the git repo plus `.env` if it's present
snake-search() {
  # shellcheck disable=SC2001
  snake_var=$(echo "$1" | sed -e 's/_/_?/g')
  (
    if [[ -f ".env" ]]; then
      echo .env
    fi
    git ls-files
  ) | xargs grep -Ei "${snake_var}"
}

alias rgyaml="rg --glob '*.y*ml'"

br_source="${HOME}/.config/broot/launcher/bash/br"
if [[ -f "${br_source}" ]]; then
  # shellcheck disable=SC1090
  source "${br_source}"
fi

md-clipboard-to-pdf() {
  local outdir="${1-/tmp/$(timestamp)}"
  mkdir -p "${outdir}"
  ~/bin/paste | ~/projects/md-to-pdf/bin/md-to-pdf.js >"${outdir}/doc.pdf"
  echo "!$"
  open "!$"
}

change-time-zone-fuzzy() {
  zone=$(timedatectl list-timezones | ~/bin/fuzzy-filter "$@")
  [[ -z "${zone}" ]] && return
  sudo timedatectl set-timezone "${zone}"
  echo Run this in interactive shells to update without exiting:
  echo export TZ="${zone}"
}

change-time-zone-by-ip() {
  sudo timedatectl set-timezone "$(curl --fail https://ipapi.co/timezone)"
}

fz-ranger() {
  ranger "$(fasd -dl "$@")"
}

alias psg="ps -ef | grep"
