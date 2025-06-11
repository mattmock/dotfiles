#!/bin/bash

# Exit on error
set -e

# Get the directory where the script is located
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Function to backup and create symlink
setup_symlink() {
    local source="$1"
    local target="$2"
    
    # Backup existing file if it exists and is not a symlink
    if [ -f "$target" ] && [ ! -L "$target" ]; then
        echo "Backing up $target to ${target}.backup"
        mv "$target" "${target}.backup"
    fi
    
    # Remove existing symlink if it exists
    if [ -L "$target" ]; then
        echo "Removing existing symlink: $target"
        rm "$target"
    fi
    
    # Create new symlink
    echo "Creating symlink: $target -> $source"
    ln -s "$source" "$target"
}

# Create symlinks
setup_symlink "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
setup_symlink "$DOTFILES_DIR/zsh/.zsh_aliases" "$HOME/.zsh_aliases"
setup_symlink "$DOTFILES_DIR/zsh/.zsh_functions" "$HOME/.zsh_functions"
setup_symlink "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
setup_symlink "$DOTFILES_DIR/hyper/.hyper.js" "$HOME/.hyper.js"
setup_symlink "$DOTFILES_DIR/editors/vscode/settings.json" "$HOME/Library/Application Support/Code/User/settings.json"
setup_symlink "$DOTFILES_DIR/editors/cursor/settings.json" "$HOME/Library/Application Support/Cursor/User/settings.json"

echo "Symlinks have been set up successfully!"
echo "Please restart your terminal and VS Code to apply the changes." 