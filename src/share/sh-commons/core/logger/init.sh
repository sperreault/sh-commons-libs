COMMONS_LOGGER_LOG_FORMAT=${COMMONS_LOGGER_LOG_FORMAT:-RAW}
# Possible Values
# RAW or raw
#
COMMONS_LOGGER_LOG_APPENDER=${COMMONS_LOGGER_LOG_APPENDER:-CONSOLE}
# Possible Values
# CONSOLE or console
#
COMMONS_LOGGER_LOG_LEVEL=${COMMONS_LOGGER_LOG_LEVEL:-INFO}
# Possible Values
# FATAL
# ERROR
# WARN
# INFO <- Default
# DEBUG
# TRACE
typeset -A COMMONS_LOGGER_LOG_NLEVEL
COMMONS_LOGGER_LOG_NLEVEL[TRACE]=6
COMMONS_LOGGER_LOG_NLEVEL[DEBUG]=5
COMMONS_LOGGER_LOG_NLEVEL[INFO]=4
COMMONS_LOGGER_LOG_NLEVEL[WARN]=3
COMMONS_LOGGER_LOG_NLEVEL[ERROR]=2
COMMONS_LOGGER_LOG_NLEVEL[FATAL]=1

commons_logger_format_raw() {
	echo "${@}"
	return $?
}

commons_logger_append_console() {
	echo "${@}" >/dev/fd/2
	return $?
}

_get_nlevel() {
	typeset level=$(commons_to_upper ${1})
	typeset nlevel=${COMMONS_LOGGER_LOG_NLEVEL[${level}]}
	if [ "${nlevel}" == "" ]; then
		nlevel=0
		return 1
	fi
	echo ${nlevel}
	return $?
}

_get_current_nlevel() {
	_get_nlevel ${COMMONS_LOGGER_LOG_LEVEL}
}
_commons_logger_log() {
	if [ ${#} -ge 2 ]; then
		typeset log_level=${1}
		typeset log_nlevel=$(_get_nlevel ${log_level})
		typeset cur_nlevel=$(_get_current_nlevel)
		if [ ${cur_nlevel} -ge ${log_nlevel} ]; then
			typeset message=$(commons_logger_format_${COMMONS_LOGGER_LOG_FORMAT} "${@}")
			shift
			commons_logger_append_${COMMONS_LOGGER_LOG_APPENDER} ${message}
		fi
		return 1
	else
		commons_logger_log_error "Not enough arguments: ${@}"
		return 1
	fi
}

commons_logger_log() {
	if [ ${#} -ge 2 ]; then
		typeset log_level=$(commons_to_lower ${1})
		typeset log_nlevel=$(_get_nlevel ${log_level})
		typeset logger=commons_logger_log_${log_level}
		shift
		if [ "${log_nlevel}" -eq "0" ]; then
			commons_logger_log_error "$(commons_to_upper ${log_level}) is not a valid commons_logger log_level, defaulting to ERROR"
			logger=commons_logger_log_error
		fi
		${logger} ${@}
		return 0
	else
		commons_logger_log_error "Not enough arguments: ${@}"
		return 1
	fi
}

commons_logger_log_trace() {
	_commons_logger_log TRACE ${@}
}

commons_logger_log_debug() {
	_commons_logger_log DEBUG ${@}
}

commons_logger_log_info() {
	_commons_logger_log INFO ${@}
}

commons_logger_log_warn() {
	_commons_logger_log WARN ${@}
}

commons_logger_log_error() {
	_commons_logger_log ERROR ${@}
}

commons_logger_log_fatal() {
	_commons_logger_log FATAL ${@}
}

commons_logger_init() {
	COMMONS_LOGGER_LOG_FORMAT=$(commons_to_lower ${COMMONS_LOGGER_LOG_FORMAT})
	export COMMONS_LOGGER_LOG_FORMAT
	COMMONS_LOGGER_LOG_APPENDER=$(commons_to_lower ${COMMONS_LOGGER_LOG_APPENDER})
	export COMMONS_LOGGER_LOG_APPENDER
	COMMONS_LOGGER_LOG_LEVEL=$(commons_to_lower ${COMMONS_LOGGER_LOG_LEVEL})
	export COMMONS_LOGGER_LOG_LEVEL
}

commons_logger_cleanup() {
	return 0
	# Any cleanup that needs to be done
}
