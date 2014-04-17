#!/bin/bash

usage()
{
  echo "     poziv: $0 <verzija>"
  echo "koristenje: $0 0.9.38"
}

VER=$1

if [[ $VER == "" ]]
then  
   usage
   exit 0
fi


#WINDOWS=`uname -a | grep -c NT`
WINDOWS=`echo $HB_PLATFORM| grep -c win`

#ARCH=`$HOSTTYPE`
ARCH="x86_64"

BIT32=`strings  ./F18 | grep '\-bit)' | grep -c 32`

if [[ "$BIT32" == "1" ]] 
then
    ARCH="i686"
fi

if [[ "$WINDOWS" == "1" ]]
then
  TAG_OS="Windows"
  F18_EXE="F18.exe"
else
  TAG_OS="Ubuntu_$ARCH"
  F18_EXE="F18"
fi

gzip -v -cN ${F18_EXE} > F18_${TAG_OS}_${VER}.gz

ls -l F18_${TAG_OS}_${VER}.gz
