#!/usr/bin/env bash
# See https://www.nicksantamaria.net/post/boilerplate-bash-script/
set -euo pipefail
IFS=$'\n\t'

#/ Usage:       ./sync.sh
#/ Description: Sync changes to installed dotfiles back to this repo.
#/
#/              Will only run if the git working directory is clean.
#/ Options:
#/   --help: Display this help message
usage() { grep '^#/' "$0" | cut -c4- ; exit 0 ; }
expr "$*" : ".*--help" > /dev/null && usage

echoerr() { printf "%s\n" "$*" >&2 ; }
info()    { echoerr "[INFO]    $*" ; }
warning() { echoerr "[WARNING] $*" ; }
error()   { echoerr "[ERROR]   $*" ; }
fatal()   { echoerr "[FATAL]   $*" ; exit 1 ; }

function cleanup {
  # Nothing to cleanup: just output a blank line.
  printf "\n";
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  trap cleanup EXIT
  # Script goes here
  cd "$(dirname "${BASH_SOURCE[0]}")"
  if output=$(git status --porcelain) && [ -z "$output" ]; then
    pushd "$HOME"
    rsync --exclude ".DS_Store" -avh --no-perms --existing .[[:word:]]* bin "$(dirs -l +1)"
  else
    fatal "There are uncommited files in the working directory:
          $output
          ...or some other error occured."
  fi
fi
