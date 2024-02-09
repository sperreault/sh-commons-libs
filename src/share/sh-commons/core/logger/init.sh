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
commons_define_hash COMMONS_LOGGER_LOG_NLEVEL TRACE 6 DEBUG 5 INFO 4 WARN 3 ERROR 2 FATAL 1 ||
	commons_print_err "Your shell is not supported: ${COMMONS_CURRENT_SHELL}"

commons_logger_format_raw() {
	echo "${@}"
	return $?
}

commons_logger_append_console() {
	echo "${@}" >/dev/fd/2
	return $?
}

_get_nlevel() {
	level=$(commons_to_upper ${1})
	nlevel=$(commons_get_hash_value COMMONS_LOGGER_LOG_NLEVEL ${level})
	if [ "${nlevel}" == "" ]; then
		echo 0
		return 1
	else
		echo ${nlevel}
		return 0
	fi
}

_get_current_nlevel() {
	_get_nlevel ${COMMONS_LOGGER_LOG_LEVEL}
}
_commons_logger_log() {
	if [ ${#} -ge 2 ]; then
		log_level=${1}
		log_nlevel=$(_get_nlevel ${log_level})
		cur_nlevel=$(_get_current_nlevel)
		if [ ${cur_nlevel} -ge ${log_nlevel} ]; then
			message=$(commons_logger_format_${COMMONS_LOGGER_LOG_FORMAT} "${@}")
			shift
			commons_logger_append_${COMMONS_LOGGER_LOG_APPENDER} ${message}
			return 0
		fi
		return 1
	else
		commons_logger_log_error "Not enough arguments: ${@}"
		return 1
	fi
}

commons_logger_log() {
	if [ ${#} -ge 2 ]; then
		log_level=$(commons_to_lower ${1})
		log_nlevel=$(_get_nlevel ${log_level})
		logger=commons_logger_log_${log_level}
		shift
		if [ "${log_nlevel}" == "0" ]; then
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
