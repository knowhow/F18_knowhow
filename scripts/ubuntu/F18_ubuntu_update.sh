#!/bin/bash
#0.1.0
#06.12.2011 

if [[ "$1" == "" ]]; then
echo "niste unijeli verziju koju zelite postaviti, npr 0.9.5"
exit 0
fi
 
NVER=$1
SERVICE='F18'
ARCH=`uname -m`
 
if ps ax | grep -v grep | grep $SERVICE > /dev/null
then
    echo "$SERVICE je pokrenut molim da ga zatvorite i ponovite update"
exit 0

else
    echo "$SERVICE nije pokrenut"
fi
 

echo -n "pricekajte u toku je download..."
wget http://knowhow-erp-f18.googlecode.com/files/F18_"$ARCH"_"$NVER".tar.gz

echo "ok - zavrseno"

echo "upgrade"

tar  xvfz F18_"$ARCH"_"$NVER".tar.gz
mv F18 ~/bin
rm  F18_"$ARCH"_"$NVER".tar.gz


echo "update je zavrsen"


