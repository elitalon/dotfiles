#!/bin/bash

cd "$(dirname "${BASH_SOURCE}")"

function doIt() {
  git pull

  # Install or upgrade Janus
  if [ ! -d ~/.vim ]; then
    read -p "Do you want to install Janus in this system? (y/n) " -n 1
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      curl -Lo- https://bit.ly/janus-bootstrap | bash
    fi
  else
    cd ~/.vim
    rake
    cd ${OLDPWD}
  fi

  rsync --exclude ".git/" --exclude ".DS_Store" --exclude "bootstrap.sh" --exclude "README.md" --exclude "init" -av . ~
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
