#!/bin/bash

echo "merge from origin/3 (no commit)"

git merge --no-ff --no-commit origin/3

for f in VERSION VERSION_E VERSION_X script/commit.sh
do
      echo "git checkout $f"
      git checkout $f
done

git status

