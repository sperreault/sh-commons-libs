#######################################
## bpl - Common Shell Library
##
## Common Shell Library is meant to be
## a common library that provided some
## standard functions that could be used
## in various shell scripts.
## It currently aims at supporting the
## following shells:
## - Bourne Shell - sh
## - Bourne Again Shell - bash
## - Korn Shell - ksh
#######################################

BPL_NAME=bpl
BPL_BASEDIR=${BPL_BASEDIR:-@DESTDIR@}
BPL_SHAREDIR=${BPL_BASEDIR}/share/${BPL_NAME}

#######################################
## Find out which shell we are using
## Globals:
##   BPL_CURRENT_SHELL
## Arguments:
##   None
## Outputs:
##   String which should be sh, ksh
## Returns
##  rc from command
#######################################
current_shell() {
	if [ ! -z ${BPL_CURRENT_SHELL+x} ]; then
		echo ${BPL_CURRENT_SHELL}
		return 0
	else
		ps=$(ps -p $$ -o command 2>&1) || (
			bpl_print_err ${ps}
			exit 1
		)
		sh=$(echo ${ps} | awk '{print $2}')
		fullpath=$(command -v $sh) || exit 1
		# are we a symlink
		#symlink=$(command -v $(ls -l ${fullpath} | awk '{print $11}'))
		ver=$($fullpath --version 2>&1)
		retval=${?}
		if [ ${retval} -gt 0 ]; then
			# we assume bourne shell
			case ${fullpath} in
			*ash)
				echo "not_supported"
				return 1
				;;
			*sh)
				echo "sh"
				return 0
				;;
			*)
				echo "not_supported"
				return 1
				;;
			esac
		else
			case "${ver}" in
			*bash*)
				declare -A >/dev/null 2>&1
				if [ $? -eq 0 ]; then
					echo "bash"
					return 0
				else
					# we are POSIX strict
					echo "sh"
					return 0
				fi
				;;
			*93*)
				echo "ksh"
				return 0
				;;
			*)
				echo "not_supported"
				return 1
				;;
			esac
		fi
	fi
}

#######################################
## Private function to define a pseudo
## hash in Bourne shell
## Arguments:
##   String Variable Name
##   String Multiple Key Value pairs
## Outputs:
##   None
## Returns
##  rc 0
#######################################
_bpl_define_hash_sh() {
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
	return 0
}

#######################################
## Private wrapper to define a hash
## in Korn shell
## Arguments:
##   String Variable Name
##   String Multiple Key Value pairs
## Outputs:
##   None
## Returns
##  rc 0
#######################################
_bpl_define_hash_ksh() {
	typeset -A ${var_name}
	export ${var_name}
	shift
	_bpl_define_hash_not_posix ${var_name} ${@}
	return 0
}

#######################################
## Private wrapper to define a hash
## in Bourne Again shell
## Arguments:
##   String Variable Name
##   String Multiple Key Value pairs
## Outputs:
##   None
## Returns
##  rc 0
#######################################
_bpl_define_hash_bash() {
	declare -A ${var_name}
	export ${var_name}
	shift
	_bpl_define_hash_not_posix ${var_name} ${@}
	return 0
}

#######################################
## Private function to define a hash
## for not POSIX compliant shells
## Arguments:
##   String Variable Name
##   String Multiple Key Value pairs
## Outputs:
##   None
## Returns
##  rc 0
#######################################
_bpl_define_hash_not_posix() {
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
	return 0
}

#######################################
## Wrapper function for hash creation
## works on POSIX and not POSIX compliant
## shells
## Arguments:
##   String Variable Name
##   String Multiple Key Value pairs
## Outputs:
##   None
## Returns
##  rc 0 If the right number of args are
##  passed
##     1 If you passed args that cannot
##  be devided by 2
#######################################
define_hash() {
	var_name=$1
	shift
	if [ ${#}%2==0 ]; then
		# TODO: Use features from Bash and KSH
		#_bpl_define_hash_${BPL_CURRENT_SHELL} ${var_name} ${@} && return 0 || return 1
		_bpl_define_hash_sh ${var_name} ${@} && return 0 || return 1
		return 0
	else
		echo "Your argument list $* can not be devided by 2"
		return 1
	fi
}

#######################################
## Private function to get value out
## of the pseudo hash on Bourne shell
## VAR_KEY is the convention
## Arguments:
##   String Variable Name
##   String Key
## Outputs:
##   String value
## Returns
##  rc from command
#######################################
_bpl_get_hash_value_sh() {
	v=${1}_${2}
	eval a=\$${v}
	r=$?
	echo ${a}
	return ${r}
}

#######################################
## Private function to get value out
## of a Bash shell hash
## VAR[KEY] is the convention
## Arguments:
##   String Variable Name
##   String Key
## Outputs:
##   String value
## Returns
##  rc from command
#######################################
_bpl_get_hash_value_bash() {
	declare | grep $1
	b=${a["$2"]}
	if [ "$b" != "[${2}]" ]; then
		echo ${a}
		return 0
	else
		echo
		return 1
	fi
}

#######################################
## Private function to get value out
## of a Korn shell hash
## VAR[KEY] is the convention
## Arguments:
##   String Variable Name
##   String Key
## Outputs:
##   String value
## Returns
##  rc from command
#######################################
_bpl_get_hash_value_ksh() {
	typeset -n v="${1}[${2}]"
	echo ${v}
	return $?
}

#######################################
## Function to get value out hashes
## defined with bpl_define_hash
## Arguments:
##   String Variable Name
##   String Key
## Outputs:
##   String value
## Returns
##  rc 0 for success
##     1 for failure
#######################################
get_hash_value() {
	# TODO: Use features from Bash and KSH
	#v=$(_bpl_get_hash_value_${BPL_CURRENT_SHELL} $@)
	v=$(_bpl_get_hash_value_sh $@)
	if [ -z "${v}" ]; then
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
to_upper() {
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
to_lower() {
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
# define_hash() {
# 	name=$1
# 	shift
# 	eval "$name"='$value'
# }

print_info() {
	echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')] [ INFO ]: $*"
	return $?
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
print_err() {
	echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')] [ ERROR ]: $*" >&2
	return $?
}

#######################################
## List the available functions in the 
## module. It removes _bpl as they are
## treated as private functions.
## Arguments:
##   Module path
## Outputs:
##   List of all the functions
## Returns
##  rc from command
#######################################
list_functions () {
  module = $1
  if [ -f ${module} == "bpl" ]; then
    functions=$(cat src/lib/bpl.sh| grep -v "^#" | grep "().{"  |grep -v _bpl | sed 's/()\ {//' | sort)
  
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
check_command() {
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
##   BPL_LOADED_MODULES
##   BPL_BASEDIR
## Arguments:
##   Module name
##   Module parameters
## Returns
##   0 if all is good
##   1 if something is wrong
########################################
load_module() {
	mod=${1}
	shift
	$(echo ${BPL_LOADED_MODULES} | grep -q ${mod})
	if [ $? -eq 0 ]; then
		return 0
	else
		# Is it a core module
		mod_types="core plugins"
		for mod_type in ${mod_types}; do
			test -d ${BPL_SHAREDIR}/${mod_type}/${mod} &&
				. ${BPL_SHAREDIR}/core/${mod}/init.sh &&
				break
		done
		if [ $? -eq 0 ]; then
			${mod}_init ${@}
			if [ $? -eq 0 ]; then
				BPL_LOADED_MODULES="${BPL_LOADED_MODULES} ${mod}"
				export BPL_LOADED_MODULES
				return 0
			else
				# let's try to unload
				${mod}_cleanup
				print_err "Module ${mod} could not be loaded"
				return 1
			fi
		else
			(print_err "Module ${mod} does not exist" &&
				return 1)
		fi
	fi
}

#######################################
## Execute the cleanup at the end
## Globals:
##   BPL_LOADED_MODULES
##   BPL_BASEDIR
## Arguments:
##   None
## Returns
##   0
########################################
cleanup() {
	for mod in ${BPL_LOADED_MODULES}; do
		if [ "${mod}" != "bpl" ]; then
			${mod}_cleanup
		fi
	done
	unset BPL_BASEDIR
	return 0
}

#######################################
## Initialization
## Globals:
##   BPL_LOADED_MODULES
##   BPL_CURRENT_SHELL
##   BPL_BASEDIR
## Arguments:
##   None
## Returns
##   rc 0
########################################
init() {
	BPL_CURRENT_SHELL=$(current_shell)
	if [ $? -gt 0 ]; then
		print_err ${BPL_CURRENT_SHELL}
		exit 1
		return 1
	else
		BPL_LOADED_MODULES="bpl"
		export BPL_LOADED_MODULES
		export BPL_CURRENT_SHELL
		export BPL_BASEDIR
		export BPL_SHAREDIR
		$BPL_CURRENT_SH
		trap cleanup EXIT
		return 0
	fi
}

if [ -z "${BPL_LOADED_MODULES+x}" ]; then
	init
fi
