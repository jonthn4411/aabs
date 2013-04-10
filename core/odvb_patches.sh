#!/bin/bash

# $1 Target root folder
out_root=$1
rev_current=$(git log -1 --format=format:%H)
rev_manifest=$REPO_RREV

echo -----------------------------------------------

if [ "$rev_current" == "$rev_manifest" ]; then
    echo "${REPO_PATH}: no change"
else
    echo "${REPO_PATH}:"
    git log --oneline ${rev_manifest}..${rev_current}
    mkdir -p ${out_root}/${REPO_PATH}
    git format-patch -o ${out_root}/${REPO_PATH} ${rev_manifest}..${rev_current}
fi

