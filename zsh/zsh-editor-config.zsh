# Guard against multiple sourcing
if [ -n "${_ZSH_EDITOR_CONFIG_LOADED:-}" ]; then
    return
fi

# Set the guard variable
_ZSH_EDITOR_CONFIG_LOADED=1

if [ -z "${DOTFILES_DIR:-}" ]; then
    return 1
fi

# Function to find project root
find_project_root() {
    local dir="$PWD"
    while [ "$dir" != "/" ]; do
        # Check for common project markers
        if [ -d "$dir/.git" ] || [ -f "$dir/package.json" ] || [ -f "$dir/.project" ]; then
            echo "$dir"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    return 1
}

# Function to validate workspace path
validate_workspace_path() {
    local path="$1"
    if [ -d "$path" ] && [ -w "$path" ]; then
        return 0
    fi
    return 1
}

# Function to detect workspace path
detect_workspace_path() {
    # Try editor-specific variables first
    if [ -n "${CURSOR_WORKSPACE:-}" ]; then
        validate_workspace_path "$CURSOR_WORKSPACE" && echo "$CURSOR_WORKSPACE" && return 0
    fi
    
    if [ -n "${VSCODE_WORKSPACE:-}" ]; then
        validate_workspace_path "$VSCODE_WORKSPACE" && echo "$VSCODE_WORKSPACE" && return 0
    fi
    
    if [ -n "${WORKSPACE_FOLDER:-}" ]; then
        validate_workspace_path "$WORKSPACE_FOLDER" && echo "$WORKSPACE_FOLDER" && return 0
    fi
    
    # If no editor variables, try to find project root
    local project_root
    project_root=$(find_project_root)
    if [ -n "$project_root" ]; then
        echo "$project_root"
        return 0
    fi
    
    # Fallback to current directory
    echo "$PWD"
    return 0
}

# Function to get editor name
get_editor_name() {
    if [ -n "${CURSOR_WORKSPACE:-}" ]; then
        echo "Cursor"
    elif [ -n "${VSCODE_WORKSPACE:-}" ]; then
        echo "VS Code"
    else
        echo "Terminal"
    fi
}

# Function to manage history file
manage_history_file() {
    local history_file="$1"
    local history_dir=$(dirname "$history_file")
    
    # Create history directory if it doesn't exist
    if [ ! -d "$history_dir" ]; then
        mkdir -p "$history_dir"
    fi
    
    # Create history file if it doesn't exist
    if [ ! -f "$history_file" ]; then
        touch "$history_file"
    fi
    
    # Set proper permissions
    chmod 600 "$history_file"
    
    # Check file size and create backup if needed (10MB limit)
    if [ -f "$history_file" ] && [ $(stat -f%z "$history_file") -gt 10485760 ]; then
        local backup_file="${history_file}.$(date +%Y%m%d%H%M%S).backup"
        mv "$history_file" "$backup_file"
        touch "$history_file"
        chmod 600 "$history_file"
        
        # Clean up old backups (keep last 5)
        if [ -d "$history_dir" ]; then
            find "$history_dir" -name ".zsh_history.*.backup" -type f -print0 2>/dev/null | \
            xargs -0 ls -t 2>/dev/null | \
            tail -n +6 | \
            xargs -r rm -f 2>/dev/null
        fi
    fi
}

# Get workspace path
WORKSPACE_PATH=$(detect_workspace_path)

if [ -n "$WORKSPACE_PATH" ]; then
    HISTORY_DIR="$WORKSPACE_PATH/.config/editor-history"
    HISTORY_FILE="$HISTORY_DIR/.zsh_history"
    
    manage_history_file "$HISTORY_FILE" 2>/dev/null
    
    HISTFILE="$HISTORY_FILE"
    HISTSIZE=10000
    SAVEHIST=10000
    
    setopt EXTENDED_HISTORY
    setopt HIST_IGNORE_DUPS
    setopt HIST_IGNORE_SPACE
    setopt HIST_VERIFY
    setopt INC_APPEND_HISTORY
    
    function precmd() {
        fc -W
    }
    
    fc -R 2>/dev/null
fi

fpath+=$HOME/.zsh/pure
autoload -U promptinit; promptinit
prompt pure 2>/dev/null || true 