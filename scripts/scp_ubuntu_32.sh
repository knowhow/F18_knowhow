

if [ "$1" == "" ] ; then
  echo prvi parametar mora biti  verzija
  echo npr: $0 1.7.134
  exit 1
fi

scp F18_Ubuntu_i686_${1}.gz root@download.bring.out.ba:/var/www/files/

