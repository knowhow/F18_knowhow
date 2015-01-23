GCODE_URL_ROOT_F18=http://knowhow-erp-f18.googlecode.com/files
GCODE_URL_ROOT=http://knowhow-erp.googlecode.com/files
F18_INSTALL_ROOT=/opt/knowhowERP

# export QT_DIR=c:/knowhowERP/Qt

# export QT_DIR=c:\\Qt\\4.7.4
# export QT_DIR_CYGWIN=/c/Qt/4.7.4

# export HB_WITH_GTALLEGRO=no
# export HB_WITH_ALLEGRO=no
# export HB_WITH_GTWVG=yes




CUR_USER=`whoami`
CUR_DIR=`pwd`
export HB_INSTALL_PREFIX=$CUR_DIR/hbout

export HB_WITH_SQLITE3=yes


export PATH=$PATH:$HB_INSTALL_PREFIX/bin


function install_template {

TPL_FILE=F18_template_${TPL_VER}

rm ${TPL_FILE}.tar.bz2
wget $GCODE_URL_ROOT_F18/${TPL_FILE}.tar.bz2

tar -C $F18_INSTALL_ROOT -jxf ${TPL_FILE}.tar.bz2
}

function install_harbour {

HRB_FILE=harbour_travis.tar.bz2

rm ${HRB_FILE}
wget $GCODE_URL_ROOT/${HRB_FILE}

tar -C . -jxf $HRB_FILE
}


function install_jod_reports {

D_FILE=jodreports-cli.jar
wget -q -nc $GCODE_URL_ROOT/$D_FILE

DEST="/opt/knowhowERP/util/"
sudo mkdir -p $DEST
sudo chown $CUR_USER $DEST
sudo cp $D_FILE  $DEST

DEST_TPL="/opt/knowhowERP/template/"
sudo mkdir -p $DEST_TPL
sudo chown $CUR_USER $DEST_TPL

}


