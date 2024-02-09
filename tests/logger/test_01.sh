source ../test_lib.sh
source ${COMMONS_BASEDIR}/lib/sh-commons.sh
commons_load_module logger

assert_true commons_logger_log INFO "Simple log message"
assert_true commons_logger_log INFO "Simple log multi line \
message"

assert_false commons_logger_log INFO

assert_false commons_logger_log TRACE "This is a trace message that should not display"
assert_false commons_logger_log trace "This is a trace message that should not display"
assert_false commons_logger_log_trace "This is a trace message that should not display"

COMMONS_LOGGER_LOG_LEVEL="TRACE"
assert_true commons_logger_log TRACE "This is a trace message that should display"
assert_true commons_logger_log trace "This is a trace message that should display"
assert_true commons_logger_log_trace "This is a trace message that should display"
