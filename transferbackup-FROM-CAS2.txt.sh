#!/bin/bash

set -e

#assume you're in the folder you want to do the backup of

#get the parameter for the name of the folder after copying
site=$1

if [ "$site" == "" ]
then
    echo "you have to give a short name to use"
    exit 1
fi

#make sure you are in the right place.
if [ ! -d files/ ]; then
    echo "There is no files folder, you're probably in the wrong place: $(pwd) "
    exit 1
fi


#setup the private folder structure.

if [ ! -d files/private/backup_migrate/manual ]; then
    mkdir -p files/private/backup_migrate/manual
fi

chgrp -R casadmin files/private
chmod -R g+w files/private

#K, now check that the private_file_path variable
set +e #turn error checking off because this variable might not exist

drush vget file_private_path

set -e 

#wait for input to decide if the variable should be made

drush vget file_public_path

privpath=$(drush vget file_public_path | cut -d'"' -f2)"/private"

read -n 1 -p "Set private file path to $privpath ?" setpath

echo ""
echo ""

if [ $setpath == "y" ];then
    echo "setting file_private_path to $privpath"
    drush vset file_private_path $privpath
fi


#do the backup
drush bb

#setup this time since I need it twice
time=$(date +%m%d%y%H%M)

#copy the backup files
cp -a files/private/backup_migrate/manual files/private/backup_migrate/BU4migrate-$time

#copy it to cas4
scp -r files/private/backup_migrate/BU4migrate-$time dlb213@cas4.cc.lehigh.edu:~/cas2backup_migrate/"$site"'-'"$time"

