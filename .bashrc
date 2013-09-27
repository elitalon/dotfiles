[ -n "$PS1" ] && source ~/.bash_profile

# Add RVM to PATH for scripting
if [ -d "$HOME/.rvm/bin" ];then
	PATH=$PATH:$HOME/.rvm/bin
fi