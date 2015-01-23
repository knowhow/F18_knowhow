export HB_INSTALL_PREFIX=/opt/knowhowERP/hbwin
export HB_INC_INSTALL=$HB_INSTALL_PREFIX/include

if [ "$HB_INC_INSTALL" == "" ]; then
    echo "setuj envars"
    exit -1
fi

cp -av fin/*.ch  $HB_INC_INSTALL
cp -av fakt/*.ch  $HB_INC_INSTALL
cp -av kalk/*.ch  $HB_INC_INSTALL
cp -av rnal/*.ch  $HB_INC_INSTALL
cp -av epdv/*.ch  $HB_INC_INSTALL
cp -av ld/*.ch  $HB_INC_INSTALL
cp -av os/*.ch  $HB_INC_INSTALL
cp -av pos/*.ch  $HB_INC_INSTALL
cp -av mat/*.ch  $HB_INC_INSTALL
cp -av virm/*.ch  $HB_INC_INSTALL
cp -av common/*.ch $HB_INC_INSTALL

rm F18*.a

./build_lib_release_mingw.sh

#cp hb_release.hbm hbmk.hbm
/opt/knowhowERP/hbout/bin/hbmk2 -plat=win -comp=mingw -workdir=.rw F18.hbp
