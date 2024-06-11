#!/usr/bin/env bash

set -o nounset
set -o errexit

script_directory=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
readonly script_directory

function command_exists() {
    [[ -n "$1" ]] && command -v "$1" 1>/dev/null 2>&1
}

function satisfy_requirements() {
    command_exists brew \
        || { echo "Error: missing Homebrew installation"; return 2; }
    command_exists truncate \
        || { echo "Error: missing truncate (install coreutils)"; return 2; }
}

function download_dotfiles() {
    [[ -n "$(command git status --porcelain --ignore-submodules -unormal 2> /dev/null)" ]] \
        && echo "Error: Git repository is dirty. Commit or discard your changes to continue." \
        && exit 2

    echo "Pulling changes from repository."
    git pull
}

function append_newline() {
    [[ -z ${1+} ]] && [[ -f $1 ]] && [[ -w $1 ]] && echo >> "$1"
}

function update_ssh_config() {
    local ssh_home="${HOME}/.ssh"
    echo "Updating SSH config at ${ssh_home}"

    local ssh_config="${ssh_home}/config"
    truncate -s 0 "${ssh_config}"

    local identity_files
    identity_files=$(find "${ssh_home}" -name 'id_*' -type f -exec basename {} \; | sed -e 's/.pub//' | uniq)

    for file in ${identity_files}; do
        echo "IdentityFile ${ssh_home}/${file}" >> "${ssh_config}"
    done
    append_newline "${ssh_config}"

    cat '.ssh/config.before' >> "${ssh_config}"
    append_newline "${ssh_config}"

    local ssh_hosts="${ssh_home}/config.hosts"
    if [[ -r "${ssh_hosts}" ]]; then
        cat "${ssh_hosts}" >> "${ssh_config}"
        append_newline "${ssh_config}"
    fi

    append_newline "${ssh_config}"
    cat '.ssh/config.after' >> "${ssh_config}"
    append_newline "${ssh_config}"
}

function install_fonts() {
    cd ~/Downloads

    local font_dir="$HOME/Library/Fonts/NerdFonts"
    if ! [[ -e "${font_dir}" ]]; then
        mkdir "${font_dir}"
    fi

    for font_name in CascadiaMono FiraMono; do
        echo "Install ${font_name} font"
        curl -fLO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/"${font_name}".zip
        unzip "${font_name}.zip" -d "${font_name}"

        case "${font_name}" in
            CascadiaMono)
                cp -fv "${font_name}"/CaskaydiaMonoNerdFontMono*.ttf "$font_dir"
                ;;
            FiraMono)
                cp -fv "${font_name}"/FiraMonoNerdFontMono*.otf "$font_dir"
                ;;
        esac

        rm -rf "${font_name}.zip" "${font_name}"
    done

    cd -
}

function install_dotfiles() {
    echo "Updating dotfiles in ${HOME}"

    local source_directory="${script_directory}"
    local destination_directory="${HOME}"
    rsync \
        --exclude "elitalon.terminal" \
        --exclude "brew.sh" \
        --exclude "macos.sh" \
        --exclude ".git/" \
        --exclude ".idea/" \
        --exclude ".gitmodules" \
        --exclude ".DS_Store" \
        --exclude "bootstrap.sh" \
        --exclude "README.md" \
        --exclude "LICENSE" \
        --exclude ".ssh/config*" \
        --exclude "xcode/" \
        --exclude "textmate/" \
        --exclude "vscode/" \
        --exclude "editor_themes/" \
        --recursive \
        --links \
        --perms \
        --times \
        --human-readable \
        --progress \
        --verbose \
        "${source_directory}/" "${destination_directory}"
}

function tune_xcode() {
    # Show how long it takes to build a project
    defaults write com.apple.dt.Xcode ShowBuildOperationDuration YES

    local user_data_directory="$HOME/Library/Developer/Xcode/UserData/"

    # Add default breakpoints
    local user_data_debugger_directory="${user_data_directory}xcdebugger"
    [[ ! -d "${user_data_debugger_directory}" ]] && mkdir -p "${user_data_debugger_directory}"
    local custom_breakpoints_filename="xcode/Breakpoints_v2.xcbkptlist"
    cp "${script_directory}/${custom_breakpoints_filename}" "${user_data_debugger_directory}"

    # Add custom themes
    local user_data_themes_directory="${user_data_directory}FontAndColorThemes"
    [[ ! -d "${user_data_themes_directory}" ]] && mkdir -p "${user_data_themes_directory}"
    find "${script_directory}" -iname '*.xccolortheme' -exec cp {} "${user_data_themes_directory}" \;

    # Enable additional counterpart extensions
    # To disable: defaults delete com.apple.dt.Xcode IDEAdditionalCounterpartSuffixes
    defaults write com.apple.dt.Xcode IDEAdditionalCounterpartSuffixes \
        -array-add "ViewModel" "View" "DataSource" "ViewData" "Tests"
}

function tune_textmate() {
    local user_directory="$HOME/Library/Application Support/TextMate/"
    mkdir -p "${user_directory}"

    cp "${script_directory}/textmate/KeyBindings.dict" "${user_directory}"
}

function tune_vscode() {
    local user_directory="$HOME/Library/Application Support/Code/User/"
    mkdir -p "${user_directory}"

    for file in settings.json keybindings.json; do
        cp "${script_directory}/vscode/${file}" "${user_directory}"
    done
}

function add_homebrewed_bash() {
    local bash_path=/opt/homebrew/bin/bash

    if ! grep -F -q "${bash_path}" /etc/shells; then
        echo "${bash_path}" | sudo tee -a /etc/shells
        chsh -s ${bash_path}
    fi
}

function main() {
    satisfy_requirements || exit 2

    cd "${script_directory}"

    download_dotfiles
    update_ssh_config
    install_dotfiles
    install_fonts
    tune_xcode
    tune_textmate
    tune_vscode
    add_homebrewed_bash
}

main

# Disabling safe-mode is needed for sourcing bash_profile
set +o nounset
set +o errexit
source ~/.bash_profile
