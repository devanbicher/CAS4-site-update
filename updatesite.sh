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
drush dis overlay,panels,dashboard,

#uninstall the disabled modules
drush pmu overlay,panels,dashboard,

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


#other config:

#the lehigh LDAP feature?
#then make that the default LDAP server?


#things to check

#list modules?
#list


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
