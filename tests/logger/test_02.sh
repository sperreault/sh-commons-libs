#!/bin/sh
echo COMMONS_BASEDIR=$COMMONS_BASEDIR
source ${COMMONS_BASEDIR}/lib/sh-commons.sh
init
echo COMMONS_LOADED_MODULES=$COMMONS_LOADED_MODULES

echo "Doing UNKNOWN level"
commons_logger_log UNKNOWN "This is not a real level"

cleanup
