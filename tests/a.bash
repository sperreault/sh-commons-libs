#!/bin/bash
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
#source build/lib/sh-commons.sh
set -x

COMMONS_CURRENT_SHELL=""

commons_current_shell() {
	sh=$(ps -p $$ | grep $0 | awk '{print $4'})
	fullpath=$(command -v $sh) || exit 1
	ver=$($fullpath --version 2>&1)
	retval=${?}
	if [ ${retval} -eq 1 ]; then
		# we assume bourne shell
		echo "sh"
		return 0
	else
		# detect ksh
		echo ${ver} | grep -q 93
		if [ $? -eq 0 ]; then
			echo "ksh"
			return 0
			#detect bash return sh if we are in POSIX compliance mode
		else
			echo ${ver} | grep -q bash
			if [ $? -eq 0 ]; then
				declare -A >/dev/null 2>&1
				if [ $? -eq 0 ]; then
					echo "bash"
					return 0
				else
					# we are POSIX strict
					echo "sh"
					return 0
				fi
			else
				echo "not_supported"
				return 1
			fi
		fi
	fi
}

# commons_shell_is_posix() {
# 	if [ $? -eq 1 ]; then
# 		echo 0
# 		return 0
# 	else
# 		if [ "${COMMONS_CURRENT_SHELL}" == "sh" ]; then
# 			echo 0
# 			return 0
# 		else
# 			echo 1
# 			return 1
# 		fi
# 	fi
# }
#
_commons_define_hash_sh() {
	var_name=$1
	shift
	c=0
	k=""
	for i in $*; do
		if [ ${c} -eq 0 ]; then
			k=$i
			c=1
		else
			# eval is evil shoult replace
			eval "${var_name}_${k}"="$i"
			#$IFS= read -r -d '' "${var_name}_${k}" <<<"${i}"
			export ${var_name}_${k}
			c=0
		fi
	done
}

_commons_define_hash_ksh() {
	typeset -A ${var_name}
	export ${var_name}
	shift
	_commons_define_hash_not_posix ${var_name} ${@}
	return $?
}

_commons_define_hash_bash() {
	declare -a ${var_name}
	export ${var_name}
	shift
	_commons_define_hash_not_posix ${var_name} ${@}
	return $?
}

_commons_define_hash_not_posix() {
	var_name=$1
	c=0
	k=""
	shift
	for i in $*; do
		if [ ${c} -eq 0 ]; then
			k=$i
			c=1
		else
			# eval is evil shoult replace
			eval "${var_name}[${k}]"="${i}"
			#IFS= read -r -d '' "${var_name}[${k}]" <<<"${i}"
			c=0
		fi
	done
	export ${var_name}
}

commons_define_hash() {
	var_name=$1
	shift
	if [ ${#}%2==0 ]; then
		_commons_define_hash_${COMMONS_CURRENT_SHELL} ${var_name} ${@} && return 0 || return 1
	else
		echo "Your argument list $* can not be devided by 2"
		return 1
	fi
}

_commons_get_hash_value_sh() {
	v=${1}_${2}
	echo ${!v}
	return $?
}

_commons_get_hash_value_bash() {
	echo ${1}[${2}]
	return $?
}

_commons_get_hash_value_ksh() {
	typeset -n v="${1}[${2}]"
	echo ${v}
	return $?
}

commons_get_hash_value() {
	_commons_get_hash_value_${COMMONS_CURRENT_SHELL} $@
}

COMMONS_CURRENT_SHELL=$(commons_current_shell)
export ${COMMONS_CURRENT_SHELL}

commons_define_hash lala TRACE 1 DEBUG 2
commons_get_hash_value lala TRACE
