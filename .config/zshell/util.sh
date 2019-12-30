#!/usr/bin/env bash
########## General utility stuff ##########
alias @bug="rg @bug"
alias cx="chmod +x"
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
  killall --user $(id -u -n) --signal USR1 "$@"
}

copy-dir-name() {
  dir=$(basename "${PWD}")
  echo -n "${dir}" | copy
  echo "✓ ${dir}"
}

alias cal="cal -3m"
alias cdrom="mount /dev/cdrom"
alias cls="clear;ls"
alias l1="ls -1"
alias l="ls"
alias la="ls -a"
alias x="exa -1 --all --group-directories-first --classify --git"
alias xl="exa --all --long --group-directories-first --classify --git"
alias les="/usr/bin/less --ignore-case"
alias less="/usr/bin/less --ignore-case --quit-at-eof"
alias lf="/usr/bin/less --ignore-case +F"
alias ll="ls -l"
alias lla="ls -al"
alias lsl="ls|less"
alias md="mkdir -p"
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
alias veh="sudo vim /etc/hosts"
whatismyipaddress() {
  local ip
  ip=$(curl --silent --fail https://myip.dnsomatic.com/)
  echo -n "${ip}" | copy
  echo "${ip} (copied to clipboard)"
  ip -o -4 -br address | grep -v '^br-'
}
alias myip="curl http://myip.dnsomatic.com;echo"
TAILER="/usr/bin/less"
if [[ -x "${TAILER}" ]]; then
  TAILER="${TAILER} -i +F"
else
  TAILER="tail -f"
fi

export BROWSER=firefox

char-count() {
  echo -n "$@" | wc -c
}

dirs() {
  for DIR in "${@}"; do
    [ -d "${DIR}" ] || mkdir -p "${DIR}"
  done
}

ok() {
  local script="$1"
  shift
  for ext in sh js py; do
    local relative="./bin/${script}.${ext}"
    if [[ -x "${relative}" ]]; then
      "${relative}" "$@"
      return
    fi
  done
  echo "no scripts matched ./bin/${script}.*" 1>&2
  ls -1 ./bin/*.*
}

serve-dir() {
  python -m SimpleHTTPServer "$@"
}

tstmp() {
  local DIR
  DIR="/tmp/$(timestamp)"
  mkdir -p "${DIR}/node_modules"
  cd "${DIR}" || return 1
}

whos-listening() {
  if [[ -n "$1" ]]; then
    port=":$1"
  fi
  lsof -n -P -i "4TCP${port}" -s TCP:LISTEN
  lsof -n -P -i "4UDP${port}"
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
  read confirm
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
  find ~/Downloads -maxdepth 2 -type "f" -size +200M | sort | {
    while IFS= read -r file_path; do
      echo -n Watch "$(basename "${file_path}")? y/n"
      read -q response
      echo
      if [[ "${response}" == "y" ]]; then
        open "${file_path}"
        return
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
alias spaces2underscores='for i in *; do mv -iv "$i" "${i// /_}"; done'
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
  source "${br_source}"
fi

md-clipboard-to-pdf() {
  local outdir="${1-/tmp/$(timestamp)}"
  mkdir -p "${outdir}"
  ~/bin/paste | ~/projects/md-to-pdf/bin/md-to-pdf.js >"${outdir}/doc.pdf"
  echo "!$"
  open "!$"
}