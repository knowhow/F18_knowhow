#!/bin/bash

function usage() {
  echo "primjer: $0 Ubuntu_i686 1.7.750"
  echo "         $0 Windows 1.7.750"
  echo "         $0 MacOSX 1.7.750"
}

[ -z "$1" ] && echo "set envar F18_TYPE argument 1"  && usage && exit 1
[ -z "$2" ] && echo "set envar F18_VER argument 2"  && usage && exit 1

F18_TYPE=$1
F18_VER=$2

git pull

./build.sh --no-rm && scripts/build_gz.sh $F18_VER && scripts/push_to_downloads.sh F18_${F18_TYPE}_${F18_VER}.gz 

