#!/bin/bash

export KNOWHOW_ERP_ROOT=/opt/knowhowERP
export HARBOUR_ROOT=$KNOWHOW_ERP_ROOT/hb32

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

MODULES="fin kalk fakt os ld virm epdv rnal kam kadev common"
MODULES="$MODULES admin brojaci partner roba parametri narudzbenica string semaphores dbf_create dbf sql fiskalizacija pdv ui_1990  print"

for m in $MODULES
do
    HB_DBG_PATH="$HB_DBG_PATH:$HB_DBG/$m"
done

export HB_DBG_PATH
echo "HB_DBG_PATH="  $HB_DBG_PATH
