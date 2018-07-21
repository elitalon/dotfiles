#!/usr/bin/env bash

set -o nounset
set -o errexit

function main() {
    # Ask for the admin password and keep it alive until finishing"
    sudo -v
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

    echo "Create Projects directory in $HOME"
    [[ ! -d ~/Projects ]] && mkdir ~/Projects

    echo "Enable transparency in menu bar"
    defaults write NSGlobalDomain AppleEnableMenuBarTransparency -bool true

    echo "Increase window resize speed for Cocoa applications"
    defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

    echo "Expand save panel by default"
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true

    echo "Expand print panel by default"
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true

    echo "Quit printer app automatically once the print jobs complete"
    defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

    echo "Disable hot plug with Image Capture"
    defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

    echo "Enable automatic restart if the computer freezes"
    sudo systemsetup -setrestartfreeze on

    echo "Set a blazingly fast keyboard repeat rate"
    defaults write NSGlobalDomain KeyRepeat -int 1
    defaults write NSGlobalDomain InitialKeyRepeat -int 10

    echo "Enable requiring a password immediately after sleep or screen saver begins"
    defaults write com.apple.screensaver askForPassword -int 1
    defaults write com.apple.screensaver askForPasswordDelay -int 0

    echo "Save screenshots in PNG format"
    defaults write com.apple.screencapture type -string "png"

    echo "Disable shadow in screenshots"
    defaults write com.apple.screencapture disable-shadow -bool true

    echo "Enable subpixel font rendering on non-Apple LCDs"
    defaults write NSGlobalDomain AppleFontSmoothing -int 2

    echo "Show status bar in Finder"
    defaults write com.apple.finder ShowStatusBar -bool true

    echo "Show path bar in Finder"
    defaults write com.apple.finder ShowPathbar -bool true

    echo "Avoid creating .DS_Store files on network volumes"
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

    echo "Do not empty Trash securely by default"
    defaults write com.apple.finder EmptyTrashSecurely -bool false

    echo "Show the ~/Library folder"
    chflags nohidden ~/Library

    echo "Show indicator lights for open applications in the Dock"
    defaults write com.apple.dock show-process-indicators -bool true

    echo "Hide and show the Dock automatically"
    defaults write com.apple.dock autohide -bool true

    echo "Make Dock icons of hidden applications translucent"
    defaults write com.apple.dock showhidden -bool true

    echo "Only use UTF-8 in Terminal.app"
    defaults write com.apple.terminal StringEncodings -array 4

    echo "Done. Note that some of these changes require a logout/restart to take effect."
}

main