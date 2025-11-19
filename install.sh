#!/bin/bash
#
# This script clones or updates the dotfiles repository and runs the init script.
# It is designed to be run remotely via:
# curl -sSL https://raw.githubusercontent.com/PrzemyslawSagalo/dotfiles/main/install.sh | sh

# Exit immediately if a command exits with a non-zero status.
set -e
# Treat unset variables as an error.
set -u

export PATH="/usr/bin:/usr/local/bin:$PATH"

# --- Configuration ---
readonly REPO_URL="https://github.com/PrzemyslawSagalo/dotfiles.git"
readonly REPO_BRANCH="main"
readonly CLONE_DIR="${HOME}/.dotfiles"

# --- Installation / Update ---
if [ -d "$CLONE_DIR" ]; then
    echo "-> Found existing dotfiles directory in ${CLONE_DIR}."
    echo "-> Pulling latest changes..."
    cd "$CLONE_DIR"
    
    # This git command is cross-platform
    if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
         echo "Error: ${CLONE_DIR} exists but is not a valid git repository." >&2
         exit 1
    fi
    
    git pull origin "$REPO_BRANCH"
else
    echo "-> Cloning dotfiles repository to ${CLONE_DIR}..."
    git clone --branch "$REPO_BRANCH" "$REPO_URL" "$CLONE_DIR"
    cd "$CLONE_DIR"
fi

# --- Initialization ---
if [ ! -f "init.sh" ]; then
    echo "Error: 'init.sh' not found in the repository." >&2
    exit 1
fi

echo "-> Running initialization script..."
# Use 'bash' explicitly to ensure compatibility on systems like Ubuntu
bash ./init.sh

echo ""
echo "✅ Dotfiles setup complete."
echo "Please restart your shell (or run 'source ~/.bashrc' / 'source ~/.bash_aliases') to apply changes."

exit 0
