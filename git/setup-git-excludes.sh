#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# Path to the global gitignore file
GLOBAL_GITIGNORE="$DOTFILES_DIR/git/.gitignore_global"

# Set the global excludes file
git config --global core.excludesfile "$GLOBAL_GITIGNORE"

echo "Global Git excludes file has been set to: $GLOBAL_GITIGNORE"
echo "The following patterns will be ignored in all Git repositories:"
echo "----------------------------------------"
cat "$GLOBAL_GITIGNORE"
echo "----------------------------------------" 