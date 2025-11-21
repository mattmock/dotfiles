#!/bin/bash

echo "=== Project-Specific History Diagnostic ==="
echo ""

echo "1. Checking environment variables:"
echo "   WORKSPACE_FOLDER: ${WORKSPACE_FOLDER:-NOT SET}"
echo "   VSCODE_WORKSPACE: ${VSCODE_WORKSPACE:-NOT SET}"
echo "   CURSOR_WORKSPACE: ${CURSOR_WORKSPACE:-NOT SET}"
echo ""

echo "2. Checking DOTFILES_DIR:"
echo "   DOTFILES_DIR: ${DOTFILES_DIR:-NOT SET}"
echo ""

echo "3. Checking if zsh-editor-config.zsh exists:"
if [ -n "${DOTFILES_DIR:-}" ] && [ -f "$DOTFILES_DIR/zsh/zsh-editor-config.zsh" ]; then
    echo "   ✓ Found at: $DOTFILES_DIR/zsh/zsh-editor-config.zsh"
else
    echo "   ✗ NOT FOUND"
    if [ -n "${DOTFILES_DIR:-}" ]; then
        echo "   DOTFILES_DIR is set but file doesn't exist"
    fi
fi
echo ""

echo "4. Checking current directory and project root detection:"
echo "   PWD: $PWD"
if [ -d ".git" ] || [ -f "package.json" ] || [ -f ".project" ]; then
    echo "   ✓ Project markers found (this looks like a project root)"
else
    echo "   ⚠ No project markers found in current directory"
fi
echo ""

echo "5. Checking history file location:"
if [ -n "${HISTFILE:-}" ]; then
    echo "   HISTFILE: $HISTFILE"
    if [ -f "$HISTFILE" ]; then
        echo "   ✓ History file exists"
        echo "   Size: $(stat -f%z "$HISTFILE" 2>/dev/null || echo "unknown") bytes"
    else
        echo "   ✗ History file does not exist"
    fi
else
    echo "   ✗ HISTFILE is not set"
fi
echo ""

echo "6. Checking for .config/editor-history directory:"
if [ -d ".config/editor-history" ]; then
    echo "   ✓ Directory exists"
    ls -lah .config/editor-history/ 2>/dev/null || echo "   (empty or inaccessible)"
else
    echo "   ✗ Directory does not exist"
fi
echo ""

echo "7. Checking if zsh-editor-config was loaded:"
if [ -n "${_ZSH_EDITOR_CONFIG_LOADED:-}" ]; then
    echo "   ✓ zsh-editor-config.zsh was loaded"
else
    echo "   ✗ zsh-editor-config.zsh was NOT loaded"
fi
echo ""

echo "8. Testing workspace path detection:"
if [ -n "${DOTFILES_DIR:-}" ] && [ -f "$DOTFILES_DIR/zsh/zsh-editor-config.zsh" ]; then
    source "$DOTFILES_DIR/zsh/zsh-editor-config.zsh" 2>&1 | head -5
    if [ -n "${WORKSPACE_PATH:-}" ]; then
        echo "   WORKSPACE_PATH: $WORKSPACE_PATH"
    else
        echo "   ✗ WORKSPACE_PATH not set"
    fi
fi
echo ""

echo "=== Diagnostic Complete ==="

