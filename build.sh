cp -av fin/*.ch  $HB_INC_INSTALL
cp -av common/*.ch $HB_INC_INSTALL

hbmk2 *.prg fin/*.prg common/*.prg
