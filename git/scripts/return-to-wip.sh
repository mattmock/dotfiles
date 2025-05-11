#!/bin/bash

current_branch=$(git rev-parse --abbrev-ref HEAD)
wip_branch=wip/$current_branch

if git show-ref --verify --quiet refs/heads/$wip_branch; then
    staged_files=$(git show $wip_branch^1 --name-only --pretty=format:'')
    unstaged_files=$(git show $wip_branch --name-only --pretty=format:'')
    git checkout $wip_branch -- $staged_files $unstaged_files
    git reset HEAD $unstaged_files
else
    echo 'No WIP branch found for current branch'
fi 