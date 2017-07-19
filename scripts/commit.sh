#!/bin/bash

BRANCH=3-std

if [ -z "$1" ] ; then
   echo "$0 <VER>"
   echo "$0 3.0.0"
   exit 1
fi

NEW_VER=$1

sed -i -e "s/f18=.*/f18=$NEW_VER/" UPDATE_INFO 
echo $NEW_VER > VERSION
git commit -a -m "publish nver $NEW_VER"
git tag $NEW_VER
git push origin $BRANCH --tags
