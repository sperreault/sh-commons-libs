#!/usr/bin/env ksh

# LALA="commons logger lala"
#
# a() {
# 	if [[ ${LALA} =~ ${1} ]]; then
# 		echo ${1}
# 	else
# 		echo "to"
# 	fi
# }
#
# b() {
# 	typeset is_cmd=$(command -v -- $1)
# 	echo ${is_cmd}
# 	if [ "${is_cmd}" != '' ]; then
# 		dirname ${is_cmd}
# 	else
# 		echo ''
# 	fi
# }
#
# echo ${LALA}
# echo "blah"
# a blah
# echo "lala"
# a lala
#
# b /usr/bin/sh
#
# b ~/shell-commons-framework/src/bin/anexa
#
# b ../shell-commons-framework/src/bin/anexa-bootstrap
# #typeset +f
#
#
set -x
# echo COMMONS_BASEDIR=$COMMONS_BASEDIR
# source ${COMMONS_BASEDIR}/lib/sh-commons.ksh
# (cmd=$(commons_check_command jdjdjd) && echo $cmd) ||
# 	(cmd=$(commons_check_command git) && echo $cmd) ||
# 	echo lala
# if [ -z "${lala+x}" ]; then
# 	echo "lala not is loaded"
# else
# 	echo "lala is loaded: $lala"
# fi
# lala=a
# if [ -z "${lala+x}" ]; then
# 	echo "lala not is loaded"
# else
# 	echo "lala is loaded: $lala"
# fi
source tools/install.sh
