#!/bin/bash

# Exit on error, undefined variable, and pipe failure
set -euo pipefail

# Get the directory where the script is located
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Function to handle errors with more detail
handle_error() {
    local line_no=$1
    local error_code=$2
    echo "❌ Error on line $line_no (exit code: $error_code)"
    echo "   Command: $(sed -n "${line_no}p" "$0")"
    exit 1
}

# Set up error handling
trap 'handle_error $LINENO $?' ERR

# Function to backup existing files
backup_file() {
    local file="$1"
    if [ -f "$file" ]; then
        echo "📦 Backing up $file to ${file}.backup"
        mv "$file" "${file}.backup"
    fi
}

# Function to check zsh version
check_zsh_version() {
    if command -v zsh &> /dev/null; then
        ZSH_VERSION=$(zsh --version | cut -d' ' -f2)
        if [ "${ZSH_VERSION%%.*}" -lt 5 ]; then
            echo "⚠️  Warning: zsh version 5.0 or higher recommended"
            echo "   Current version: $ZSH_VERSION"
            echo "   Some features may not work correctly"
        fi
    fi
}

# Function to clean up old files
cleanup() {
    echo "🧹 Cleaning up old files..."
    
    # Remove old symlinks
    local files=(
        "$HOME/.zshrc"
        "$HOME/.zsh_aliases"
        "$HOME/.zsh_functions"
        "$HOME/.gitconfig"
        "$HOME/.hyper.js"
        "$HOME/Library/Application Support/Code/User/settings.json"
        "$HOME/Library/Application Support/Cursor/User/settings.json"
    )
    
    for file in "${files[@]}"; do
        if [ -L "$file" ]; then
            echo "   Removing old symlink: $file"
            rm "$file"
        fi
    done
    
    # Remove old backups older than 30 days
    echo "   Removing backups older than 30 days..."
    find "$HOME" -maxdepth 1 -name ".*.backup" -mtime +30 -delete
}

# Check for required dependencies
echo "🔍 Checking dependencies..."

# Check for zsh, install if missing
if ! command -v zsh &> /dev/null; then
    echo "Zsh not found. Installing..."
    if command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y zsh
    elif command -v brew &> /dev/null; then
        brew install zsh
    else
        echo "Please install zsh manually."
        exit 1
    fi
fi

# Ensure ~/.local/bin is in PATH
if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    export PATH="$HOME/.local/bin:$PATH"
fi

# Install Pure prompt if missing
if [ ! -d "$HOME/.zsh/pure" ]; then
    git clone https://github.com/sindresorhus/pure.git "$HOME/.zsh/pure"
fi
if ! grep -q 'fpath+=$HOME/.zsh/pure' "$HOME/.zshrc" 2>/dev/null; then
    echo 'fpath+=$HOME/.zsh/pure' >> "$HOME/.zshrc"
    echo 'autoload -U promptinit; promptinit' >> "$HOME/.zshrc"
    echo 'prompt pure' >> "$HOME/.zshrc"
fi

# Create empty .zsh_aliases and .zsh_functions if missing in dotfiles repo
[ -f "$DOTFILES_DIR/zsh/.zsh_aliases" ] || touch "$DOTFILES_DIR/zsh/.zsh_aliases"
[ -f "$DOTFILES_DIR/zsh/.zsh_functions" ] || touch "$DOTFILES_DIR/zsh/.zsh_functions"

# Create .zsh_env from example if missing in home directory
if [ ! -f "$HOME/.zsh_env" ]; then
    if [ -f "$DOTFILES_DIR/zsh/.zsh_env.example" ]; then
        echo "📝 Creating ~/.zsh_env from example..."
        cp "$DOTFILES_DIR/zsh/.zsh_env.example" "$HOME/.zsh_env"
        echo "   ⚠️  Please edit ~/.zsh_env with your actual GitHub account mappings"
    else
        echo "⚠️  Warning: .zsh_env.example not found in dotfiles"
    fi
fi

# Prompt to set zsh as default shell
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "Setting Zsh as your default shell..."
    chsh -s "$(which zsh)"
fi

# Check for git
if ! command -v git &> /dev/null; then
    echo "❌ Error: git is not installed"
    echo "   Please install git first:"
    echo "   - macOS: brew install git"
    echo "   - Linux: sudo apt-get install git"
    exit 1
fi

# Check for package manager
if [[ "$OSTYPE" == "darwin"* ]]; then
    if ! command -v brew &> /dev/null; then
        echo "⚠️  Warning: Homebrew is not installed"
        echo "   Some features may not work correctly"
        echo "   Install with: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if ! command -v apt-get &> /dev/null; then
        echo "⚠️  Warning: apt-get is not available"
        echo "   Some features may not work correctly"
    fi
fi

# Check for editors
if [[ "$OSTYPE" == "darwin"* ]]; then
    if ! command -v code &> /dev/null; then
        echo "⚠️  Warning: VS Code is not installed"
        echo "   Install from: https://code.visualstudio.com/"
    fi
    if ! command -v cursor &> /dev/null; then
        echo "⚠️  Warning: Cursor editor is not installed"
        echo "   Install from: https://cursor.sh/"
    fi
fi

# Create necessary directories
echo "📁 Creating directories..."
mkdir -p ~/.local/bin
mkdir -p ~/.oh-my-zsh/custom/plugins
mkdir -p "$HOME/Library/Application Support/Code/User"
mkdir -p "$HOME/Library/Application Support/Cursor/User"
mkdir -p "$HOME/.config/editor-history"

# Clean up old symlinks first
cleanup

# Backup existing files
echo "📦 Backing up existing files..."
backup_file "$HOME/.zshrc"
backup_file "$HOME/.zsh_aliases"
backup_file "$HOME/.zsh_functions"
backup_file "$HOME/.gitconfig"
backup_file "$HOME/.hyper.js"
backup_file "$HOME/Library/Application Support/Code/User/settings.json"
backup_file "$HOME/Library/Application Support/Code/User/keybindings.json"
backup_file "$HOME/Library/Application Support/Cursor/User/settings.json"
backup_file "$HOME/Library/Application Support/Cursor/User/keybindings.json"

# Create symlinks
echo "🔗 Creating symlinks..."
ln -sf "$DOTFILES_DIR/zsh/.zshrc" ~/.zshrc
ln -sf "$DOTFILES_DIR/zsh/.zsh_aliases" ~/.zsh_aliases
ln -sf "$DOTFILES_DIR/zsh/.zsh_functions" ~/.zsh_functions
ln -sf "$DOTFILES_DIR/git/.gitconfig" ~/.gitconfig
ln -sf "$DOTFILES_DIR/git/.gitignore_global" ~/.gitignore_global
ln -sf "$DOTFILES_DIR/hyper/.hyper.js" ~/.hyper.js
ln -sf "$DOTFILES_DIR/editors/vscode/settings.json" "$HOME/Library/Application Support/Code/User/settings.json"
ln -sf "$DOTFILES_DIR/editors/vscode/keybindings.json" "$HOME/Library/Application Support/Code/User/keybindings.json"
ln -sf "$DOTFILES_DIR/editors/cursor/settings.json" "$HOME/Library/Application Support/Cursor/User/settings.json"
ln -sf "$DOTFILES_DIR/editors/cursor/keybindings.json" "$HOME/Library/Application Support/Cursor/User/keybindings.json"

# Install Git scripts globally
echo "📜 Installing Git scripts..."
for script in "$DOTFILES_DIR/git/scripts/"*.sh; do
    if [ -f "$script" ]; then
        script_name=$(basename "$script" .sh)
        echo "   Installing git-$script_name..."
        ln -sf "$script" ~/.local/bin/git-"$script_name"
        chmod +x ~/.local/bin/git-"$script_name"
    fi
done

# Install Oh My Zsh if not already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "📦 Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install Oh My Zsh plugins if not already installed
echo "🔌 Installing Oh My Zsh plugins..."
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    echo "   Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
fi

if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
    echo "   Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
fi

# Add terminal history configuration to .zshrc if not already present
if ! grep -q "zsh-editor-config.zsh" ~/.zshrc; then
    echo "📝 Adding terminal history configuration to .zshrc..."
fi

echo "✅ Installation complete!"
echo ""
echo "⚠️  IMPORTANT: Git Identity Configuration"
echo "   If you use multiple Git accounts (personal/work), set up ~/.gitconfig.local"
echo "   See the 'Multiple Git Identities' section in README.md for instructions"
echo "   Example file: git/.gitconfig.local.example"
echo ""
echo "   Please restart your shell to apply changes."
echo "   If you encounter any issues, check the troubleshooting section in SETUP.md" 