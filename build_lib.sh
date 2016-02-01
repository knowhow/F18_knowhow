if [ "$HB_INC_INSTALL" == "" ]; then
    echo "setuj envars"
    exit -1
fi


hbmk2 -workdir=.h F18_narudzbenica.hbp
hbmk2 -workdir=.h F18_string.hbp

