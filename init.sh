#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BASHRC="$HOME/.bashrc"
ALIAS_TARGET="$HOME/.bash_aliases"
COPILOT_TARGET="$HOME/.config/copilot"
AGY_CONFIG_DIR="$HOME/.gemini/config"

link_dotfile() {
    local source_file="$1"
    local target_file="$2"
    
    mkdir -p "$(dirname "$target_file")"
    echo "Symlinking $source_file -> $target_file..."
    ln -sfn "$source_file" "$target_file"
}

ensure_in_bashrc() {
    local line="$1"
    local comment="$2"
    
    if ! grep -Fxq "$line" "$BASHRC"; then
        echo "Adding $comment to $BASHRC..."
        echo -e "\n# $comment\n$line" >> "$BASHRC"
    else
        echo "Already present in $BASHRC: $comment"
    fi
}

setup_bash() {
    echo "--- Setting up Bash ---"
    link_dotfile "$DOTFILES_DIR/.bash_aliases" "$ALIAS_TARGET"
    ensure_in_bashrc "if [ -f $ALIAS_TARGET ]; then . $ALIAS_TARGET; fi" "Source custom aliases"
}

setup_copilot() {
    echo "--- Setting up GitHub Copilot CLI ---"
    
    # 1. Create real directories to prevent modifying the git repository when we copy dynamic files
    mkdir -p "$COPILOT_TARGET/skills" "$COPILOT_TARGET/agents" "$COPILOT_TARGET/commands" "$COPILOT_TARGET/standards"
    
    # 2. Symlink tracked files from dotfiles individually
    [ -f "$DOTFILES_DIR/.config/copilot/copilot-instructions.md" ] && link_dotfile "$DOTFILES_DIR/.config/copilot/copilot-instructions.md" "$COPILOT_TARGET/copilot-instructions.md"
    [ -f "$DOTFILES_DIR/.config/copilot/mcp-config.json" ] && link_dotfile "$DOTFILES_DIR/.config/copilot/mcp-config.json" "$COPILOT_TARGET/mcp-config.json"
    
    if [ -d "$DOTFILES_DIR/.config/copilot/skills" ]; then
        for skill in "$DOTFILES_DIR/.config/copilot/skills/"*; do
            [ -e "$skill" ] || continue
            link_dotfile "$skill" "$COPILOT_TARGET/skills/$(basename "$skill")"
        done
    fi

    if [ -d "$DOTFILES_DIR/.config/copilot/standards" ]; then
        for std in "$DOTFILES_DIR/.config/copilot/standards/"*; do
            [ -e "$std" ] || continue
            link_dotfile "$std" "$COPILOT_TARGET/standards/$(basename "$std")"
        done
    fi
    
    # 3. Add environment variable to .bashrc
    ensure_in_bashrc "export COPILOT_HOME=\"\$HOME/.config/copilot\"" "GitHub Copilot configuration"
    
    # 4. Sync external maister-copilot files dynamically
    echo "Dynamically syncing maister repository for Copilot..."
    local TEMP_DIR=$(mktemp -d)
    trap 'rm -rf "$TEMP_DIR"' EXIT
    git clone --depth 1 https://github.com/SkillPanel/maister.git "$TEMP_DIR" > /dev/null 2>&1
    
    # Copy dynamic skills, commands, and agents directly into the real Copilot config folders
    if [ -d "$TEMP_DIR/plugins/maister-copilot/skills" ]; then
        cp -R "$TEMP_DIR/plugins/maister-copilot/skills/"* "$COPILOT_TARGET/skills/"
    fi
    if [ -d "$TEMP_DIR/plugins/maister-copilot/agents" ]; then
        cp -R "$TEMP_DIR/plugins/maister-copilot/agents/"* "$COPILOT_TARGET/agents/"
    fi
    if [ -d "$TEMP_DIR/plugins/maister-copilot/commands" ]; then
        cp -R "$TEMP_DIR/plugins/maister-copilot/commands/"* "$COPILOT_TARGET/commands/"
    fi
    
    trap - EXIT
    rm -rf "$TEMP_DIR"
    echo "Copilot setup complete."
}

setup_antigravity() {
    echo "--- Setting up Antigravity CLI ---"
    link_dotfile "$DOTFILES_DIR/.config/copilot/skills" "$AGY_CONFIG_DIR/skills"
    link_dotfile "$DOTFILES_DIR/.config/copilot/standards" "$AGY_CONFIG_DIR/standards"
    
    echo "Dynamically syncing maister repository for Antigravity..."
    local TEMP_DIR=$(mktemp -d)
    trap 'rm -rf "$TEMP_DIR"' EXIT
    git clone --depth 1 https://github.com/SkillPanel/maister.git "$TEMP_DIR" > /dev/null 2>&1
    
    local AGY_PLUGIN_DIR="$AGY_CONFIG_DIR/plugins/maister"
    mkdir -p "$AGY_PLUGIN_DIR"
    cp -R "$TEMP_DIR/plugins/maister/"* "$AGY_PLUGIN_DIR/"
    
    if [ ! -f "$AGY_PLUGIN_DIR/plugin.json" ]; then
        echo '{"name": "maister"}' > "$AGY_PLUGIN_DIR/plugin.json"
    fi
    
    trap - EXIT
    rm -rf "$TEMP_DIR"
    echo "Antigravity setup complete."
}

main() {
    echo "Initializing dotfiles..."

    setup_bash
    setup_copilot
    setup_antigravity

    echo -e "\nDone! Please run the following command to apply changes to your current terminal:"
    echo "  source ~/.bashrc"
}

main
