#!/bin/bash

cd "$(dirname "${BASH_SOURCE}")"

git pull

function doIt() {
  EXCLUDE_JANUS=
  if [ -d ~/.vim ]; then
    EXCLUDE_JANUS='--exclude ".vim"'
  fi
  rsync --exclude ".git/" --exclude ".DS_Store" --exclude "bootstrap.sh" --exclude "README.md" ${EXCLUDE_JANUS} --exclude "init" -av . ~
  cd ~/.vim && rake && cd ${OLDPWD}
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
