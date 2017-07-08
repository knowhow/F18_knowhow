#!/bin/bash

F18_VER=`git describe --tags | grep "\d\{1,2\}.\d\{1,2\}.\d\{1,3\}"`

if [ -z "$F18_VER" ] ; then
 echo "verzija u git-u `git describe --tags` ne odgovara konvenciji X.Y.ZZZ"
 exit 1
fi

F18_DATE=`date +%d.%m.%Y`

echo F18_VER=$F18_VER, F18_DATE=$F18_DATE

sed -e "s/___F18_DATE___/$F18_DATE/" \
    -e "s/___F18_VER___/$F18_VER/" \
     f18_ver.template > include/f18_ver.ch

echo include/f18_ver.ch updated
