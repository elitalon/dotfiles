#!/bin/bash

cd "$(dirname "${BASH_SOURCE}")"

SSH_CONFIG=~/.ssh/config
cat .ssh/config.before > $SSH_CONFIG && cat ~/Dropbox/Software/SSH/config.hosts >> $SSH_CONFIG && cat .ssh/config.after >> $SSH_CONFIG
