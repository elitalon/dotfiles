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

# Set prompt to 'username@hostname:directory [git_branch] $ '
function parse_git_branch() {
	git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\[\1\] /'
}
PS1='\[\e[0;90m\]\w \[\e[0;32m\]$(parse_git_branch)\[\e[0m\]\$ '


#########
# EXPORTS
#########

# Default editor
export EDITOR=vim
command_exists mate && export EDITOR="$(type -P mate) -w"

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

# Enhanced WHOIS lookups
alias whois='whois -h whois-servers.net'

# Makes TextMate wait by default
command_exists mate && alias mate='mate -w'


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

# RVM binaries
[[ -s "${HOME}/.rvm/scripts/rvm" ]] && source "${HOME}/.rvm/scripts/rvm"

# HomeBrew binaries
homebrew_binaries="$(brew --prefix coreutils)/libexec/gnubin"
command_exists brew && ! path_contains "$homebrew_binaries" && export PATH="$homebrew_binaries:/usr/local/bin:$PATH"
unset -f homebrew_binaries


# Delete helpers functions
unset -f command_exists
unset -f path_contains
