# WIP Workflow Troubleshooting Guide

This document covers common issues and solutions when using the WIP (Work In Progress) workflow management system.

## Issue: Running `git restore-wip` on Wrong Branch

### **What Happened:**
- User ran `git restore-wip` while on the WIP branch instead of the original branch
- The script deleted the WIP commits from the WIP branch
- User lost access to their saved work

### **Why It Happened:**
The `restore-wip` script is designed to work on the **original branch** where the WIP commits exist. When run on the WIP branch itself, it deletes the commits that contain the saved work.

### **How to Recreate:**
```bash
# 1. Save WIP work
git save-wip

# 2. Stay on WIP branch (don't switch back)
# 3. Try to restore (this will fail)
git restore-wip
```

### **Symptoms:**
- Error message: "No WIP commits found with staged/unstaged separation"
- WIP commits disappear from the WIP branch
- Work appears to be lost

### **Solution:**
1. **Find the commits in reflog:**
   ```bash
   git reflog --oneline -10
   ```

2. **Look for WIP commits:**
   ```
   3d16b293f WIP(unstaged): saving unstaged changes on feature/branch
   2b4cb7b48 WIP(staged): saving staged changes on feature/branch
   ```

3. **Restore the WIP branch:**
   ```bash
   git reset --hard 3d16b293f  # Use the unstaged commit hash
   ```

4. **Switch to original branch:**
   ```bash
   git checkout feature/branch
   ```

5. **Bring WIP commits to original branch:**
   ```bash
   git cherry-pick 2b4cb7b48 3d16b293f
   ```

6. **Now run restore-wip correctly:**
   ```bash
   git restore-wip
   ```

---

## Issue: Incorrect Staged/Unstaged Separation After Restore

### **What Happened:**
- User had files with both staged and unstaged changes
- After `git restore-wip`, all changes became unstaged
- The original staged/unstaged separation was lost

### **Why It Happened:**
The current `restore-wip.sh` script has a flaw in how it handles files that appear in both staged and unstaged commits. The script uses:
```bash
git reset HEAD $(git diff --name-only HEAD~1)
```
This unstages ALL files that were in the unstaged commit, even if they also had staged changes.

### **How to Recreate:**
```bash
# 1. Make changes to a file
echo "change 1" >> file.txt
git add file.txt

# 2. Make more changes to the same file
echo "change 2" >> file.txt

# 3. Save WIP
git save-wip

# 4. Restore WIP
git restore-wip

# 5. Check status - all changes are now unstaged
git status
```

### **Symptoms:**
- Files that were originally staged are now unstaged
- Loss of the staged/unstaged separation
- Incorrect working state

### **Solution:**
1. **Reset to clean state:**
   ```bash
   git reset --hard HEAD~2  # Go back before WIP commits
   ```

2. **Apply staged changes first:**
   ```bash
   git show <staged-commit-hash> | git apply
   git add <files-that-were-staged>
   ```

3. **Apply unstaged changes:**
   ```bash
   git show <unstaged-commit-hash> | git apply
   ```

4. **Verify the separation:**
   ```bash
   git status
   git diff --cached --stat
   git diff --stat
   ```

---

## Issue: Files with Both Staged and Unstaged Changes

### **What Happened:**
- Same files appeared in both staged and unstaged WIP commits
- This indicates additional changes were made after staging
- The restore process needs to handle this correctly

### **Example Scenario:**
```bash
# Original state:
# file.txt: staged changes (lines 1-10)
# file.txt: unstaged changes (lines 11-20) 
# other.txt: unstaged changes (lines 1-5)

# WIP commits:
# Staged: file.txt (lines 1-10)
# Unstaged: file.txt (lines 11-20), other.txt (lines 1-5)
```

### **Correct Restoration Process:**
1. **Apply staged changes and stage them:**
   ```bash
   git show <staged-commit> | git apply
   git add <files-from-staged-commit>
   ```

2. **Apply unstaged changes (leave unstaged):**
   ```bash
   git show <unstaged-commit> | git apply
   ```

3. **Result:**
   - Files from staged commit: staged
   - Files from unstaged commit: unstaged
   - Files in both: staged portion + unstaged portion

---

## Current Script Limitations

### **`restore-wip.sh` Issues:**
1. **Wrong branch detection**: No check if user is on correct branch
2. **No WIP branch validation**: Doesn't verify a corresponding WIP branch exists
3. **Incomplete separation**: Doesn't properly handle files in both commits
4. **Over-aggressive unstaging**: Unstages all files from unstaged commit

### **`return-to-wip.sh` Issues:**
1. **File list extraction**: May not handle complex file paths correctly
2. **Error handling**: Limited error messages for troubleshooting

---

## Improved Script Recommendations

### **Enhanced `restore-wip.sh`:**
```bash
#!/bin/bash

# Get current branch name
current_branch=$(git rev-parse --abbrev-ref HEAD)

# Check if we're on a WIP branch
if [[ $current_branch == wip/* ]]; then
    echo "Error: You're on a WIP branch. Switch to the original branch first."
    echo "Original branch: ${current_branch#wip/}"
    exit 1
fi

# Check if there's a corresponding WIP branch
wip_branch=wip/$current_branch
if ! git show-ref --verify --quiet refs/heads/$wip_branch; then
    echo "Error: No WIP branch found for current branch '$current_branch'"
    echo "Available WIP branches:"
    git branch | grep wip/ || echo "  (none)"
    echo ""
    echo "Use 'git save-wip' to create a WIP branch first, or"
    echo "use 'git return-to-wip' to copy files from an existing WIP branch."
    exit 1
fi

# Check for WIP commits on current branch
if git log -2 --pretty=%s | grep -q 'WIP(unstaged)'; then
    # Store file lists before reset
    staged_files=$(git show HEAD~1 --name-only --pretty=format:'')
    unstaged_files=$(git show HEAD --name-only --pretty=format:'')
    
    # Reset to get changes back
    git reset --soft HEAD~2
    
    # Re-stage only the files that were originally staged
    for file in $staged_files; do
        if [ -f "$file" ]; then
            git add "$file"
        fi
    done
    
    echo "Successfully restored WIP work from branch: $wip_branch"
else
    echo 'No WIP commits found with staged/unstaged separation'
    echo "Note: WIP branch '$wip_branch' exists but no WIP commits found on current branch."
    echo "You may need to cherry-pick the WIP commits first:"
    echo "  git cherry-pick <staged-commit> <unstaged-commit>"
fi
```

### **Enhanced `return-to-wip.sh`:**
```bash
#!/bin/bash

current_branch=$(git rev-parse --abbrev-ref HEAD)
wip_branch=wip/$current_branch

if git show-ref --verify --quiet refs/heads/$wip_branch; then
    # Extract file lists with better error handling
    staged_files=$(git show $wip_branch^1 --name-only --pretty=format:'' 2>/dev/null)
    unstaged_files=$(git show $wip_branch --name-only --pretty=format:'' 2>/dev/null)
    
    if [ -z "$staged_files" ] && [ -z "$unstaged_files" ]; then
        echo "Error: Could not extract file lists from WIP branch"
        exit 1
    fi
    
    # Checkout files with error handling
    if [ -n "$staged_files" ]; then
        git checkout $wip_branch -- $staged_files
    fi
    
    if [ -n "$unstaged_files" ]; then
        git checkout $wip_branch -- $unstaged_files
        git reset HEAD $unstaged_files
    fi
    
    echo "Files restored from WIP branch: $wip_branch"
else
    echo 'No WIP branch found for current branch'
fi
```

---

## Validation Requirements

### **`restore-wip` Validation Rules:**
The `restore-wip` command should only work when:

1. **Not on a WIP branch**: Must be on the original branch (e.g., `feature/123`, not `wip/feature/123`)
2. **WIP branch exists**: Must have a corresponding WIP branch (e.g., `wip/feature/123` exists)
3. **WIP commits present**: Current branch must have the WIP commits to restore

### **Validation Flow:**
```bash
# 1. Check current branch
current_branch=$(git rev-parse --abbrev-ref HEAD)

# 2. Reject if on WIP branch
if [[ $current_branch == wip/* ]]; then
    echo "Error: You're on a WIP branch. Switch to the original branch first."
    exit 1
fi

# 3. Check for corresponding WIP branch
wip_branch=wip/$current_branch
if ! git show-ref --verify --quiet refs/heads/$wip_branch; then
    echo "Error: No WIP branch found for current branch '$current_branch'"
    exit 1
fi

# 4. Check for WIP commits on current branch
if ! git log -2 --pretty=%s | grep -q 'WIP(unstaged)'; then
    echo "Error: No WIP commits found on current branch"
    exit 1
fi
```

### **Why This Validation is Important:**
- **Prevents data loss**: Stops users from accidentally deleting WIP commits
- **Clear error messages**: Tells users exactly what's wrong and how to fix it
- **Guides workflow**: Helps users understand the correct WIP workflow
- **Reduces confusion**: Eliminates the "wrong branch" problem we encountered

---

## Best Practices

### **Before Using WIP Commands:**
1. **Check your current branch:**
   ```bash
   git branch --show-current
   ```

2. **Verify WIP state:**
   ```bash
   git list-wip
   ```

3. **Understand the workflow:**
   - `save-wip`: Creates WIP branch, commits changes
   - `restore-wip`: Must be run on original branch
   - `return-to-wip`: Can be run from any branch

### **When Things Go Wrong:**
1. **Don't panic** - Git reflog usually has the commits
2. **Check reflog first:**
   ```bash
   git reflog --oneline -10
   ```
3. **Identify the WIP commits** by their commit messages
4. **Use cherry-pick** to recover commits
5. **Apply changes manually** if needed

### **Testing the Workflow:**
1. **Create test scenario:**
   ```bash
   echo "staged change" > test.txt
   git add test.txt
   echo "unstaged change" >> test.txt
   ```

2. **Test save and restore:**
   ```bash
   git save-wip
   git checkout main
   git checkout feature/test
   git restore-wip
   ```

3. **Verify the state matches original**

---

## Common Error Messages

### **"No WIP commits found with staged/unstaged separation"**
- **Cause**: Not on the right branch or WIP commits were deleted
- **Solution**: Check current branch and reflog

### **"No WIP branch found for current branch"**
- **Cause**: No corresponding WIP branch exists
- **Solution**: Check available WIP branches with `git list-wip`

### **"Could not extract file lists from WIP branch"**
- **Cause**: WIP branch is corrupted or empty
- **Solution**: Check WIP branch state and reflog

---

## Recovery Commands Reference

### **Find Lost Commits:**
```bash
git reflog --oneline -20
git log --all --grep="WIP" --oneline
```

### **Restore WIP Branch:**
```bash
git reset --hard <wip-commit-hash>
```

### **Bring Commits to Original Branch:**
```bash
git cherry-pick <staged-commit> <unstaged-commit>
```

### **Apply Changes Manually:**
```bash
git show <commit-hash> | git apply
```

### **Check File Differences:**
```bash
git show <commit-hash> --stat
git show <commit-hash> --name-only
```

---

## Future Improvements

1. **Add branch validation** to all WIP scripts
2. **Improve error messages** with actionable guidance
3. **Add dry-run mode** for testing
4. **Create backup mechanism** before destructive operations
5. **Add interactive mode** for complex scenarios
6. **Improve file path handling** for special characters
7. **Add logging** for debugging
8. **Create recovery scripts** for common failure scenarios 