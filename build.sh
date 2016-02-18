#!/bin/bash

if [ "$HB_INC_INSTALL" == "" ]; then
    echo "setuj envars"
    exit -1
fi

if [ "$1" != "--no-rm" ] ; then
   rm -r -f .h
fi

unset F18_DEBUG
unset F18_DEBUG_BROWSE_SIF
unset F18_DEBUG_FIN_AZUR

./build_lib.sh

hbmk2 -workdir=.h F18.hbp

