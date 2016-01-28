#!/bin/bash

HB_DBG="."

HB_DBG_PATH="."

. scripts/set_envars.sh

for m in $MODULES
do
      HB_DBG_PATH="$HB_DBG_PATH;$m"
done

export HB_DBG_PATH

echo $HB_DBG_PATH
