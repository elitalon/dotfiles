#!/usr/bin/env bash

set -o nounset
set -o errexit


function set_up_system() {
    echo "Create Projects directory in $HOME"
    [[ ! -d ~/Projects ]] && mkdir ~/Projects

    echo "Restart automatically if the computer freezes"
    sudo systemsetup -setrestartfreeze on

    echo "Set a blazingly fast keyboard repeat rate"
    defaults write NSGlobalDomain KeyRepeat -int 1
    defaults write NSGlobalDomain InitialKeyRepeat -int 10

    echo "Set languages"
    defaults write NSGlobalDomain AppleLanguages -array "en" "es" "de"

    echo "Require a password immediately after sleep or screen saver begins"
    defaults write com.apple.screensaver askForPassword -int 1
    defaults write com.apple.screensaver askForPasswordDelay -int 0

    echo "Save screenshots in PNG format"
    defaults write com.apple.screencapture type -string "png"

    echo "Disable shadow in screenshots"
    defaults write com.apple.screencapture disable-shadow -bool true

    echo "Enable subpixel font rendering on non-Apple LCDs"
    defaults write NSGlobalDomain AppleFontSmoothing -int 1

    echo "Enable drag on windows gesture"
    defaults write -g NSWindowShouldDragOnGesture -bool true

    echo "Increase sound quality for Bluetooth headphones/headsets"
    defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40
}

function set_up_finder() {
    echo "Enable transparency in menu bar"
    defaults write NSGlobalDomain AppleEnableMenuBarTransparency -bool true

    echo "Set sidebar icon size to small"
    defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 1

    echo "Disable the over-the-top focus ring animation"
    defaults write NSGlobalDomain NSUseAnimatedFocusRing -bool false

    echo "Increase window resize speed for Cocoa applications"
    defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

    echo "Expand save panel by default"
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

    echo "Expand print panel by default"
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

    echo "Save to disk (not to iCloud) by default"
    defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

    echo "Quit printer app automatically once the print jobs complete"
    defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

    echo "Do not show all filename extensions"
    defaults write NSGlobalDomain AppleShowAllExtensions -bool false

    echo "Show status bar in Finder"
    defaults write com.apple.finder ShowStatusBar -bool true

    echo "Show path bar in Finder"
    defaults write com.apple.finder ShowPathbar -bool true

    echo "Search the current folder by default"
    defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

    echo "Avoid creating .DS_Store files on network and USB volumes"
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

    echo "Show the ~/Library folder"
    chflags nohidden ~/Library && xattr -d com.apple.FinderInfo ~/Library
}

function set_up_dock() {
    echo "Show indicator lights for open applications in the Dock"
    defaults write com.apple.dock show-process-indicators -bool true

    echo "Hide and show the Dock automatically"
    defaults write com.apple.dock autohide -bool true

    echo "Make Dock icons of hidden applications translucent"
    defaults write com.apple.dock showhidden -bool true
}

function set_up_desktop() {
    echo "Speed up Mission Control animations"
    defaults write com.apple.dock expose-animation-duration -float 0.1

    echo "Don't group windows by application in Mission Control"
    defaults write com.apple.dock expose-group-by-app -bool false

    echo "Disable Dashboard"
    defaults write com.apple.dashboard mcx-disabled -bool true
    defaults write com.apple.dock dashboard-in-overlay -bool true

    echo "Setup top left screen corner to start the screen saver"
    defaults write com.apple.dock wvous-tl-corner -int 5
    defaults write com.apple.dock wvous-tl-modifier -int 0

    echo "Setup bottom right screen corner to show Mission Control"
    defaults write com.apple.dock wvous-br-corner -int 2
    defaults write com.apple.dock wvous-br-modifier -int 0

    echo "Setup top right screen corner to show Desktop"
    defaults write com.apple.dock wvous-tr-corner -int 4
    defaults write com.apple.dock wvous-tr-modifier -int 0

    echo "Show icons for hard drives, servers, and removable media on the desktop"
    defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
    defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
    defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
    defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true
}

function set_up_terminal() {
    echo "Only use UTF-8 in Terminal"
    defaults write com.apple.terminal StringEncodings -array 4

    echo "Enable Secure Keyboard Entry in Terminal.app"
    # See: https://security.stackexchange.com/a/47786/8918
    defaults write com.apple.terminal SecureKeyboardEntry -bool true

    echo "Disable the annoying line marks in Terminal"
    defaults write com.apple.Terminal ShowLineMarks -int 0
}

function set_up_activity_monitor() {
    echo "Show the main window when launching Activity Monitor"
    defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

    echo "Visualize CPU usage in the Activity Monitor Dock icon"
    defaults write com.apple.ActivityMonitor IconType -int 5

    echo "Show all processes in Activity Monitor"
    defaults write com.apple.ActivityMonitor ShowCategory -int 0

    echo "Sort Activity Monitor results by CPU usage"
    defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
    defaults write com.apple.ActivityMonitor SortDirection -int 0
}

function set_up_text_edit() {
    echo "Use plain text mode for new TextEdit documents"
    defaults write com.apple.TextEdit RichText -int 0

    echo "Open and save files as UTF-8 in TextEdit"
    defaults write com.apple.TextEdit PlainTextEncoding -int 4
    defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4
}

function set_up_photos() {
    echo "Disable hot plug with Image Capture and Photos"
    defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true
}

function kill_affected_applications() {
    for app in "Activity Monitor" \
        "cfprefsd" \
        "Dock" \
        "Finder" \
        "Photos" \
        "SystemUIServer" \
        "Terminal"; do
        killall "${app}" &> /dev/null
    done
}


function main() {
    # Close any open System Preferences panes, to prevent them from overriding
    # settings we're about to change
    osascript -e 'tell application "System Preferences" to quit'

    # Ask for the admin password upfront and keep it alive until we're done
    sudo -v
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

    set_up_system
    set_up_finder
    set_up_dock
    set_up_desktop
    set_up_terminal
    set_up_activity_monitor
    set_up_text_edit
    set_up_photos
    kill_affected_applications

    echo
    echo "Done. Note that some of these changes require a logout/restart to take effect."
}

main
