##########
# HELPERS
#
# These functions are only used inside .bash_profile and will be unset at the
# very end.
##########

# Returns whether a given command exists
function command_exists() {
    [[ -n "$1" ]] && hash "$1" 1>/dev/null 2>&1
}

# Returns whether a given pattern exists in $PATH
function path_contains() {
    [[ -z "$1" ]] && return 1

    local IFS_BACKUP=${IFS}
    IFS=:
    for DIRECTORY in ${PATH}; do
        if [[ "${DIRECTORY}" == *"$1"* ]]; then
            IFS=${IFS_BACKUP}
            return 0
        fi
    done

    IFS=${IFS_BACKUP}
    return 1
}



##########
# SOURCING
#
# Needs to happen before anything else, so that further customisations can use
# the paths defined here.
##########

# HomeBrew binaries (always first)
eval "$(/opt/homebrew/bin/brew shellenv)"

for package in coreutils findutils
do
    package_path="/opt/homebrew/opt/${package}/libexec/gnubin"
    command_exists brew \
        && ! path_contains "${package_path}" \
        && export PATH="${package_path}:${PATH}"
unset -f package_path
done

# pyenv binaries
if command_exists pyenv; then
    export PYENV_ROOT="${HOME}/.pyenv"
    export PATH="${PYENV_ROOT}/bin:${PATH}"
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
fi

# rbenv binaries
command_exists rbenv && eval "$(rbenv init -)"

# Go environment
if command_exists go; then
    export GOPATH="${HOME}/Projects/golang"
    export GOROOT="$(brew --prefix golang)/libexec"
    export PATH="${PATH}:${GOPATH}/bin:${GOROOT}/bin"
    test -d "${GOPATH}" || mkdir -p "${GOPATH}"
fi

# Java environment
if command_exists jenv; then
    export PATH="${PATH}:${HOME}/.jenv/bin"
    eval "$(jenv init -)"
fi
export PATH="$PATH:/opt/apache-maven/bin"

# Visual Studio Code
vscode_path="/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
[[ -e "${vscode_path}" ]] \
    && ! path_contains "${vscode_path}" \
    && export PATH="${PATH}:${vscode_path}"
unset -f vscode_path

# NVM environment
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Rust environment
rust_cargo_path="${HOME}/.cargo"
[ -d "${rust_cargo_path}" ] && \. "${rust_cargo_path}/env"
unset -f rust_cargo_path

# Additional add-on packages
export PATH="$PATH:/opt/bin"
export PATH="$PATH:${HOME}/.local/bin"

# SDKMAN
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"



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

# Make Python use UTF-8 encoding for output to stdin, stdout, and stderr.
export PYTHONIOENCODING='UTF-8';

# Make Java use English
export JAVA_TOOL_OPTIONS='-Duser.language=en -Duser.country=CH'

# Highlight section titles in manual pages.
export LESS_TERMCAP_md="${yellow}";

# Do not clear the screen after quitting a manual page
export MANPAGER='less -X'

# Larger bash history
export HISTSIZE=32768
export HISTFILESIZE=${HISTSIZE}
export HISTCONTROL=ignoreboth

# Prefer US English and UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Hide the “default interactive shell is now zsh” warning on macOS.
export BASH_SILENCE_DEPRECATION_WARNING=1;

# Private environment variables
[[ -s "${HOME}/.private_exports" ]] && source "${HOME}/.private_exports"



###########
# FUNCTIONS
###########

# Opens Xcode workspace in current directory
function xcode() {
    local XED=xed

    local workspace=$(find . -maxdepth 1 -type d -name *.xcworkspace -print -quit)
    if [[ -d "${workspace}" ]]; then
        ${XED} "${workspace}"
        return
    fi

    local project=$(find . -maxdepth 1 -type d -name *.xcodeproj -print -quit)
    if [[ -d "${project}" ]]; then
        ${XED} "${project}"
        return
    fi

    local package=$(find . -maxdepth 1 -type f -name Package.swift -print -quit)
    if [[ -f "${package}" ]]; then
        ${XED} "${package}"
        return
    fi

    echo "Xcode workspace, project or package not found"
    return 1
}

function encrypt() {
    local input_file="${1:-}"

    if [[ -z "${input_file}" ]]; then
        echo "Error: Missing input file"
        return 1
    fi

    if [[ ! -e "${input_file}" ]]; then
        echo "Error: ${input_file} does not exist"
        return 1
    fi

    if [[ ! -f "${input_file}" ]]; then
        echo "Error: ${input_file} is not a valid file"
        return 1
    fi

    local output_file="${input_file}.enc"
    if [[ -e "${output_file}" ]]; then
        echo "Error: ${output_file} already exists"
        return 1
    fi

    openssl enc -e -aes-256-cbc -pbkdf2 -salt -in "${input_file}" -out "${output_file}" || return 1
    echo "${input_file} encrypted successfully into ${output_file}";
}

function decrypt() {
    local input_file="${1:-}"

    if [[ -z "${input_file}" ]]; then
        echo "Error: Missing input file"
        return 1
    fi

    if [[ ! -e "${input_file}" ]]; then
        echo "Error: ${input_file} does not exist"
        return 1
    fi

    if [[ ! -f "${input_file}" ]]; then
        echo "Error: ${input_file} is not a valid file"
        return 1
    fi

    local output_file="${input_file%.enc}"
    if [[ -e "${output_file}" ]]; then
        echo "Error: ${output_file} already exists"
        return 1
    fi

    openssl enc -d -aes-256-cbc -pbkdf2 -in "${input_file}" -out "${output_file}" || return 1
    echo "${input_file} decrypted successfully into ${output_file}";
}

# Private functions
[[ -s "${HOME}/.private_functions" ]] && source "${HOME}/.private_functions"



#################
# GENERAL OPTIONS
#################

# Append to the Bash history file, rather than overwriting it
shopt -s histappend

# Autocorrect typos in path names when using `cd`
shopt -s cdspell

# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
	shopt -s "$option" 2> /dev/null;
done;

# Auto-expand directory in variables
shopt -s direxpand

# Autocomplete commands issued with sudo
complete -cf sudo



#########
# ALIASES
#########

# Enable aliases to be sudo’ed
alias sudo='sudo '

# Show line numbers in grep
alias grep='grep -n --color=auto'

# Recursive grep with line numbers
alias rgrep='grep -n -r --color=auto'

# List all files colorized in long format
if ls --color > /dev/null 2>&1; then # GNU `ls`
    alias ls='ls -lh --color'
else # OS X `ls`
    alias ls='ls -lhG'
fi

# Print each PATH entry on a separate line
alias path='echo -e ${PATH//:/\\n}'

# Get week number
alias week='date +%V'

# Launch Tower automatically from the current directory
alias tower='gittower .'

# Flush Directory Service cache
alias flush="dscacheutil -flushcache && killall -HUP mDNSResponder"

# Clean up LaunchServices to remove duplicates in the “Open With” menu
alias lscleanup="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user && killall Finder"

# Speed up attaching to tmux session
alias tat="tmux attach -t"



#################
# AUTO COMPLETION
#################

# SSH hostnames
[[ -s "${HOME}/.ssh/config" ]] \
    && complete -o 'default' -o 'nospace' -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2)" scp sftp ssh

# Bash commands
[[ -r /etc/bash_completion ]] && source /etc/bash_completion

# Homebrew-based bash commands
export BASH_COMPLETION_COMPAT_DIR="/opt/homebrew/etc/bash_completion.d"
bash_autocompletion="/opt/homebrew/etc/profile.d/bash_completion.sh"
[[ -r "${bash_autocompletion}" ]] && . "${bash_autocompletion}"
unset -f bash_autocompletion

# Kubernetes
# for k8s_tool in kubectl minikube; do
#     command_exists ${k8s_tool} && source <(${k8s_tool} completion bash)
# done



##########
# CLEANING UP
##########

unset -f command_exists
unset -f path_contains
