#!/bin/bash

site=$1
name=$2

cd /var/www/drupal/sites/$site

#update user 1
uid1='cas_$name_admin'
drush sqlq 'update users set name="$uid1" where uid=1';

drush upwd --password="$(pwgen -s 32)" castopadmin;

#remove people
drush ucan ark218,gsl217,rbc218,ena219

#should I remove admin from everyone for now? probably

#disable modules

#disable, don't uninstall:
drush dis comments,tracker

#disable, then uninstall
$dis="overlay,panels,dashboard,color,colors,imce_mkdir"
$dis1="fullcalendar_colors"

drush dis "$dispmu"

#uninstall the disabled modules
drush pmu "$dis"','"$dis1"

#don't uninstall
#      comments,tracker


#maybe add something in here displaying other modules that should be uninstalled.

#enable modules
drush en module_filter,filter_perms,view_unpublished,syslog

# list modules
echo "ENABLED Modules"
drush pm-list --type=module --status=enabled

echo "--------------------------"
echo "DISABLED Modules"
drush pm-list --type=module --status=disabled
#list enabled FEATURES only


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
drush
#update the db
drush updb
#clear the cache
drush cc all
#backup the db again
drush
#one more cach clear
drush cc all
