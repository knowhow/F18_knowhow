if [ "$HB_INC_INSTALL" == "" ]; then
    echo "setuj envars"
    exit -1
fi

#cp hb_debug_lib.hbm hbmk.hbm

hbmk2 -workdir=.h -b F18_narudzbenica.hbp
hbmk2 -workdir=.h -b F18_string.hbp

