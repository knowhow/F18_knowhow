export HB_ARCHITECTURE=win
export HB_COMPILER=mingw


C_ROOT=C:


HB_ROOT=$C_ROOT\\hbwin


export HB_INC_INSTALL=$HB_ROOT\\include
export HB_LIB_INSTALL=$HB_ROOT\\lib

export HB_INSTALL_PREFIX=$HB_ROOT

#export HB_WITH_MYSQL=c:\\mysql\\include
#export HB_WITH_QT=c:\\Qt\\$QT_VER\\mingw$MINGW_VER\\include

export MSYS2=c:\\msys32\\mingw32

export PATH=$MSYS2\\bin:$PATH
export HB_WITH_PGSQL=$MSYS2\\include
export HB_WITH_OPENSSL=$MSYS2\\include

. scripts/set_envars.sh


HB_DBG=`cygpath -d $PWD`


for m in $MODULES
do
      HB_DBG_PATH="$HB_DBG_PATH;$HB_DBG\\$m"
done

export HB_DBG_PATH

echo $HB_DBG_PATH
