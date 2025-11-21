# Guard against multiple sourcing
if [ -n "${_ZSH_EDITOR_CONFIG_LOADED:-}" ]; then
    return
fi

# Set the guard variable
_ZSH_EDITOR_CONFIG_LOADED=1

if [ -z "${DOTFILES_DIR:-}" ]; then
    return 1
fi

# Function to validate workspace path
validate_workspace_path() {
    local path="$1"
    if [ -d "$path" ] && [ -w "$path" ]; then
        return 0
    fi
    return 1
}

# Function to detect workspace path
# Only works in editor workspaces - returns empty if not in an editor
detect_workspace_path() {
    # Only use project history if explicitly in an editor workspace
    # Regular terminals should use global history
    if [ -n "${CURSOR_WORKSPACE:-}" ]; then
        validate_workspace_path "$CURSOR_WORKSPACE" && echo "$CURSOR_WORKSPACE" && return 0
    fi
    
    if [ -n "${VSCODE_WORKSPACE:-}" ]; then
        validate_workspace_path "$VSCODE_WORKSPACE" && echo "$VSCODE_WORKSPACE" && return 0
    fi
    
    if [ -n "${WORKSPACE_FOLDER:-}" ]; then
        validate_workspace_path "$WORKSPACE_FOLDER" && echo "$WORKSPACE_FOLDER" && return 0
    fi
    
    # Not in an editor workspace - return empty to use global history
    return 1
}

# Function to get file size (cross-platform)
get_file_size() {
    local file="$1"
    if [ ! -f "$file" ]; then
        echo "0"
        return
    fi
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        stat -f%z "$file" 2>/dev/null || echo "0"
    else
        stat -c%s "$file" 2>/dev/null || echo "0"
    fi
}

# Function to manage history file
manage_history_file() {
    local history_file="$1"
    local history_dir=$(dirname "$history_file")
    
    if [ -z "$history_file" ] || [ -z "$history_dir" ]; then
        return 1
    fi
    
    # Create history directory if it doesn't exist
    if [ ! -d "$history_dir" ]; then
        if ! mkdir -p "$history_dir" 2>/dev/null; then
            return 1
        fi
    fi
    
    # Create history file if it doesn't exist
    if [ ! -f "$history_file" ]; then
        if ! touch "$history_file" 2>/dev/null; then
            return 1
        fi
    fi
    
    # Set proper permissions
    chmod 600 "$history_file" 2>/dev/null
    
    # Check file size and create backup if needed (10MB limit)
    local file_size
    file_size=$(get_file_size "$history_file")
    if [ "$file_size" -gt 10485760 ]; then
        local backup_file="${history_file}.$(date +%Y%m%d%H%M%S).backup"
        mv "$history_file" "$backup_file" 2>/dev/null
        touch "$history_file" 2>/dev/null
        chmod 600 "$history_file" 2>/dev/null
        
        # Clean up old backups (keep last 5)
        if [ -d "$history_dir" ]; then
            find "$history_dir" -name ".zsh_history.*.backup" -type f -print0 2>/dev/null | \
            xargs -0 ls -t 2>/dev/null | \
            tail -n +6 | \
            xargs -r rm -f 2>/dev/null
        fi
    fi
    
    return 0
}

# Get workspace path (only set in editor workspaces)
WORKSPACE_PATH=$(detect_workspace_path 2>/dev/null || echo "")

# Only configure project-specific history if we're in an editor workspace
# Regular terminals will use global history from .zshrc
if [ -n "$WORKSPACE_PATH" ] && [ "$WORKSPACE_PATH" != "$HOME" ]; then
    HISTORY_DIR="$WORKSPACE_PATH/.config/editor-history"
    HISTORY_FILE="$HISTORY_DIR/.zsh_history"
    
    if manage_history_file "$HISTORY_FILE"; then
        HISTFILE="$HISTORY_FILE"
        HISTSIZE=10000
        SAVEHIST=10000
        
        setopt EXTENDED_HISTORY
        setopt HIST_IGNORE_ALL_DUPS
        setopt HIST_IGNORE_SPACE
        setopt HIST_VERIFY
        setopt HIST_SAVE_NO_DUPS
        setopt INC_APPEND_HISTORY
        setopt NO_SHARE_HISTORY
        setopt HIST_FCNTL_LOCK
        
        # Load existing history once at startup
        # HIST_IGNORE_ALL_DUPS and HIST_SAVE_NO_DUPS prevent duplicates
        if [ -f "$HISTFILE" ]; then
            fc -R "$HISTFILE" 2>/dev/null || true
        fi
        
        # Don't save on exit - INC_APPEND_HISTORY already writes each command immediately
        # Adding fc -W on exit would duplicate entries that were already written
    fi
fi 