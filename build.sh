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
unset F18_DEBUG_THREAD
unset F18_DEBUG_SYNC
unset F18_DEBUG_SQL

#./build_lib.sh

scripts/update_f18_ver_ch.sh

hbmk2 -workdir=.h F18.hbp

