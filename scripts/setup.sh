#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Configuration
readonly NODE_VERSION=22.14.0
readonly FISH_PLUGINS=(
    "jethrokuan/fzf"
    "jethrokuan/z"
    "edc/bass"
    "netologist/theme-lambda"
)
readonly NODENV_PATH="$HOME/.nodenv"
readonly FISH_PATH="$HOME/.config/fish"

# Function for logging with timestamp
log() {
    echo "⌁ 📺 ⌁ [$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Function for error handling with more detailed output
handle_error() {
    local line_no=$1
    local command=$2
    log "Error occurred at line ${line_no}"
    log "Failed command: ${command}"
    exit 1
}

# Configure error traps
trap 'handle_error ${LINENO} "${BASH_COMMAND}"' ERR

# Function to check for required commands
check_requirements() {
    local required_commands=("git" "curl" "sudo")
    
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            log "Error: Required command '$cmd' not found"
            exit 1
        fi
    done
    
    log "All requirements satisfied"
}

# Function to run a command and log its status
run_command() {
    local description="$1"
    shift
    log "Starting: $description"
    if "$@"; then
        log "Completed: $description"
        return 0
    else
        log "Failed: $description"
        return 1
    fi
}

# Function to install Fisher and plugins
install_fisher() {
    run_command "Installing Fisher" \
        fish -c "curl -sL https://git.io/fisher | source && fisher install jethrokuan/fzf"
}

# Function to install Fish plugins
install_fish_plugins() {
    for plugin in "${FISH_PLUGINS[@]}"; do
        run_command "Installing Fish plugin: $plugin" \
            fish -c "fisher install $plugin"
    done
}

# Function to setup Fish shell
setup_fish() {
    if command -v fish &>/dev/null; then
        log "Fish shell is already installed"
        return 0
    fi

    run_command "Updating package lists" \
        sudo apt update

    run_command "Installing Fish shell" \
        sudo apt install -y fish

    run_command "Changing default shell to Fish" \
        chsh -s "$(which fish)"

    install_fisher || return 1
    install_fish_plugins || return 1
}

# Function to setup nodenv
setup_nodenv() {
    if command -v nodenv &>/dev/null; then
        log "nodenv is already installed"
        return 0
    fi

    run_command "Downloading and installing nodenv" \
        git clone https://github.com/nodenv/nodenv.git "$NODENV_PATH"

    # Add nodenv to PATH using a heredoc for better readability
    cat >> ~/.bashrc << EOF
export PATH="$NODENV_PATH/bin:\$PATH"
eval "\$(nodenv init -)"
EOF

    # Source the updated bashrc
    source ~/.bashrc

    run_command "Installing Node.js $NODE_VERSION" \
        nodenv install "$NODE_VERSION"

    run_command "Refreshing nodenv shims" \
        nodenv rehash

    run_command "Setting global Node.js version to $NODE_VERSION" \
        nodenv global "$NODE_VERSION"
}

# F
main() {
    log "Running: Setup Home ⌁ 🧊"

    # Create a trap for cleanup on script exit
    trap cleanup EXIT

    check_requirements || exit 1
    setup_nodenv || exit 1
    setup_fish || exit 1

    log "Finished: Setup Home ⌁ ⚡️"
}

cleanup() {
    # Add any cleanup tasks here
    log "Cleanup completed"
}

# Run main function
main

exit 0
