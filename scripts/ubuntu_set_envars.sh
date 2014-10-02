#!/bin/bash

export KNOWHOW_ERP_ROOT=/opt/knowhowERP
export HARBOUR_ROOT=$KNOWHOW_ERP_ROOT/hbout
export HB_ROOT=$KNOWHOW_ERP_ROOT/hbout
export PATH=$HB_ROOT/bin:$PATH

let KH_PATH=`echo $PATH | grep -c $KNOWHOW_ERP_ROOT/bin`

if [[ $KH_PATH -eq 0 ]]; then
   # echo "knowhowERP not in path ($KH_PATH) dodajem"
   export PATH=$KNOWHOW_ERP_ROOT/bin:$KNOWHOW_ERP_ROOT/util:$HARBOUR_ROOT/bin:$PATH
else
   echo "knowhowERP already in path ($KH_PATH): $PATH"
fi

export HB_COMPILER=gcc

export HB_INC_INSTALL=$HARBOUR_ROOT/include/harbour
export HB_LIB_INSTALL=$HARBOUR_ROOT/lib/harbour


HB_DBG=`pwd`
export HB_DBG_PATH=$HB_DBG/test:$HB_DBG/common:$HB_DBG/pos:$HB_DBG/kalk:$HB_DBG/fin:$HB_DBG/fakt:$HB_DBG/os:$HB_DBG/ld:/$HB_DBG/epdv:$HB_DBG/rnal:$HB_DBG/mat:$HB_DBG/virm:$HB_DBG/reports:$HB_DBG/kadev


echo "HB_DBG_PATH="  $HB_DBG_PATH
