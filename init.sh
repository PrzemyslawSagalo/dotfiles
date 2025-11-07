#!/bin/bash
# Exit immediately if a command exits with a non-zero status.
set -e

# Define key files
ALIAS_SOURCE_FILE=".bash_aliases"
ALIAS_DEST_FILE="$HOME/.bash_aliases"
BASHRC="$HOME/.bashrc"

# --- 1. Copy the file ---
# Assumes you are in the same directory as the source .bash_aliases
echo "Copying $ALIAS_SOURCE_FILE to $ALIAS_DEST_FILE..."
cp "$ALIAS_SOURCE_FILE" "$ALIAS_DEST_FILE"

# --- 2. Add sourcing logic to .bashrc ---
# This is the line we want to add
ALIAS_LINE="if [ -f $ALIAS_DEST_FILE ]; then . $ALIAS_DEST_FILE; fi"

# Check if that *exact* line already exists in .bashrc
# -F = Treat as fixed string (not regex)
# -x = Match the whole line
# -q = Quiet (no output)
if ! grep -Fxq "$ALIAS_LINE" "$BASHRC"; then
    echo "Adding alias sourcing logic to $BASHRC..."
    # Add a newline, a comment, and the sourcing line
    echo -e "\n# Source custom aliases" >> "$BASHRC"
    echo "$ALIAS_LINE" >> "$BASHRC"
else
    echo "Sourcing logic already in $BASHRC."
fi

# --- 3. Apply changes ---
echo "Reloading shell..."
source "$BASHRC"
echo "Done."
