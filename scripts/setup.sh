#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

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

# Function to handle nodenv installation
setup_nodenv() {
    if command -v nodenv &> /dev/null; then
        log "nodenv is already installed"
        return 0
    fi

    log "Downloading and installing nodenv"
    git clone https://github.com/nodenv/nodenv.git ~/.nodenv || return 1

    log "Adding nodenv to PATH"
    echo 'export PATH="$HOME/.nodenv/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(nodenv init -)"' >> ~/.bashrc
    source ~/.bashrc || return 1

    log "Installing Node.js"
    nodenv install 22.14.0 || return 1

    log "Setting Node.js version"
    nodenv global 22.14.0 || return 1
    nodenv rehash || return 1
}

main() {
    log "Running: Setup Home ⌁ 🧊"

    # Check requirements first
    check_requirements

    # Setup nodenv
    setup_nodenv || {
        log "Failed to setup yarn environment"
        exit 1
		}

		log "Finished: Setup Home ⌁ ⚡️"

    echo
}

# Run main function
main

exit 0
