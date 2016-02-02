#!/bin/bash

if [ "$HB_INC_INSTALL" == "" ]; then
    echo "setuj envars"
    exit -1
fi

rm -r -f .h

unset F18_DEBUG

./build_lib.sh

hbmk2 -workdir=.h F18.hbp

