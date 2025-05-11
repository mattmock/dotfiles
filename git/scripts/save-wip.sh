#!/bin/bash

branch_name=$(git rev-parse --abbrev-ref HEAD)
git checkout -b wip/$branch_name

if git diff --cached --quiet; then
    echo 'No staged changes'
else
    git commit -m "WIP(staged): saving staged changes on $branch_name"
fi

if git diff --quiet; then
    echo 'No unstaged changes'
else
    git add -A
    git commit -m "WIP(unstaged): saving unstaged changes on $branch_name"
fi 