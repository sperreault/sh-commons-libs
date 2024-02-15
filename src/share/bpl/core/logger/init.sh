#set -e
BPL_LOGGER_LOG_FORMAT=${BPL_LOGGER_LOG_FORMAT:-RAW}
# Possible Values
# RAW or raw
#
BPL_LOGGER_LOG_APPENDER=${BPL_LOGGER_LOG_APPENDER:-CONSOLE}
# Possible Values
# CONSOLE or console
#
BPL_LOGGER_LOG_LEVEL=${BPL_LOGGER_LOG_LEVEL:-INFO}
# Possible Values
# FATAL
# ERROR
# WARN
# INFO <- Default
# DEBUG
# TRACE
define_hash BPL_LOGGER_LOG_NLEVEL TRACE 6 DEBUG 5 INFO 4 WARN 3 ERROR 2 FATAL 1 ||
	print_err "Your shell is not supported: ${BPL_CURRENT_SHELL}"

logger_format_raw() {
	echo "${@}"
	return $?
}

logger_append_console() {
	echo "${@}" >/dev/fd/2
	return $?
}

_get_nlevel() {
	level=$(to_upper ${1})
	nlevel=$(get_hash_value BPL_LOGGER_LOG_NLEVEL ${level})
	if [ -z ${nlevel} ]; then
		echo 0
		return 1
	else
		echo ${nlevel}
		return 0
	fi
}

_get_current_nlevel() {
	_get_nlevel ${BPL_LOGGER_LOG_LEVEL}
}

_bpl_logger_log() {
	if [ ${#} -ge 2 ]; then
		log_nlevel=${1}
		#log_nlevel=$(_get_nlevel ${log_level})
		cur_nlevel=$(_get_current_nlevel)
		if [ ${cur_nlevel} -ge ${log_nlevel} ]; then
			message=$(logger_format_${BPL_LOGGER_LOG_FORMAT} "${@}")
			shift
			logger_append_${BPL_LOGGER_LOG_APPENDER} ${message}
			return 0
		else
			return 0
		fi
	else
		logger_log_error "Not enough arguments: ${@}"
		return 1
	fi
}

logger_log() {
	if [ ${#} -ge 2 ]; then
		log_level=$(to_lower ${1})
		log_nlevel=$(_get_nlevel ${log_level})
		shift
		if [ ${log_nlevel} -eq 0 ]; then
			logger_log_error "$(to_upper ${log_level}) is not a valid bpl_logger log_level, defaulting to ERROR"
			return 1
		else
			logger_log_${log_level} ${@}
			return 0
		fi
	else
		logger_log_error "Not enough arguments: ${@}"
		return 1
	fi
}

logger_log_trace() {
	n=$(_get_nlevel TRACE)
	_bpl_logger_log ${n} ${@}
}

logger_log_debug() {
	n=$(_get_nlevel DEBUG)
	_bpl_logger_log ${n} ${@}
}

logger_log_info() {
	n=$(_get_nlevel INFO)
	_bpl_logger_log ${n} ${@}
}

logger_log_warn() {
	n=$(_get_nlevel WARN)
	_bpl_logger_log ${n} ${@}
}

logger_log_error() {
	n=$(_get_nlevel ERROR)
	_bpl_logger_log ${n} ${@}
}

logger_log_fatal() {
	n=$(_get_nlevel FATAL)
	_bpl_logger_log ${n} ${@}
}

logger_init() {
	BPL_LOGGER_LOG_FORMAT=$(to_lower ${BPL_LOGGER_LOG_FORMAT})
	export BPL_LOGGER_LOG_FORMAT
	BPL_LOGGER_LOG_APPENDER=$(to_lower ${BPL_LOGGER_LOG_APPENDER})
	export BPL_LOGGER_LOG_APPENDER
	BPL_LOGGER_LOG_LEVEL=$(to_lower ${BPL_LOGGER_LOG_LEVEL})
	export BPL_LOGGER_LOG_LEVEL
}

logger_cleanup() {
	return 0
	# Any cleanup that needs to be done
}
