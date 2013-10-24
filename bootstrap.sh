#!/bin/bash

cd "$(dirname "${BASH_SOURCE}")"

function doIt() {
  # Update SSH config
  SSH_CONFIG=~/.ssh/config
  cat .ssh/config.before > $SSH_CONFIG && cat ~/Dropbox/Software/SSH/config.hosts >> $SSH_CONFIG && cat .ssh/config.after >> $SSH_CONFIG

  # Download changes
  git pull

  # Update dotfiles
  rsync --exclude ".brew" --exclude ".osx" --exclude "update_ssh.sh" --exclude ".git/" --exclude ".gitmodules" --exclude ".DS_Store" --exclude "bootstrap.sh" --exclude "README.md" --exclude "init" --exclude ".ssh/config" -av . ~
}

if [ "$1" == "--force" -o "$1" == "-f" ]; then
  doIt
else
  read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    doIt
  fi
fi
unset doIt

source ~/.bash_profile
