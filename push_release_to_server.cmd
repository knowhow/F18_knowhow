@echo off


IF [%VERSION%]==[] (
   echo ENVAR VERSION nije definisana. STOP!
   goto end
)

IF [%1]==[] (
   ECHO download host nije definisan?!
   ECHO POZIV: push_release_to_server download_host.bring.out.ba
   
   ECHO PREREQ: push ssh-key from build machine [ON download_host.bring.out.ba]
   ECHO "ssh-rsa AAAAB3N.... zaCs274Or//xwd4OOgUd sa\ernad.h@hp-desk-sa-X" >> /root/.ssh/authorized_keys
   goto end
)

set HOST=%1


echo scp  F18_Windows_%VERSION%.gz root@%HOST%:/data/download.bring.out.ba/www/files/

scp -i %USERPROFILE%\.ssh\id_rsa F18_Windows_%VERSION%.gz root@%HOST%:/data/download.bring.out.ba/www/files/


:end
echo ---- kraj ----