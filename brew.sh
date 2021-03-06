#!/usr/bin/env bash

set -o nounset
set -o errexit

readonly brew="$(command -v brew)"
[[ -z "${brew}" ]] && echo 'brew command is not installed' && exit -1


# Removes outdated versions and broken links
function clean_up() {
    ${brew} cleanup
}

# Updates Homebrew
function update() {
    ${brew} update
    ${brew} upgrade
}

# Installs a list of formulae
function install() {
    for formula; do
        ${brew} install "${formula}"
    done
}

function main() {
    ${brew} analytics on

    clean_up
    update

    # Improved shell experience
    install coreutils findutils
    install bash bash-completion2
    install the_silver_searcher
    # install tree
    # install tmux

    # Git
    install git gh

    # Ruby environment
    install rbenv ruby-build

    # Python environment
    # install pyenv

    # iOS dependency managers
    # install carthage

    # Code quality
    install swiftlint
    # install tokei
    # install cloc
    # install danger/tap/danger-js

    # Programming languages and runtimes
    # install go
    # install node npm
    # install jenv

    # Networking utilities
    # install masscan nmap

    # Data processing
    # install jq

    # Other useful binaries
    # install unrar
    # install p7zip

    # Containers and orchestration
    # install docker-completion

    clean_up
}

main
