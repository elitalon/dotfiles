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
[ -f /etc/bash_completion ] && source /etc/bash_completion
if [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
fi

###
# Add rbenv init to enable shims and autocompletion
###
eval "$(rbenv init -)"
