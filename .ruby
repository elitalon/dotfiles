#!/usr/bin/env bash

PREFERRED_VERSION="2.0.0-p247"

# Install preferred version of Ruby
rbenv install $PREFERRED_VERSION
rbenv rehash

# Set Ruby version as global
rbenv global $PREFERRED_VERSION

# Update rubygems
gem update --system
rbenv rehash

# Install bundler
gem install bundle
rbenv rehash