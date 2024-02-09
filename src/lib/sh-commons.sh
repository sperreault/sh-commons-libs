COMMONS_NAME=sh-commons
COMMONS_BASEDIR=${COMMONS_BASEDIR:-@DESTDIR@}
COMMONS_SHAREDIR=${COMMONS_BASEDIR}/share/${COMMONS_NAME}
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
				commons_logger_log ERROR "Module ${mod} could not be loaded"
				return 1
			fi
		else
			(commons_logger_log ERROR "Module ${mod} does not exist" &&
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
##   COMMONS_BASEDIR
## Arguments:
##   None
## Returns
##   rc from commons_load_module logger
########################################
commons_init() {
	trap commons_cleanup EXIT
	COMMONS_LOADED_MODULES="commons"
	export COMMONS_LOADED_MODULES
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
