# .zshrc

# Function to find dotfiles directory
find_dotfiles_dir() {
    # First check if it's already set
    if [ -n "${DOTFILES_DIR:-}" ] && [ -d "$DOTFILES_DIR" ]; then
        echo "$DOTFILES_DIR"
        return 0
    fi

    # Common locations to check
    local common_locations=(
        "$HOME/Projects/dotfiles"
        "$HOME/dotfiles"
        "$HOME/.dotfiles"
        "/Users/mmock/Projects/dotfiles"  # Fallback for your specific setup
    )

    # Check each location
    for dir in "${common_locations[@]}"; do
        if [ -d "$dir" ] && [ -f "$dir/zsh/.zshrc" ]; then
            echo "$dir"
            return 0
        fi
    done

    # If we're in a git repository, check if it's the dotfiles repo
    if command -v git >/dev/null 2>&1; then
        local git_dir
        git_dir=$(git rev-parse --git-dir 2>/dev/null)
        if [ -n "$git_dir" ]; then
            local repo_root
            repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
            if [ -n "$repo_root" ] && [ -f "$repo_root/zsh/.zshrc" ]; then
                echo "$repo_root"
                return 0
            fi
        fi
    fi

    return 1
}

# Set DOTFILES_DIR
export DOTFILES_DIR=$(find_dotfiles_dir)

# Load editor configuration first
if [ -n "$DOTFILES_DIR" ] && [ -f "$DOTFILES_DIR/zsh/zsh-editor-config.zsh" ]; then
    source "$DOTFILES_DIR/zsh/zsh-editor-config.zsh"
fi

# Load Pure prompt if not in an editor workspace
if [ -z "${WORKSPACE_FOLDER:-}" ]; then
    autoload -U promptinit; promptinit
    prompt pure
fi

# Detect OS and set editor with fallback chain
case "$(uname -s)" in
    Darwin*)    # macOS
        export PATH="/usr/local/opt/openjdk/bin:$PATH"
        if command -v cursor &> /dev/null; then
            export EDITOR="cursor -w"
        elif command -v code &> /dev/null; then
            export EDITOR="code -w"
        else
            export EDITOR="vim"
        fi
        ;;
    Linux*)     # Linux
        if command -v cursor &> /dev/null; then
            export EDITOR="cursor -w"
        elif command -v code &> /dev/null; then
            export EDITOR="code -w"
        else
            export EDITOR="vim"
        fi
        ;;
esac

# Add local bin to PATH
export PATH="$HOME/.local/bin:$PATH"

# History configuration - only set if not in an editor workspace
if [ -z "${WORKSPACE_FOLDER:-}" ]; then
    HISTSIZE=10000
    SAVEHIST=10000
    HISTFILE=~/.zsh_history
    setopt HIST_IGNORE_DUPS
    setopt HIST_IGNORE_SPACE
    setopt HIST_VERIFY
    setopt SHARE_HISTORY
fi

# Load completion system
autoload -Uz compinit
compinit

# Completion configuration
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Directory navigation
setopt AUTO_CD
setopt EXTENDED_GLOB
setopt NO_CASE_GLOB
setopt NUMERIC_GLOB_SORT

# Load aliases and functions if they exist
[ -f ~/.zsh_aliases ] && source ~/.zsh_aliases
[ -f ~/.zsh_functions ] && source ~/.zsh_functions

# Initialize rbenv if it exists
if command -v rbenv &> /dev/null; then
    eval "$(rbenv init -)"
    export PATH="$HOME/.rbenv/bin:$PATH"
fi

# NVM setup
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Python development aliases
alias pip-update="pip install --upgrade \$(pip list --outdated | tail -n +3 | cut -d\" \" -f1)"

# Oh My Zsh plugins
plugins=(
  zsh-autosuggestions
  zsh-syntax-highlighting
)

# Manually load plugins if they exist
if [ -f "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
    source ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

if [ -f "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
    source ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
fpath+=$HOME/.zsh/pure
autoload -U promptinit; promptinit
prompt pure
