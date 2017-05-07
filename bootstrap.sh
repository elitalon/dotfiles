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

function append_newline() {
  [[ -z ${1+} ]] && [[ -f $1 ]] && [[ -w $1 ]] && echo >> $1
}

function update_ssh_config() {
  local ssh_home="${HOME}/.ssh"
  echo "Updating SSH config at ${ssh_home}"

  local ssh_config="${ssh_home}/config"
  truncate -s 0 "${ssh_config}"

  local identity_files=`find "${ssh_home}" -name 'id_*' -type f -exec basename {} \; | sed -e 's/.pub//' | uniq`
  for file in ${identity_files}; do
    echo "IdentityFile ${ssh_home}/${file}" >> "${ssh_config}"
  done
  append_newline "${ssh_config}"

  cat '.ssh/config.before' >> "${ssh_config}"
  append_newline "${ssh_config}"

  cat "${HOME}/Dropbox/Software/SSH/config.hosts" >> "${ssh_config}"
  append_newline "${ssh_config}"

  cat '.ssh/config.after' >> "${ssh_config}"
  append_newline "${ssh_config}"
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
    --exclude "Breakpoints_v2.xcbkptlist" \
    --exclude "editor_themes" \
    --archive \
    --verbose \
    "${source_directory}" "${destination_directory}"
}

function tune_xcode() {
  # Show how long it takes to build a project
  defaults write com.apple.dt.Xcode ShowBuildOperationDuration -bool YES

  # Faster build times by leveraging multi-core CPU
  defaults write com.apple.dt.Xcode IDEBuildOperationMaxNumberOfConcurrentCompileTasks `sysctl -n hw.ncpu`

  local user_data_directory="$HOME/Library/Developer/Xcode/UserData/"

  # Add default breakpoints
  local user_data_debugger_directory="${user_data_directory}xcdebugger"
  [[ ! -d "${user_data_debugger_directory}" ]] && mkdir -p "${user_data_debugger_directory}"
  local custom_breakpoints_filename="Breakpoints_v2.xcbkptlist"
  cp "$(dirname $BASH_SOURCE)/${custom_breakpoints_filename}" "${user_data_debugger_directory}"

  # Add custom themes
  local user_data_themes_directory="${user_data_directory}FontAndColorThemes"
  [[ ! -d "${user_data_themes_directory}" ]] && mkdir -p "${user_data_themes_directory}"
  cp "$(dirname $BASH_SOURCE)/editor_themes/*.xccolortheme" "${user_data_themes_directory}"
}

function main() {
  cd "$(dirname "${BASH_SOURCE}")"
  download_changes
  update_ssh_config
  update_dotfiles
  tune_xcode
}

main

# Disabling safe-mode is needed for sourcing bash_profile
set +o nounset
set +o errexit
source ~/.bash_profile
