###
# Configure Bash
#
# Dependencies:
#   - dotfiles
#   - ssh
#   - brew
#   - rbenv
###


###
# Returns true if given command exists
#
# WARNING: This function is defined here because it's used throughout the dotfiles
###
function command_exists() {
  if [ -z "$1" ]; then
    return 1
  else
    return $(command -v $1 >/dev/null 2>&1)
  fi
}


###
# Returns true if given pattern exists in $PATH
#
# WARNING: This function is defined here because it's used throughout the dotfiles
###
function path_contains() {
  if [ -z "$1" ]; then
    return 1
  else
    IFS_BACKUP=$IFS
    IFS=:
    for DIRECTORY in $PATH; do
      if [[ "$DIRECTORY" == *"$1"* ]]; then
        IFS=$IFS_BACKUP
        return 0
      fi
    done

    IFS=$IFS_BACKUP
    return 1
  fi
}


###
# Alert if dependencies are not satisfied
###
dependencies="brew rbenv"
for dependency in $dependencies; do
  if ! command_exists $dependency; then
    echo "WARNING: $dependency is required but has not been found"
  fi
done
unset dependencies

###
# Load the shell dotfiles
###
for file in ~/.{bash_prompt,exports,aliases,functions}; do
  [ -r "$file" ] && source "$file"
done
unset file

###
# Autocomplete commands issued with sudo
###
complete -cf sudo

###
# Append to the Bash history file, rather than overwriting it
###
shopt -s histappend

###
# Autocorrect typos in path names when using `cd`
###
shopt -s cdspell

###
# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
###
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2)" scp sftp ssh

###
# Add tab completion for many more commands
###
[ -r /etc/bash_completion ] && source /etc/bash_completion
if command_exists brew && [ -r $(brew --prefix)/etc/bash_completion ]; then
  source $(brew --prefix)/etc/bash_completion
fi

###
# Delete functions defined above
###
unset -f command_exists
unset -f path_contains