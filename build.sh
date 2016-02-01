if [ "$HB_INC_INSTALL" == "" ]; then
    echo "setuj envars"
    exit -1
fi

./build_lib.sh

hbmk2 -b -workdir=.h F18.hbp

