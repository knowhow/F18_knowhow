#!/bin/bash

BRANCH=23100-ld

if [ -z "$1" ] ; then
   echo "$0 <VER>"
   echo "$0 2.3.502"
fi

NEW_VER=$1

sed -i -e "s/f18=.*/f18=$NEW_VER" UPDATE_INFO 
git commit -a -m "publish nver $NEW_VER"
git tag $NEW_VER
git push origin $BRANCH --tags
