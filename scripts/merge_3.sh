#!/bin/bash

git merge --no-ff --no-commit 3

for f $ VERSION VERSION_E VERSION_X script/commit.sh
      echo "git checkout $f"
      git checkout $f
done

git status

