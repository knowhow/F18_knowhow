#!/bin/bash

#SSH_OPTS="-i $HOME/hernad_ssh.key -o StrictHostKeyChecking=no"
#WWW_PATH=/var/www/files

#scp $SSH_OPTS $1 root@download.bring.out.ba:$WWW_PATH/
#ssh $SSH_OPTS root@download.bring.out.ba chmod +r $WWW_PATH/*

#GREEN1=docker@192.168.168.107
GREEN1=docker@192.168.169.128

scp $1 $GREEN1:/data/f18-downloads/downloads.bring.out.ba/www/files/

