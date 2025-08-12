#!/usr/bin/env bash

set -o nounset
set -o errexit

script_directory=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
readonly script_directory

function fail() {
    local message=${1:-"Error"}
    local code=${2:-1}

    if [[ $code -eq 0 ]]; then
        code=1
    fi

    echo -e "\033[91m${message}\e[0m"
    exit "$code"
}

function log() {
    local message=${1:-}
    echo -e "\033[93m${message}\e[0m"
}

function command_exists() {
    [[ -n "$1" ]] && command -v "$1" 1>/dev/null 2>&1
}

function append_newline() {
    [[ -z ${1+} ]] && [[ -f $1 ]] && [[ -w $1 ]] && echo >> "$1"
}

function satisfy_requirements() {
    command_exists brew || fail "Missing Homebrew installation"
    command_exists truncate || fail "Missing truncate (install coreutils)"
}

function print_step_header() {
    local command=${1:-}
    local header_size="$(("${#command}" + 3))"

    echo -e
    echo -e "\033[92m*\e[${header_size}b\e[0m"
    echo -e "\033[92m* ${command} *\e[0m"
    echo -e "\033[92m*\e[${header_size}b\e[0m"
}

function download_dotfiles() {
    print_step_header "Downloading dotfiles"

    [[ -n "$(command git status --porcelain --ignore-submodules -unormal 2> /dev/null)" ]] \
        && fail "Error: Git repository is dirty. Commit or discard your changes to continue."

    git pull
}

function update_ssh_config() {
    local ssh_home="${HOME}/.ssh"
    print_step_header "Updating SSH config at ${ssh_home}"

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
    print_step_header "Installing custom fonts"
    cd ~/Downloads

    local font_dir="$HOME/Library/Fonts/NerdFonts"
    if ! [[ -e "${font_dir}" ]]; then
        mkdir "${font_dir}"
    fi

    # shellcheck disable=SC2043
    for font_name in FiraMono; do
        log "Installing ${font_name} font"
        curl -fsSLO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/"${font_name}".zip
        unzip "${font_name}.zip" -d "${font_name}"

        case "${font_name}" in
            FiraMono)
                cp -fv "${font_name}"/FiraMonoNerdFontMono*.otf "$font_dir"
                ;;
        esac

        rm -rf "${font_name}.zip" "${font_name}"
    done

    cd -
}

function install_dotfiles() {
    print_step_header "Updating dotfiles in ${HOME}"

    local source_directory="${script_directory}"
    local destination_directory="${HOME}"
    rsync \
        --exclude-from=rsync.filters \
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
    print_step_header "Tuning Xcode"

    # Show how long it takes to build a project
    defaults write com.apple.dt.Xcode ShowBuildOperationDuration YES

    local user_data_directory="$HOME/Library/Developer/Xcode/UserData/"
    local xcode_dotfiles="${script_directory}/xcode"

    # Add custom breakpoints
    local user_data_debugger_directory="${user_data_directory}xcdebugger"
    [[ ! -d "${user_data_debugger_directory}" ]] && mkdir -p "${user_data_debugger_directory}"
    cp "${xcode_dotfiles}/Breakpoints_v2.xcbkptlist" "${user_data_debugger_directory}"

    # Add custom themes
    local user_data_themes_directory="${user_data_directory}FontAndColorThemes"
    [[ ! -d "${user_data_themes_directory}" ]] && mkdir -p "${user_data_themes_directory}"
    find "${xcode_dotfiles}/themes" -iname '*.xccolortheme' -exec cp {} "${user_data_themes_directory}" \;

    # Enable additional counterpart extensions
    # To disable: defaults delete com.apple.dt.Xcode IDEAdditionalCounterpartSuffixes
    defaults write com.apple.dt.Xcode IDEAdditionalCounterpartSuffixes \
        -array-add "ViewModel" "View" "DataSource" "ViewData" "Tests"

    # Avoid creating a default set of devices
    defaults write com.apple.CoreSimulator EnableDefaultSetCreation -bool NO
}

function tune_textmate() {
    print_step_header "Tuning TextMate"

    local user_directory="$HOME/Library/Application Support/TextMate/"
    mkdir -p "${user_directory}"

    cp "${script_directory}/textmate/KeyBindings.dict" "${user_directory}"
}

function tune_vscode() {
    print_step_header "Tuning VS Code"

    local user_directory="$HOME/Library/Application Support/Code/User/"
    mkdir -p "${user_directory}"

    for file in settings.json keybindings.json; do
        cp "${script_directory}/vscode/${file}" "${user_directory}"
    done
}

function add_homebrewed_bash() {
    print_step_header "Adding Homebrew version of Bash"

    local bash_path=/opt/homebrew/bin/bash

    if ! grep -F -q "${bash_path}" /etc/shells; then
        echo "${bash_path}" | sudo tee -a /etc/shells
        chsh -s ${bash_path}
    fi
}

function add_trash_symbolic_link() {
    print_step_header "Adding symbolic link to ~/.Trash"

    if [[ -e "${PWD^^}" ]]; then
        log "Skipping symbolic link, filesystem is case insensitive"
        return 0
    fi

    local lowercase_trash="${HOME}/.trash"
    local uppercase_trash="${HOME}/.Trash"
    if [[ -h "${lowercase_trash}" ]]; then
        log "Symlink to ${uppercase_trash} already exists"
    else
        ln -s "${uppercase_trash}" "${lowercase_trash}"
    fi
}

function install_custom_scripts() {
    print_step_header "Installing custom scripts"

    local custom_binaries="/opt/bin"
    if [[ ! -d "${custom_binaries}" ]]; then
        fail "Target directory ${custom_binaries} does not exist."
    fi

    sudo -v
    for script in scripts/mkscript.sh idea.sh; do
        if [[ ! -e "${script_directory}/${script}" ]]; then
            log "Script ${script} does not exist in ${script_directory}"
        else
            local target
            target="${custom_binaries}/$(basename -- "${script}" .sh)"

            log "Installing ${target}"
            sudo cp "${script_directory}/${script}" "${target}"
            sudo chown root:wheel "${target}"
        fi
    done
    sudo -k
}

function main() {
    satisfy_requirements

    cd "${script_directory}"

    download_dotfiles
    update_ssh_config
    install_dotfiles
    install_fonts
    tune_xcode
    tune_textmate
    tune_vscode
    add_homebrewed_bash
    add_trash_symbolic_link
    install_custom_scripts
}

main "$@"

# Disabling safe-mode is needed for sourcing bash_profile
set +o nounset
set +o errexit

# shellcheck source=/dev/null
source ~/.bash_profile
