#!/bin/sh
echo COMMONS_BASEDIR=$COMMONS_BASEDIR
source ${COMMONS_BASEDIR}/lib/sh-commons.sh

echo COMMONS_LOADED_MODULES=$COMMONS_LOADED_MODULES

echo "Loading an existing module"
commons_load_module logger
echo COMMONS_LOADED_MODULES=$COMMONS_LOADED_MODULES

echo "Loading a dummy module"
commons_load_module dummy
echo COMMONS_LOADED_MODULES=$COMMONS_LOADED_MODULES

echo "Loading a module with not enough parameters"
commons_load_module cmd
echo COMMONS_LOADED_MODULES=$COMMONS_LOADED_MODULES

echo "Loading a none existing module"
commons_load_module unknown
echo COMMONS_LOADED_MODULES=$COMMONS_LOADED_MODULES
