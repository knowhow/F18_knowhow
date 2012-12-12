#!/bin/bash

GCODE_URL_ROOT_F18=http://knowhow-erp-f18.googlecode.com/files
GCODE_URL_ROOT=http://knowhow-erp.googlecode.com/files
F18_INSTALL_ROOT=/opt/knowhowERP


DEST_TPL="/opt/knowhowERP/template"
#mkdir -p $DEST_TPL
#chown $CUR_USER $DEST_TPL


function install_template {

TPL_FILE=F18_template_${TPL_VER}

rm ${TPL_FILE}.tar.bz2
wget $GCODE_URL_ROOT_F18/${TPL_FILE}.tar.bz2

CMD="tar -C $F18_INSTALL_ROOT -jvxf ${TPL_FILE}.tar.bz2"
echo $CMD
$CMD

}


TPL_VER="1.2.6"
install_template

rm $DEST_TPL/f-std?.odt
rm $DEST_TPL/f-std??.odt

