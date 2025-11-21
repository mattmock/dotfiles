#!/bin/zsh

# Diagnostic tool to inspect history behavior
# Run this in your actual terminal to see what's happening

echo "=== History Inspection ==="
echo ""

echo "1. Current HISTFILE: ${HISTFILE:-not set}"
echo ""

if [ -n "${HISTFILE:-}" ]; then
    if [ -f "$HISTFILE" ]; then
        echo "2. History file exists: $HISTFILE"
        FILE_SIZE=$(wc -l < "$HISTFILE" 2>/dev/null || echo 0)
        echo "   File size: $FILE_SIZE lines"
        echo ""
        
        echo "3. Last 20 lines of history file:"
        tail -20 "$HISTFILE" | cat -n
        echo ""
        
        echo "4. Checking for duplicate lines in file:"
        DUPLICATE_LINES=$(sort "$HISTFILE" | uniq -d | wc -l | tr -d ' ')
        if [ "$DUPLICATE_LINES" -gt 0 ]; then
            echo "   ❌ Found $DUPLICATE_LINES duplicate lines!"
            echo "   First 10 duplicates:"
            sort "$HISTFILE" | uniq -d | head -10
        else
            echo "   ✅ No duplicate lines in file"
        fi
        echo ""
    else
        echo "2. History file does not exist"
        echo ""
    fi
    
    echo "5. History in memory (fc -l):"
    MEM_TOTAL=$(fc -l 2>/dev/null | wc -l | tr -d ' ' || echo 0)
    MEM_UNIQUE=$(fc -l 2>/dev/null | cut -d' ' -f4- | sort -u | wc -l | tr -d ' ' || echo 0)
    echo "   Total entries: $MEM_TOTAL"
    echo "   Unique entries: $MEM_UNIQUE"
    
    if [ "$MEM_TOTAL" -gt "$MEM_UNIQUE" ] && [ "$MEM_TOTAL" -gt 0 ]; then
        echo "   ❌ Found $((MEM_TOTAL - MEM_UNIQUE)) duplicate entries in memory!"
        echo "   Duplicate commands:"
        fc -l 2>/dev/null | cut -d' ' -f4- | sort | uniq -d | head -10
    else
        echo "   ✅ No duplicates in memory"
    fi
    echo ""
    
    echo "6. Last 20 history entries in memory:"
    fc -l -20 2>/dev/null | cat -n || echo "   (no history)"
    echo ""
else
    echo "2. HISTFILE not set - using global history"
    echo ""
fi

echo "7. History options:"
setopt | grep -i hist | sort
echo ""

echo "8. Environment variables:"
echo "   WORKSPACE_FOLDER: ${WORKSPACE_FOLDER:-not set}"
echo "   VSCODE_WORKSPACE: ${VSCODE_WORKSPACE:-not set}"
echo "   CURSOR_WORKSPACE: ${CURSOR_WORKSPACE:-not set}"
echo "   DOTFILES_DIR: ${DOTFILES_DIR:-not set}"
echo ""

echo "9. zsh-editor-config status:"
echo "   _ZSH_EDITOR_CONFIG_LOADED: ${_ZSH_EDITOR_CONFIG_LOADED:-not set}"
echo ""

echo "=== Inspection Complete ==="
echo ""
echo "To help debug:"
echo "1. Run this script BEFORE closing terminal"
echo "2. Close terminal"
echo "3. Reopen terminal"
echo "4. Run this script again"
echo "5. Compare the outputs"


