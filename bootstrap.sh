#!/usr/bin/env bash

set -o nounset
set -o errexit

cd "$(dirname "${BASH_SOURCE}")"

function doIt() {
  # Update SSH config
  local readonly ssh_config='~/.ssh/config'
  cat '.ssh/config.before' > "${ssh_config}" && cat '~/Dropbox/Software/SSH/config.hosts' >> "${ssh_config}" && cat '.ssh/config.after' >> "${ssh_config}"

  # Download changes
  git pull

  # Update dotfiles
  rsync --exclude '.brew' --exclude '.osx' --exclude '.git/' --exclude '.gitmodules' --exclude '.DS_Store' --exclude 'bootstrap.sh' --exclude 'README.md' --exclude 'init' --exclude '.ssh/config' -av . ~
}

readonly arg1=${1:-}
if [[ "${arg1}" = '--force' || "${arg1}" = '-f' ]]; then
  doIt
else
  read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1
  echo
  if [[ ${reply:-} =~ ^[Yy]$ ]]; then
    doIt
  fi
fi

unset doIt
source ~/.bash_profile
