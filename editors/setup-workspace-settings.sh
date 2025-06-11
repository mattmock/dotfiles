#!/bin/bash

# Script to set up VS Code/Cursor workspace settings for a project
# Usage: ./setup-workspace-settings.sh [project_path]
# If no project path is provided, uses current directory

PROJECT_PATH=${1:-$(pwd)}
SETTINGS_FILE="$PROJECT_PATH/.vscode/settings.json"

# Create .vscode directory if it doesn't exist
mkdir -p "$PROJECT_PATH/.vscode"

# Create or update settings.json
cat > "$SETTINGS_FILE" << 'EOF'
{
    "terminal.integrated.env.osx": {
        "WORKSPACE_FOLDER": "${workspaceFolder}",
        "VSCODE_WORKSPACE": "${workspaceFolder}",
        "CURSOR_WORKSPACE": "${workspaceFolder}"
    },
    "terminal.integrated.env.linux": {
        "WORKSPACE_FOLDER": "${workspaceFolder}",
        "VSCODE_WORKSPACE": "${workspaceFolder}",
        "CURSOR_WORKSPACE": "${workspaceFolder}"
    },
    "terminal.integrated.env.windows": {
        "WORKSPACE_FOLDER": "${workspaceFolder}",
        "VSCODE_WORKSPACE": "${workspaceFolder}",
        "CURSOR_WORKSPACE": "${workspaceFolder}"
    },
    "terminal.integrated.inheritEnv": false
}
EOF

echo "Workspace settings have been set up in $SETTINGS_FILE"
echo "Please restart VS Code/Cursor and open a new terminal to verify the environment variables are set." 