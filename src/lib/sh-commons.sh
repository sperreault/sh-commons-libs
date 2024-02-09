COMMONS_NAME=sh-commons
COMMONS_BASEDIR=${COMMONS_BASEDIR:-@DESTDIR@}
COMMONS_SHAREDIR=${COMMONS_BASEDIR}/share/${COMMONS_NAME}

#######################################
## Find out which shell we are using
## Arguments:
##   None
## Outputs:
##   String which should be sh, ksh
## Returns
##  rc from command
#######################################
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
	v=$(_commons_get_hash_value_${COMMONS_CURRENT_SHELL} $@)
	if [ "${v}" == "" ]; then
		echo ""
		return 1
	else
		echo ${v}
		return 0
	fi
}

#######################################
## Convert to upper
## Arguments:
##   String to be converted
## Outputs:
##   Returns to string in upper case
## Returns
##  rc from command
########################################
commons_to_upper() {
	echo $@ | tr "[:lower:]" "[:upper:]"
	return $?
}

#######################################
## Convert to lower
## Arguments:
##   String to be converted
## Outputs:
##   Returns to string in lower case
## Returns
##  rc from command
#######################################
commons_to_lower() {
	echo $@ | tr "[:upper:]" "[:lower:]"
	return $?
}

#######################################
## Define a Hash that can be used if shell is POSIX
## Arguments:
##   String Name of the hash
##   Narguments as KEY VALUE KEY VALUE
## Outputs:
##   None
## Returns
##  rc from command
#######################################
commons_define_hash() {
	name=$1
	shift
	eval "$name"='$value'
}

#######################################
## Print to STDERR
## Arguments:
##   String to be printed
## Outputs:
##   Prints to STDERR
## Returns
##  rc from command
#######################################
commons_print_err() {
	echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
	return $?
}

#######################################
## Check if the command exist and return it
## Arguments:
##   String of the command
## Outputs:
##   Full command path or nothing
## Returns
##  rc from command
#######################################
commons_check_command() {
	if [ ${#} -eq 1 ]; then
		command -v $1
		return $?
	else
		echo ""
		return 1
	fi
}
#######################################
## Load modules
## Globals:
##   COMMONS_LOADED_MODULES
##   COMMONS_BASEDIR
## Arguments:
##   Module name
##   Module parameters
## Returns
##   0 if all is good
##   1 if something is wrong
########################################
commons_load_module() {
	typeset mod=${1}
	shift
	if [[ ${COMMONS_LOADED_MODULES} =~ ${mod} ]]; then
		return 0
	else
		# Is it a core module
		typeset mod_types="core plugins"
		for mod_type in ${mod_types}; do
			test -d ${COMMONS_SHAREDIR}/${mod_type}/${mod} &&
				source ${COMMONS_SHAREDIR}/core/${mod}/init.sh &&
				break
		done
		if [ $? -eq 0 ]; then
			commons_${mod}_init ${@}
			if [ $? -eq 0 ]; then
				COMMONS_LOADED_MODULES="${COMMONS_LOADED_MODULES} ${mod}"
				export COMMONS_LOADED_MODULES
				return 0
			else
				# let's try to unload
				commons_${mod}_cleanup
				commons_print_err "Module ${mod} could not be loaded"
				return 1
			fi
		else
			(commons_print_err "Module ${mod} does not exist" &&
				return 1)
		fi
	fi
}

#######################################
## Execute the cleanup at the end
## Globals:
##   COMMONS_LOADED_MODULES
##   COMMONS_BASEDIR
## Arguments:
##   None
## Returns
##   0
########################################
commons_cleanup() {
	for mod in ${COMMONS_LOADED_MODULES}; do
		if [ "${mod}" != "commons" ]; then
			commons_${mod}_cleanup
		fi
	done
	unset COMMONS_BASEDIR
	return 0
}

#######################################
## Initialization
## Globals:
##   COMMONS_LOADED_MODULES
##   COMMONS_CURRENT_SHELL
##   COMMONS_BASEDIR
## Arguments:
##   None
## Returns
##   rc from commons_load_module logger
########################################
commons_init() {
	trap commons_cleanup EXIT
	COMMONS_LOADED_MODULES="commons"
	COMMONS_CURRENT_SHELL=$(commons_current_shell)
	export COMMONS_LOADED_MODULES
	export COMMONS_CURRENT_SHELL
	export COMMONS_BASEDIR
	commons_load_module logger
	return $?
}

#######################################
## Cleanup alias
## Returns
##   rc from common_cleanup
########################################
cleanup() {
	commons_cleanup
	return $?
}

#######################################
## Initialization alias
## Returns
##   rc from commons_init
########################################
init() {
	commons_init
	return $?
}

if [ -z "${COMMONS_LOADED_MODULES+x}" ]; then
	commons_init
fi
