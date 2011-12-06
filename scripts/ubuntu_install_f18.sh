#!/bin/bash

VER=0.1.0
DAT=06.12.2011
F18INSTALL=~/bin

echo "F18 install app ver: $VER, dat: $DAT"
echo "F18 lin installacija ...."



echo "F18 req."

sudo apt-get update
sudo apt-get install libqt4-sql-psql
sudo apt-get install wine
sudo apt-get install vim-gtk
sudo apt-get install wget 
wget http://winetricks.org/winetricks 
chmod +x winetricks
sh winetricks -q  riched20


echo " postoji li F18 install dir"

if [ -d $F18INSTALL ]; then

	echo "F18 instalaciona lokacija postoji, nastavljam" 
else
        echo "kreiram F18 install dir"
 	mkdir -p  $F18INSTALL
fi

echo " instaliram F18"

cp bin/F18 $F18INSTALL
chmod +x $F18INSTALL/F18

echo "deps" 

cp scripts/PTXT  $F18INSTALL/PTXT
cp util/ptxt.exe ~/.wine/drive_c/
cp util/delphirb.exe ~/.wine/drive_c/
cp fonts/ptxt_fonts/*.ttf  ~/.wine/drive_c/windows/Fonts/
cp scripts/update  $F18INSTALL
cp scripts/f18_editor $F18INSTALL
chmod +x $F18INSTALL/update
chmod +x $F18INSTALL/PTXT
chmod +x $F18INSTALL/f18_editor


echo "setujem envars"

echo export PATH=\$PATH:~/bin >> ~/.bash_profile
echo ""
echo ""
clear
echo "F18 instalacija zavrsena, pokrecemo iz terminala sa F18 "



