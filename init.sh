#!/bin/bash
# Exit immediately if a command exits with a non-zero status.
set -e

# Define key files
ALIAS_SOURCE_FILE=".bash_aliases"
ALIAS_DEST_FILE="$HOME/.bash_aliases"
BASHRC="$HOME/.bashrc"
COPILOT_CONFIG_DIR=".config/copilot"
COPILOT_DEST_DIR="$HOME/.config/copilot"

# --- 1. Copy the file ---
# Assumes you are in the same directory as the source .bash_aliases
echo "Copying $ALIAS_SOURCE_FILE to $ALIAS_DEST_FILE..."
cp "$ALIAS_SOURCE_FILE" "$ALIAS_DEST_FILE"

# --- 2. Copy Copilot configuration ---
if [ -d "$COPILOT_CONFIG_DIR" ]; then
    echo "Copying $COPILOT_CONFIG_DIR to $COPILOT_DEST_DIR..."
    mkdir -p "$COPILOT_DEST_DIR"
    cp -R "$COPILOT_CONFIG_DIR/"* "$COPILOT_DEST_DIR/"
fi

# --- 3. Add sourcing logic and environment variables to .bashrc ---
# This is the line we want to add
ALIAS_LINE="if [ -f $ALIAS_DEST_FILE ]; then . $ALIAS_DEST_FILE; fi"
COPILOT_HOME_LINE="export COPILOT_HOME=\"\$HOME/.config/copilot\""

# Check if alias sourcing already exists
if ! grep -Fxq "$ALIAS_LINE" "$BASHRC"; then
    echo "Adding alias sourcing logic to $BASHRC..."
    echo -e "\n# Source custom aliases" >> "$BASHRC"
    echo "$ALIAS_LINE" >> "$BASHRC"
else
    echo "Sourcing logic already in $BASHRC."
fi

# Check if COPILOT_HOME already exists
if ! grep -Fxq "$COPILOT_HOME_LINE" "$BASHRC"; then
    echo "Adding COPILOT_HOME to $BASHRC..."
    echo -e "\n# GitHub Copilot configuration" >> "$BASHRC"
    echo "$COPILOT_HOME_LINE" >> "$BASHRC"
else
    echo "COPILOT_HOME already set in $BASHRC."
fi

# --- 4. Apply changes ---
echo "Reloading shell..."
source "$BASHRC"
echo "Done."
