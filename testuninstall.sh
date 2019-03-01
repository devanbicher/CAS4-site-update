#!/bin/bash

#this is to attempt uninstalling modules

# I will need to test this in a site folder first.

#put a test to make sure $1 isn't empty
cd $1

drush pm-list --type=module --status=disabled


read -n 1 -p "Uninstall the modules listed above? " keepuninstalling


while [$keepuninstalling == "y"]; do
    drush -y pm-uninstall $(drush pm-list --type=module --status=disabled --pipe | tr '\n' ',')

    echo ""
    echo " --------- Modules uninstalled ---------"
    echo " printing still disabled modules"
    echo ""

    drush pm-list --type=module --status=disabled

    read -n 1 -p "Continue to uninstall? " keepuninstalling

done


echo " You have chosen to stop uninstalling disabled modules. "
