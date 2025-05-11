#!/bin/bash

if git log -2 --pretty=%s | grep -q 'WIP(unstaged)'; then
    git reset --soft HEAD~2
    git reset HEAD $(git diff --name-only HEAD~1)
else
    echo 'No WIP commits found with staged/unstaged separation'
fi 