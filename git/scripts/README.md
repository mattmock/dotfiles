# WIP Workflow Management System

This directory contains scripts for managing Work In Progress (WIP) branches in Git. The WIP system allows you to quickly save your current work state, switch contexts, and restore your work later.

## Overview

The WIP system provides four main commands that are available as Git aliases:

- `git save-wip` - Save current work to a WIP branch
- `git restore-wip` - Restore WIP work to current branch
- `git list-wip` - List all WIP branches
- `git return-to-wip` - Return specific files from WIP branch

## Commands

### `git save-wip`

Saves your current work state by creating a WIP branch and committing both staged and unstaged changes.

**What it does:**
1. Creates a new branch named `wip/current-branch-name`
2. Commits staged changes (if any) with message "WIP(staged): saving staged changes on branch-name"
3. Commits unstaged changes (if any) with message "WIP(unstaged): saving unstaged changes on branch-name"

**Usage:**
```bash
# Save current work state
git save-wip
```

**Example:**
```bash
# You're on feature/123 branch with some uncommitted changes
$ git status
On branch feature/123
Changes not staged for commit:
  modified:   src/main.js
  new file:   src/utils.js

$ git save-wip
Switched to a new branch 'wip/feature/123'
[wip/feature/123 abc1234] WIP(unstaged): saving unstaged changes on feature/123
 2 files changed, 15 insertions(+)
```

### `git restore-wip`

Restores your WIP work back to the original branch, separating staged and unstaged changes.

**What it does:**
1. Checks if the last two commits are WIP commits
2. Uses soft reset to restore changes to staging area
3. Unstages files that were originally unstaged

**Usage:**
```bash
# Switch back to original branch first
git checkout feature/123

# Restore WIP work
git restore-wip
```

**Example:**
```bash
$ git checkout feature/123
Switched to branch 'feature/123'

$ git restore-wip
# Your changes are now restored to their original state
# Staged changes remain staged, unstaged changes are unstaged
```

### `git list-wip`

Lists all WIP branches in the repository.

**Usage:**
```bash
git list-wip
```

**Example:**
```bash
$ git list-wip
  wip/feature/123
  wip/bugfix/456
  wip/hotfix/789
```

### `git return-to-wip`

Returns specific files from a WIP branch to your current branch.

**What it does:**
1. Finds the WIP branch for your current branch
2. Restores staged files to staging area
3. Restores unstaged files to working directory (unstaged)

**Usage:**
```bash
git return-to-wip
```

**Example:**
```bash
$ git return-to-wip
# Files from wip/feature/123 are restored to current branch
```

## Workflow Scenarios

### Scenario 1: Context Switching

You're working on a feature but need to quickly switch to fix a bug:

```bash
# 1. Save current work
git save-wip

# 2. Switch to bugfix branch
git checkout bugfix/456

# 3. Fix the bug and commit
# ... make changes ...
git add .
git commit -m "Fix critical bug"

# 4. Return to feature work
git checkout feature/123
git restore-wip
```

### Scenario 2: Experimenting with Changes

You want to try a different approach but keep your current work:

```bash
# 1. Save current approach
git save-wip

# 2. Try new approach
# ... make experimental changes ...

# 3. If you don't like the new approach, restore the old one
git restore-wip

# 4. If you like the new approach, you can delete the WIP branch
git branch -D wip/feature/123
```

### Scenario 3: Partial Restoration

You want to restore only some files from your WIP:

```bash
# 1. List available WIP branches
git list-wip

# 2. Return specific files from WIP
git return-to-wip

# 3. Or manually restore specific files
git checkout wip/feature/123 -- path/to/specific/file.js
```

## Best Practices

1. **Use descriptive branch names**: Your WIP branches will be named `wip/your-branch-name`, so use clear branch names.

2. **Clean up WIP branches**: Delete WIP branches when you're done with them:
   ```bash
   git branch -D wip/feature/123
   ```

3. **Check before restoring**: Always verify you're on the correct branch before restoring WIP work.

4. **Use for temporary work**: WIP branches are meant for temporary work state, not long-term storage.

5. **Commit frequently**: The WIP system works best when you commit your work regularly.

## Troubleshooting

### "No WIP commits found"
This means the last commits on your current branch are not WIP commits. Make sure you're on the correct branch and that you've saved WIP work.

### "No WIP branch found for current branch"
This means there's no corresponding WIP branch for your current branch. Check available WIP branches with `git list-wip`.

### Conflicts during restore
If there are conflicts when restoring WIP work, resolve them manually and then commit the resolution.

## Script Files

- `save-wip.sh` - Creates WIP branch and commits changes
- `restore-wip.sh` - Restores WIP work to original state
- `list-wip.sh` - Lists all WIP branches
- `return-to-wip.sh` - Returns files from WIP branch

## Git Aliases

These scripts are configured as Git aliases in your `.gitconfig`:

```ini
[alias]
    save-wip = "!git-save-wip"
    restore-wip = "!git-restore-wip"
    list-wip = "!git-list-wip"
    return-to-wip = "!git-return-to-wip"
```

The aliases assume the scripts are available in your PATH as `git-save-wip`, `git-restore-wip`, etc. 