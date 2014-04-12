
export CC=i586-mingw32msvc-gcc
export CXX=i586-mingw32msvc-g++
export CPP=i586-mingw32msvc-cpp
export AR=i586-mingw32msvc-ar
export RANLIB=i586-mingw32msvc-ranlib
export ADD2LINE=i586-mingw32msvc-addr2line
export AS=i586-mingw32msvc-as
export LD=i586-mingw32msvc-ld
export NM=i586-mingw32msvc-nm
export STRIP=i586-mingw32msvc-strip
export MINGW32_LIBS=/usr/i586-mingw32msvc/lib/
export MINGW32_INCLUDES=/usr/i586-mingw32msvc/include/
 
export PATH="/usr/i586-mingw32msvc/bin:$PATH"
#export PKG_CONFIG_PATH="$HOME/win32-x264/lib/pkgconfig/"

export HB_PLATFORM=win
export HB_INSTALL_PREFIX=/opt/knowhowERP/hbwin
export HB_CCPREFIX=i586-mingw32msvc-
#/opt/knowhowERP/hbout/bin/hbmk2 -plat=win -comp=mingw -gtwvt test.prg


#apt-get install autoconf automake bash bison bzip2 cmake flex gettext git g++ intltool libffi-dev libtool libltdl-dev libssl-dev libxml-parser-perl make openssl patch perl pkg-config scons sed unzip wget xz-utils

#apt-get install g++-multilib libc6-dev-i386

# postgresql 9.3 mingw
#./configure --host=i686-w64-mingw32  --without-zlib --prefix=/usr/i586-mingw32msvc/
# ~/dev/harbour/harbour/postgresql-9.3-9.3.4
# ln -s /usr/sbin/zic src/timezone/zic

# ls -l /usr/i586-mingw32msvc/lib/libpq*
# -rw-r--r-- 1 bringout bringout 119524 Apr 12 11:58 /usr/i586-mingw32msvc/lib/libpq.a
# -rwxr-xr-x 1 bringout bringout 187168 Apr 12 11:58 /usr/i586-mingw32msvc/lib/libpq.dll

#hbpgsql $ /opt/knowhowERP/hbout/bin/hbmk2 -plat=win -comp=mingw hbpgsql

#cat hbpgsql.hbc
#{darwin}libpaths=/opt/local/lib/postgresql83
# dodati:
#{win}libs=/usr/i586-mingw32msvc/lib

#cp libhbpgsql.a /usr/i586-mingw32msvc/lib/



# /opt/knowhowERP/hbout/bin/hbmk2 -plat=win -comp=mingw sddpg
#cp hbrddsql.h /usr/i586-mingw32msvc/include

#bringout@bringout-Inspiron-5537 ~/dev/harbour/harbour/contrib/sddpg $ cat sddpg.hbp
#dodati:
#{win}-depincpath=pgsql:/usr/i586-mingw32msvc/include


#F18.exe

# sudo apt-get install p11-kit:i386

