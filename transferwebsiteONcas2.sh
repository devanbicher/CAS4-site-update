#!/bin/bash

#sh transferwebsite.sh fullsitedomain.cas.lehigh.edu sitename

set -e

#assume you're in the folder you want to do the backup of

#get the parameter for the name of the folder after copying
dest=$1
site=$2

#original parameters
#site=$1
#dest=$2

if [ "$site" == "" ]
then
    echo "you have to give a short name to use"
    exit 1
fi

if [ "$dest" == "" ]
then
    echo "you have to give a destination for the site on the cas4server"
    exit 1
fi

#make sure you are in the right place.
if [ ! -d files/ ]; then
    echo "There is no files folder, you're probably in the wrong place: $(pwd) "
    exit 1
fi

#first copy the modules list: 
time=$(date +%m%d%y%H%M)

#modulelist="/home/dlb213/modulelists/$site"'-modules-'"$time.txt"
modulelist="/home/casadmin/modulelists/$site"'-modules-'"$time.txt"

modulecsv="/home/casadmin/modulelists/$site"'-modules-'"$time.csv"


echo "Generating module list..."
echo "modulelist csv:  $modulecsv "

drush pm-list --type=module --status=enabled,disabled > "$modulelist"

sed 's/  \+/,/g' "$modulelist" | sed 's/,$//g' | grep -v "Package,Name,Status,Version" | cut -d, -f2- > "$modulecsv"


scp "$modulecsv" $USER@cas4.cc.lehigh.edu:/opt/drupal/modules-transfer/cas2modulelists/

#now do the copying of the website.
#setup the private folder structure.

if [ ! -d files/private/backup_migrate/manual ]; then
    mkdir -p files/private/backup_migrate/manual
else
    echo "The files/private folder exists, dont forget to copy anything over if you need to"
    ls files/private
fi

sudo chgrp casadmin files/private
sudo chmod g+w files/private

sudo chgrp casadmin files/private/backup_migrate
sudo chmod g+w files/private/backup_migrate

sudo chgrp casadmin files/private/backup_migrate/manual
sudo chmod g+w files/private/backup_migrate/manual

#K, now check that the private_file_path variable
set +e #turn error checking off because this variable might not exist

drush vget file_private_path

set -e 

#wait for input to decide if the variable should be made

drush vget file_public_path

privpath=$(drush vget file_public_path | cut -d'"' -f2)"/private"

read -n 1 -p "Set private file path to $privpath ? (press y for yes) " setpath

echo ""
echo ""

if [ $setpath == "y" ];then
    echo "setting file_private_path to $privpath"
    drush vset file_private_path $privpath
fi

echo " Now doing the backup ... "

#do the backup
drush bb

#copy the backup files
cp -a files/private/backup_migrate/manual files/private/backup_migrate/BU4migrate-$time

echo "Done with the backup, copying the files, then themes over. "

#copy it to cas4
rsync -vr files/private/backup_migrate/BU4migrate-$time $USER@cas4.cc.lehigh.edu:/var/www/drupal/sites/"$dest"/files/private/backup_migrate/manual/

#copy themes over
rsync -vr themes/  $USER@cas4.cc.lehigh.edu:/var/www/drupal/sites/"$dest"/themes/

echo "DONT FORGET TO CHECK THE THEMES FOLDER ON CAS4, THIS SCRIPT COPIES EVERYTHING.!!"

#copy files over
rsync -v files/* $USER@cas4.cc.lehigh.edu:/var/www/drupal/sites/"$dest"/files/

#list the files directory in case there is anything in any of them. 
ls -ld files/*/
du -h --max-depth=1 files/