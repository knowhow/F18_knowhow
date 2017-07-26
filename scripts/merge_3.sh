#!/bin/bash

echo "merge from origin/3 (no commit)"

git merge --no-ff --no-commit origin/3

echo "CHANGELOG.md -> CHANGELOG_MERGE.md"

cp CHANGELOG.md CHANGELOG_MERGE.md

for f in VERSION VERSION_E VERSION_X script/commit.sh include/f18.ch CHANGELOG.md
do
      echo "git checkout origin/3-std -- $f"
      git checkout origin/3-std -- $f
done

git status

