###
# Returns whether a given command exists
###
function command_exists() {
  [[ -z "$1" ]] && return 1
  return $(command -v $1 >/dev/null 2>&1)
}


###
# Returns whether a given pattern exists in $PATH
###
function path_contains() {
  [[ -z "$1" ]] && return 1

  local IFS_BACKUP=$IFS
  IFS=:
  for DIRECTORY in $PATH; do
    if [[ "$DIRECTORY" == *"$1"* ]]; then
      IFS=$IFS_BACKUP
      return 0
    fi
  done

  IFS=$IFS_BACKUP
  return 1
}


###
# All the dig info
###
function digga() {
	dig +nocmd "$1" any +multiline +noall +answer
}


#################
# GENERAL OPTIONS
#################

# Append to the Bash history file, rather than overwriting it
shopt -s histappend

# Autocorrect typos in path names when using `cd`
shopt -s cdspell

# Autocomplete commands issued with sudo
complete -cf sudo


########
# PROMPT
########

function git_dirty() {
  test -z "$(command git status --porcelain --ignore-submodules -unormal 2> /dev/null)"
  (( $? )) && echo " *"
}

function git_branch() {
  local current_branch="$(command git rev-parse --abbrev-ref HEAD 2> /dev/null)"
  [[ -z "${current_branch}" ]] || echo "[${current_branch}$(git_dirty)] "
}

PS1='\[\e[0;90m\]\w \[\e[0;32m\]$(git_branch)\[\e[0m\]❯ '


#########
# EXPORTS
#########

# Default editor
export EDITOR=vim
command_exists mate && export EDITOR="$(type -P mate)"

# Do not clear the screen after quitting a manual page
export MANPAGER='less -X'

# Larger bash history
export HISTSIZE=32768
export HISTFILESIZE=$HISTSIZE
export HISTCONTROL=ignoredups

# Make some commands not show up in history
export HISTIGNORE='ls:cd:cd -:pwd:exit:date:* --help'


#########
# ALIASES
#########

# Enable aliases to be sudo’ed
alias sudo='sudo '

# Show line numbers in grep
alias grep='grep -n'

# Recursive grep with line numbers
alias rgrep='grep -n -r'

# List all files colorized in long format
alias ls='ls -lh --color'

# IP addresses
alias ip='dig +short myip.opendns.com @resolver1.opendns.com'
alias localip='ipconfig getifaddr en1'


#################
# AUTO COMPLETION
#################

# SSH hostnames
[[ -s "${HOME}/.ssh/config" ]] && complete -o 'default' -o 'nospace' -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2)" scp sftp ssh

# Bash commands
[[ -r /etc/bash_completion ]] && source /etc/bash_completion

# Homebrew-based bash commands
[[ -r "$(brew --prefix)/etc/bash_completion" ]] && source "$(brew --prefix)/etc/bash_completion"


##########
# SOURCING
##########

# HomeBrew binaries
homebrew_binaries="$(brew --prefix coreutils)/libexec/gnubin"
command_exists brew && ! path_contains "$homebrew_binaries" && export PATH="$homebrew_binaries:/usr/local/bin:$PATH"
unset -f homebrew_binaries

# pyenv binaries
if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi

# rbenv binaries
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi


##########
# CLEANING
##########

# Delete helpers functions
unset -f command_exists
unset -f path_contains
