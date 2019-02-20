#!/bin/bash

#do a check to make sure both of these exists
site="$1"
short="$2"

cd /var/www/drupal/sites/$site

#update user 1, don't need to backup before that
uid1="cas_$short"'_admin'
drush sqlq 'update users set name="$uid1",mail="incasweb@lehigh.edu" where uid=1';

drush upwd --password="$(pwgen -s 32)" "$uid1"

#set site mail
drush vset site_mail "incasweb@lehigh.edu"

#remove people, don't need to backup before this
drush ucan -y ark218,gsl217,rbc218,ena219,vrt221

#should I remove admin from everyone for now? probably

#### BACKUP database before disabling uninstalled modules
# test to make sure  files/private/backup_migrate/manual  exists
# check it's permissions
drush bb
cp -r files/private/backup_migrate/manual files/private/backup_migrate/bu-b4modules-$(date +%m%d%H%M)


#Uninstall disabled modules from the old server
#this won't work without making sure that these modules are on the server. I might need a more sophisticated script to make this work
drush pmu $(drush pm-list --type=module --status=disabled --pipe | tr '\n' ,)

#### Disable modules now
#disable, don't uninstall:
drush dis -y comments,tracker

#disable, then uninstall
$dis="overlay,dashboard,color,imce_mkdir"
#$dis1="fullcalendar_colors"

drush dis -y "$dis"
#drush dis -y "$dis1"

#uninstall the disabled modules
#drush pmu -y "$dis"','"$dis1"
drush pmu -y "$dis"

### remove modules that aren't on the server
#if the modules folder exists
cp -r ~/modules-transfer/UNINSTALLmodules ./modules
drush dis -y oauth_common,panels,colors
drush pmu -y oauth_common,panels,colors
rm -r ./modules/UNINSTALLmodules
#I'm sure there will be more to add to the above, maybe if enough get added

#maybe add something in here displaying other modules that should be uninstalled.

#enable modules
drush en module_filter,filter_perms,view_unpublished,syslog,diff

#list content types that don't have any content?

#is there a roster type?
#   if so look at the number of pieces of content
#         disable if not too many?


# Check for the Documents archive feature
#  is there content in there?


#other config:

#the lehigh LDAP feature?
#then make that the default LDAP server?


#things to check

#list modules?
#list

#check for the
#   bxslider
#   webforms
#   field_permissions

#backup the db before doing a updb
##### drush bam-backup
#update the db
drush updb
#clear the cache
drush cc all
#backup the db again
#### drush bam-backup
#one more cach clear
drush cc all

# list modules
echo "ENABLED Modules"
drush pm-list --type=module --status=enabled

echo "--------------------------"
echo "DISABLED Modules"
drush pm-list --type=module --status=disabled
#list enabled FEATURES only
