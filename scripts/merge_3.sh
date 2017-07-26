#!/bin/bash

MY_BRANCH=origin/3-vindi

git merge --no-ff --no-commit 3

for f in VERSION VERSION_E VERSION_X include/f18.ch kalk/kalk_import_racuni.prg kalk/kalk_import_partn_roba.prg kalk/kalk_mnu_razmjena_podataka.prg
do
      echo "git checkout $MY_BRANCH -- $f"
      git checkout $MY_BRANCH -- $f
done

rm scripts/merge_from_3-vindi.sh

git status


