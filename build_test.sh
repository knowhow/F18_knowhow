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
cp -av common/*.ch $HB_INC_INSTALL
cp -av test/*.ch $HB_INC_INSTALL

#cp hb_test.hbm hbmk.hbm

hbmk2 -quiet -workdir=.t F18_test.hbp

