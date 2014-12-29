if [ "$HB_INC_INSTALL" == "" ]; then
    echo "setuj envars"
    exit -1
fi


IS_DARWIN=`uname  -a | grep -c Darwin`

echo uname_darvin = $UNAME

if [ "$OS_DARVIN" !=  "0" ]
then
    OS=MacOSX
else
    echo "TODO: jos provjera za linux ?" 
    OS=LinuxUbuntu
fi

cp -av fin/*.ch  $HB_INC_INSTALL
cp -av fakt/*.ch  $HB_INC_INSTALL
cp -av kalk/*.ch  $HB_INC_INSTALL
cp -av rnal/*.ch  $HB_INC_INSTALL
cp -av epdv/*.ch  $HB_INC_INSTALL
cp -av ld/*.ch  $HB_INC_INSTALL
cp -av os/*.ch  $HB_INC_INSTALL
cp -av pos/*.ch  $HB_INC_INSTALL
cp -av common/*.ch $HB_INC_INSTALL

cp hb_release.hbm hbmk.hbm


hbmk2 -workdir=.r F14.hbp
#ne treba mi rebuild poseban je direktorij u odnosu debug -rebuildall

#mkdir -p out/bin

#rm out/bin/*
#rm out/*

#cp -av F18 out/bin
#cp -av scripts/install_f18.sh out/

#cd out

#F18_REL=`grep 'F18_VER\ \\+\\"\\(.*\\)\\"' -o ../common/f18_ver.ch | grep -o "[0-9]\\+.[0-9]\\+.[0-9]\\+"`

#echo $F18_REL

#INSTALL_F_NAME=F18_${OS}_${F18_REL}_install.tar.bz2 

#echo kreiram $INSTALL_F_NAME

#gnutar cvfj ../$INSTALL_F_NAME .

echo "------- rezultat:  $INSTALL_F_NAME -------------"

#cd ..
#gnutar tvfj $INSTALL_F_NAME
