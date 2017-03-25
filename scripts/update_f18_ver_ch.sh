#!/bin/bash

F18_VER=`git describe --tags`
F18_DATE=`date +%d.%m.%Y`

echo F18_VER=$F18_VER, F18_DATE=$F18_DATE

sed -e "s/___F18_DATE___/$F18_DATE/" \
    -e "s/___F18_VER___/$F18_VER/" \
     f18_ver.template > include/f18_ver.ch

echo include/f18_ver.ch updated
