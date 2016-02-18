#!/usr/bin/env bash

set -o nounset
set -o errexit

function download_changes() {
  [[ -n "$(command git status --porcelain --ignore-submodules -unormal 2> /dev/null)" ]] \
    && echo "Error: Git repository is dirty. Commit or discard your changes to continue." \
    && exit -2

  echo "Pulling changes from repository."
  git pull
}

function update_ssh_config() {
  echo "Updating SSH config"

  local ssh_config="${HOME}/.ssh/config"
  cat '.ssh/config.before' > "${ssh_config}" \
    && cat "${HOME}/Dropbox/Software/SSH/config.hosts" >> "${ssh_config}" \
    && cat '.ssh/config.after' >> "${ssh_config}"
}

function update_dotfiles() {
  echo "Updating dotfiles in ${HOME}"

  local source_directory=$(dirname "${BASH_SOURCE}")
  local destination_directory="${HOME}"
  rsync \
    --exclude "elitalon.terminal" \
    --exclude ".brew" \
    --exclude ".osx" \
    --exclude ".git/" \
    --exclude ".gitmodules" \
    --exclude ".DS_Store" \
    --exclude "bootstrap.sh" \
    --exclude "README.md" \
    --exclude ".ssh/config*" \
    --archive \
    --verbose \
    "${source_directory}" "${destination_directory}"
}

function main() {
  read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1
  echo
  if [[ ${REPLY} =~ ^[Nn]$ ]]; then
    exit
  fi

  cd "$(dirname "${BASH_SOURCE}")"
  download_changes
  update_ssh_config
  update_dotfiles
}

main

# Disabling safe-mode is needed for sourcing bash_profile
set +o nounset
set +o errexit
source ~/.bash_profile
