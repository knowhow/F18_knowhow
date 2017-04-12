#!/bin/bash

if ! rclone listremotes  | grep -q gdrive_bout
then
  echo "rclone mora biti konfigurisan - podesen remote gdrive_bout"
  exit 1
fi


docker stop jenkins-1

tar cvfJ jenkins_home.tar.xz jenkins_home

docker start jenkins-1

rclone copy -v jenkins_home.tar.xz gdrive_bout:/jenkins_home.tar.xz
