#!/bin/bash

# usage
# curl https://raw.githubusercontent.com/knowhow/F18_knowhow/3/bin/F18_install.sh | bash


F18_VER=3.1.215
F18_ZIP_MD5=52255d8cbc049a20f3f160869f541bf7

F18_GZ=F18_${F18_VER}.gz
APT_INSTALL_FILES="libpq5 curl vim vim-gnome  xfonts-terminus-oblique xfonts-terminus"

OS="CENTOS7"


if lsb_release -d | grep "Ubuntu 14" ; then
  OS="UBUNTU14"
elif lsb_release -d | grep "Ubuntu 16" ; then
  OS="UBUNTU16"
fi

ubuntu_install() {

  pwd

  if ! dpkg -l | grep -q terminus ; then
     echo "sudo enabled user - enter password, install $APT_INSTALL_FILES"
     sudo apt-get update -y
     sudo apt-get install -y $APT_INSTALL_FILES
  fi



  if [ -f $F18_GZ ]  ; then
      echo "$F18_GZ postoji"
      if  ! ( md5sum $F18_GZ | grep $F18_ZIP_MD5 )  ; then
        echo "md5 sum gz wrong ! rm gz"
        rm $F18_GZ
      else
        echo "md5 sum OK"
      fi
  fi

  if [ ! -f $F18_GZ ] ; then
      echo "download $F18_VER sa bintray-a"
      curl -L https://bintray.com/hernad/F18/download_file?file_path=F18_linux_x86_$F18_VER.zip > $F18_GZ
  fi

  if [[ $OS == UBUNTU14 ]] ; then
      curl -L https://github.com/knowhow/F18_knowhow/raw/3/bin/UBUNTU14/libstdc%2B%2B.so.6 > libstdc++.so.6 
      chmod +x libstdc++.so.6
  fi

  if [ ! -f F18.png ] ; then
      curl -L https://github.com/knowhow/F18_knowhow/raw/3/bin/F18.png > F18.png
  fi

  cp $F18_GZ F18.gz
  gunzip -f F18.gz
  chmod +x F18

  ls -l F18
}

echo $OS

cd $HOME
[ -f F18 ] && rm F18

mkdir -p $HOME/F18
cd $HOME/F18

if [[ $OS == UBUNTU* ]] ; then
   ubuntu_install
fi


if [[ $OS == UBUNTU14 || $OS == UBUNTU16 ]] ; then

# unity autohide
cat > F18.sh <<- EOM
#!/bin/sh

# --- echo ubuntu -----
dconf write /org/compiz/profiles/unity/plugins/unityshell/launcher-hide-mode 1

cd ${HOME}/F18
export LD_LIBRARY_PATH=.
export PATH=${HOME}/F18:\$PATH
./F18

dconf write /org/compiz/profiles/unity/plugins/unityshell/launcher-hide-mode 0
EOM

else


cat > F18.sh <<- EOM
#!/bin/sh

# ---- echo centos ---

cd ${HOME}/F18
export LD_LIBRARY_PATH=.
export PATH=${HOME}/F18:\$PATH
./F18

EOM

fi

cat > F18.desktop <<- EOM
[Desktop Entry]
Name=F18 klijent
Comment=F18 - knjigovodstvo za bosance
Icon=application.png
Exec=/home/hernad/F18/F18.sh
Icon=${HOME}/F18/F18.png
Type=Application
Categories=GTK;GNOME;Utility;
Terminal=false
EOM


cat > f18_editor <<- EOM
#!/bin/bash


cat \$1 | sed 's/#%.*#//g' | iconv -c -f IBM852 -t UTF-8 > \$1.conv.txt

export BANG=\!  
gvim -c "nmap <C-P> :exe '\$BANG ptxt ' . substitute(@%, '.conv.txt', '', 'y') . ' /p'<CR>" \$1.conv.txt
EOM

chmod +x F18.sh
chmod +x F18.desktop
chmod +x f18_editor
xdg-open .

cd $HOME