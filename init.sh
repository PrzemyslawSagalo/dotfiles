#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BASHRC="$HOME/.bashrc"
ALIAS_TARGET="$HOME/.bash_aliases"
COPILOT_TARGET="$HOME/.config/copilot"
AGY_CONFIG_DIR="$HOME/.gemini/config"
MAISTER_REPO_DIR="$HOME/.config/maister_repo"

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

download_maister() {
    echo "--- Syncing maister repository to host ---"
    mkdir -p "$(dirname "$MAISTER_REPO_DIR")"
    
    # Remove old clone to ensure clean state
    if [ -d "$MAISTER_REPO_DIR" ]; then
        rm -rf "$MAISTER_REPO_DIR"
    fi
    
    git clone --depth 1 https://github.com/SkillPanel/maister.git "$MAISTER_REPO_DIR" > /dev/null 2>&1
}

setup_bash() {
    echo "--- Setting up Bash ---"
    link_dotfile "$DOTFILES_DIR/.bash_aliases" "$ALIAS_TARGET"
    ensure_in_bashrc "if [ -f $ALIAS_TARGET ]; then . $ALIAS_TARGET; fi" "Source custom aliases"
}

setup_copilot() {
    echo "--- Setting up GitHub Copilot CLI ---"
    
    # Create real directories to hold our symlinks
    mkdir -p "$COPILOT_TARGET/skills" "$COPILOT_TARGET/agents" "$COPILOT_TARGET/commands" "$COPILOT_TARGET/standards"
    
    # Symlink tracked files from dotfiles individually
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
    
    ensure_in_bashrc "export COPILOT_HOME=\"\$HOME/.config/copilot\"" "GitHub Copilot configuration"
    
    # Symlink dynamic components directly from the host's permanent clone
    if [ -d "$MAISTER_REPO_DIR/plugins/maister-copilot/skills" ]; then
        for skill in "$MAISTER_REPO_DIR/plugins/maister-copilot/skills/"*; do
            [ -e "$skill" ] || continue
            link_dotfile "$skill" "$COPILOT_TARGET/skills/$(basename "$skill")"
        done
    fi
    
    if [ -d "$MAISTER_REPO_DIR/plugins/maister-copilot/agents" ]; then
        for agent in "$MAISTER_REPO_DIR/plugins/maister-copilot/agents/"*; do
            [ -e "$agent" ] || continue
            link_dotfile "$agent" "$COPILOT_TARGET/agents/$(basename "$agent")"
        done
    fi
    
    if [ -d "$MAISTER_REPO_DIR/plugins/maister-copilot/commands" ]; then
        for cmd in "$MAISTER_REPO_DIR/plugins/maister-copilot/commands/"*; do
            [ -e "$cmd" ] || continue
            link_dotfile "$cmd" "$COPILOT_TARGET/commands/$(basename "$cmd")"
        done
    fi
    
    echo "Copilot setup complete."
}

setup_antigravity() {
    echo "--- Setting up Antigravity CLI ---"
    link_dotfile "$DOTFILES_DIR/.config/copilot/skills" "$AGY_CONFIG_DIR/skills"
    link_dotfile "$DOTFILES_DIR/.config/copilot/standards" "$AGY_CONFIG_DIR/standards"
    
    local AGY_PLUGIN_DIR="$AGY_CONFIG_DIR/plugins/maister"
    
    # Symlink the entire plugin bundle from the permanent clone
    link_dotfile "$MAISTER_REPO_DIR/plugins/maister" "$AGY_PLUGIN_DIR"
    
    if [ ! -f "$AGY_PLUGIN_DIR/plugin.json" ]; then
        echo '{"name": "maister"}' > "$AGY_PLUGIN_DIR/plugin.json"
    fi
    
    echo "Antigravity setup complete."
}

main() {
    echo "Initializing dotfiles..."

    download_maister
    setup_bash
    setup_copilot
    setup_antigravity

    echo -e "\nDone! Please run the following command to apply changes to your current terminal:"
    echo "  source ~/.bashrc"
}

main
