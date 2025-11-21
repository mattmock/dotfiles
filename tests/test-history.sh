#!/bin/bash

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TEST_DIR=$(mktemp -d -t dotfiles-history-test-XXXXXX)

echo "🧪 Testing Project-Specific History Feature"
echo "============================================"
echo "Test directory: $TEST_DIR"
echo ""

cleanup() {
    echo ""
    echo "🧹 Cleaning up test directory..."
    rm -rf "$TEST_DIR"
    echo "✅ Cleanup complete"
}

trap cleanup EXIT

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

test_result() {
    local test_name="$1"
    local passed="$2"
    
    if [ "$passed" -eq 1 ]; then
        echo "✅ PASS: $test_name"
        ((TESTS_PASSED++))
    else
        echo "❌ FAIL: $test_name"
        ((TESTS_FAILED++))
    fi
}

# Function to test in zsh
test_in_zsh() {
    local test_script="$1"
    zsh -c "$test_script"
}

# Test 1: Create a test project with .git marker
echo "Test 1: Project with .git marker"
PROJECT1="$TEST_DIR/project1"
mkdir -p "$PROJECT1"
cd "$PROJECT1" || exit 1
git init --quiet >/dev/null 2>&1 || true
echo "test file" > test.txt

TEST1_SCRIPT="
export WORKSPACE_FOLDER='$PROJECT1'
export VSCODE_WORKSPACE='$PROJECT1'
export CURSOR_WORKSPACE='$PROJECT1'
export DOTFILES_DIR='$DOTFILES_DIR'
cd '$PROJECT1'
source '$DOTFILES_DIR/zsh/zsh-editor-config.zsh' 2>/dev/null || true
if [ -f '.config/editor-history/.zsh_history' ]; then
    exit 0
else
    exit 1
fi
"

if test_in_zsh "$TEST1_SCRIPT" >/dev/null 2>&1; then
    test_result "Project with .git - history file created" 1
else
    test_result "Project with .git - history file created" 0
fi

# Test 2: Create a test project with package.json
echo ""
echo "Test 2: Project with package.json marker"
PROJECT2="$TEST_DIR/project2"
mkdir -p "$PROJECT2"
cd "$PROJECT2" || exit 1
echo '{"name": "test-project"}' > package.json

TEST2_SCRIPT="
export WORKSPACE_FOLDER='$PROJECT2'
export VSCODE_WORKSPACE='$PROJECT2'
export CURSOR_WORKSPACE='$PROJECT2'
export DOTFILES_DIR='$DOTFILES_DIR'
unset _ZSH_EDITOR_CONFIG_LOADED
cd '$PROJECT2'
source '$DOTFILES_DIR/zsh/zsh-editor-config.zsh' 2>/dev/null || true
if [ -f '.config/editor-history/.zsh_history' ]; then
    exit 0
else
    exit 1
fi
"

if test_in_zsh "$TEST2_SCRIPT" >/dev/null 2>&1; then
    test_result "Project with package.json - history file created" 1
else
    test_result "Project with package.json - history file created" 0
fi

# Test 3: Test without editor environment variables (should NOT create project history)
echo ""
echo "Test 3: Regular terminal should NOT create project history (no editor env vars)"
PROJECT3="$TEST_DIR/project3"
mkdir -p "$PROJECT3"
cd "$PROJECT3" || exit 1
git init --quiet >/dev/null 2>&1 || true

TEST3_SCRIPT="
export DOTFILES_DIR='$DOTFILES_DIR'
unset WORKSPACE_FOLDER
unset VSCODE_WORKSPACE
unset CURSOR_WORKSPACE
unset _ZSH_EDITOR_CONFIG_LOADED
cd '$PROJECT3'
source '$DOTFILES_DIR/zsh/zsh-editor-config.zsh' 2>/dev/null || true
# Should NOT create project history file - should use global history instead
if [ ! -f '.config/editor-history/.zsh_history' ]; then
    exit 0
else
    exit 1
fi
"

if test_in_zsh "$TEST3_SCRIPT" >/dev/null 2>&1; then
    test_result "Regular terminal does NOT create project history" 1
else
    test_result "Regular terminal does NOT create project history" 0
fi

# Test 4: Test history file in project root (not subdirectory)
echo ""
echo "Test 4: History file location in project root"
PROJECT4="$TEST_DIR/project4"
mkdir -p "$PROJECT4/src/components"
cd "$PROJECT4" || exit 1
git init --quiet >/dev/null 2>&1 || true

TEST4_SCRIPT="
export WORKSPACE_FOLDER='$PROJECT4'
export VSCODE_WORKSPACE='$PROJECT4'
export CURSOR_WORKSPACE='$PROJECT4'
export DOTFILES_DIR='$DOTFILES_DIR'
unset _ZSH_EDITOR_CONFIG_LOADED
cd '$PROJECT4'
source '$DOTFILES_DIR/zsh/zsh-editor-config.zsh' 2>/dev/null || true
if [ -f '$PROJECT4/.config/editor-history/.zsh_history' ] && [ ! -f '$PROJECT4/src/components/.config/editor-history/.zsh_history' ]; then
    exit 0
else
    exit 1
fi
"

if test_in_zsh "$TEST4_SCRIPT" >/dev/null 2>&1; then
    test_result "History file in project root (not subdirectory)" 1
else
    test_result "History file in project root (not subdirectory)" 0
fi

# Test 5: Test HISTFILE variable is set correctly
echo ""
echo "Test 5: HISTFILE variable is set correctly"
PROJECT5="$TEST_DIR/project5"
mkdir -p "$PROJECT5"
cd "$PROJECT5" || exit 1
git init --quiet >/dev/null 2>&1 || true

TEST5_SCRIPT="
export WORKSPACE_FOLDER='$PROJECT5'
export VSCODE_WORKSPACE='$PROJECT5'
export CURSOR_WORKSPACE='$PROJECT5'
export DOTFILES_DIR='$DOTFILES_DIR'
unset _ZSH_EDITOR_CONFIG_LOADED
unset HISTFILE
cd '$PROJECT5'
source '$DOTFILES_DIR/zsh/zsh-editor-config.zsh' 2>/dev/null || true
EXPECTED='$PROJECT5/.config/editor-history/.zsh_history'
if [ \"\${HISTFILE:-}\" = \"\$EXPECTED\" ]; then
    exit 0
else
    echo \"Expected: \$EXPECTED\"
    echo \"Got: \${HISTFILE:-not set}\"
    exit 1
fi
"

if test_in_zsh "$TEST5_SCRIPT" >/dev/null 2>&1; then
    test_result "HISTFILE variable set correctly" 1
else
    HISTFILE_OUTPUT=$(test_in_zsh "$TEST5_SCRIPT" 2>&1 || true)
    echo "   $HISTFILE_OUTPUT"
    test_result "HISTFILE variable set correctly" 0
fi

# Test 6: Test history file is writable
echo ""
echo "Test 6: History file is writable and can store commands"
PROJECT6="$TEST_DIR/project6"
mkdir -p "$PROJECT6"
cd "$PROJECT6" || exit 1
git init --quiet >/dev/null 2>&1 || true

TEST6_SCRIPT="
export WORKSPACE_FOLDER='$PROJECT6'
export VSCODE_WORKSPACE='$PROJECT6'
export CURSOR_WORKSPACE='$PROJECT6'
export DOTFILES_DIR='$DOTFILES_DIR'
unset _ZSH_EDITOR_CONFIG_LOADED
unset HISTFILE
cd '$PROJECT6'
source '$DOTFILES_DIR/zsh/zsh-editor-config.zsh' 2>/dev/null || true
if [ -n \"\${HISTFILE:-}\" ] && [ -f \"\$HISTFILE\" ]; then
    echo ': 1234567890:0;echo test command 1' >> \"\$HISTFILE\"
    echo ': 1234567891:0;echo test command 2' >> \"\$HISTFILE\"
    if [ -s \"\$HISTFILE\" ]; then
        exit 0
    else
        exit 1
    fi
else
    exit 1
fi
"

if test_in_zsh "$TEST6_SCRIPT" >/dev/null 2>&1; then
    test_result "History file is writable and stores commands" 1
else
    test_result "History file is writable and stores commands" 0
fi

# Test 7: Test that different projects have separate histories
echo ""
echo "Test 7: Different projects have separate history files"
PROJECT7A="$TEST_DIR/project7a"
PROJECT7B="$TEST_DIR/project7b"
mkdir -p "$PROJECT7A" "$PROJECT7B"
cd "$PROJECT7A" || exit 1
git init --quiet >/dev/null 2>&1 || true
cd "$PROJECT7B" || exit 1
git init --quiet >/dev/null 2>&1 || true

TEST7_SCRIPT="
export DOTFILES_DIR='$DOTFILES_DIR'
unset _ZSH_EDITOR_CONFIG_LOADED
unset HISTFILE

cd '$PROJECT7A'
export WORKSPACE_FOLDER='$PROJECT7A'
source '$DOTFILES_DIR/zsh/zsh-editor-config.zsh' 2>/dev/null || true
HISTFILE_A=\"\${HISTFILE:-}\"

unset _ZSH_EDITOR_CONFIG_LOADED
unset HISTFILE

cd '$PROJECT7B'
export WORKSPACE_FOLDER='$PROJECT7B'
source '$DOTFILES_DIR/zsh/zsh-editor-config.zsh' 2>/dev/null || true
HISTFILE_B=\"\${HISTFILE:-}\"

if [ -n \"\$HISTFILE_A\" ] && [ -n \"\$HISTFILE_B\" ] && [ \"\$HISTFILE_A\" != \"\$HISTFILE_B\" ]; then
    exit 0
else
    echo \"Project A HISTFILE: \$HISTFILE_A\"
    echo \"Project B HISTFILE: \$HISTFILE_B\"
    exit 1
fi
"

if test_in_zsh "$TEST7_SCRIPT" >/dev/null 2>&1; then
    test_result "Different projects have separate history files" 1
else
    SEPARATE_OUTPUT=$(test_in_zsh "$TEST7_SCRIPT" 2>&1 || true)
    echo "   $SEPARATE_OUTPUT"
    test_result "Different projects have separate history files" 0
fi

# Test 8: Test that home directory doesn't get project history
echo ""
echo "Test 8: Home directory doesn't create project history"
TEST8_SCRIPT="
export DOTFILES_DIR='$DOTFILES_DIR'
export WORKSPACE_FOLDER=\"\$HOME\"
unset _ZSH_EDITOR_CONFIG_LOADED
unset HISTFILE
cd \"\$HOME\"
source '$DOTFILES_DIR/zsh/zsh-editor-config.zsh' 2>/dev/null || true
# Even if WORKSPACE_FOLDER is set to HOME, we should NOT set HISTFILE to project history
# The check [ \"\$WORKSPACE_PATH\" != \"\$HOME\" ] should prevent this
# Check that HISTFILE is NOT set to a project history path (should use global history instead)
if [ -z \"\${HISTFILE:-}\" ] || [ \"\${HISTFILE:-}\" != \"\$HOME/.config/editor-history/.zsh_history\" ]; then
    exit 0
else
    echo \"HISTFILE incorrectly set to: \${HISTFILE:-not set}\"
    exit 1
fi
"

if test_in_zsh "$TEST8_SCRIPT" >/dev/null 2>&1; then
    test_result "Home directory doesn't create project history" 1
else
    test_result "Home directory doesn't create project history" 0
fi

# Test 9: Test environment variable priority
echo ""
echo "Test 9: Environment variable priority (CURSOR_WORKSPACE takes priority)"
PROJECT9="$TEST_DIR/project9"
mkdir -p "$PROJECT9"
cd "$PROJECT9" || exit 1
git init --quiet >/dev/null 2>&1 || true

TEST9_SCRIPT="
export DOTFILES_DIR='$DOTFILES_DIR'
export CURSOR_WORKSPACE='$PROJECT9'
export VSCODE_WORKSPACE='$TEST_DIR/wrong'
export WORKSPACE_FOLDER='$TEST_DIR/also-wrong'
unset _ZSH_EDITOR_CONFIG_LOADED
unset HISTFILE
cd '$PROJECT9'
source '$DOTFILES_DIR/zsh/zsh-editor-config.zsh' 2>/dev/null || true
EXPECTED='$PROJECT9/.config/editor-history/.zsh_history'
if [ \"\${HISTFILE:-}\" = \"\$EXPECTED\" ]; then
    exit 0
else
    echo \"Expected: \$EXPECTED\"
    echo \"Got: \${HISTFILE:-not set}\"
    exit 1
fi
"

if test_in_zsh "$TEST9_SCRIPT" >/dev/null 2>&1; then
    test_result "CURSOR_WORKSPACE takes priority" 1
else
    PRIORITY_OUTPUT=$(test_in_zsh "$TEST9_SCRIPT" 2>&1 || true)
    echo "   $PRIORITY_OUTPUT"
    test_result "CURSOR_WORKSPACE takes priority" 0
fi

# Summary
echo ""
echo "============================================"
echo "Test Summary"
echo "============================================"
echo "✅ Tests passed: $TESTS_PASSED"
echo "❌ Tests failed: $TESTS_FAILED"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo "🎉 All tests passed!"
    exit 0
else
    echo "⚠️  Some tests failed. Please review the output above."
    exit 1
fi
