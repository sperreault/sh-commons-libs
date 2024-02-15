. ${BPL_BASEDIR}/share/bpl/core/tests/init.sh

tests_init $0
. ${BPL_BASEDIR}/lib/bpl.sh

echo "Loading the module"
load_module logger

echo "Testing logging with default log level INFO"
assert_true logger_log INFO "This is an info message that should display"

echo "Testing all ways to issue the log"
assert_true logger_log info "This is an info message that should display"
assert_true logger_log_info "This is an info message that should display"

echo "Testing different output"
assert_true logger_log INFO "Simple log multi line converted to one line \
message"
assert_true logger_log INFO "Simple log multi line as multiline \n \
message"

echo "Testing not enough args"
assert_false logger_log INFO

echo "Testing logging when the level is lower"
assert_true logger_log DEBUG "This is a debug message that should not display"
assert_true logger_log debug "This is a debug message that should not display"
assert_true logger_log_debug "This is a debug message that should not display"

echo "Testing logging when it's the same level"
BPL_LOGGER_LOG_LEVEL="DEBUG"
assert_true logger_log DEBUG "This is a debug message that should display"
assert_true logger_log debug "This is a debug message that should display"
assert_true logger_log_debug "This is a debug message that should display"

echo "Testing logging when it's a lower level"
assert_true logger_log INFO "This is an info message that should display"
echo "Testing logging when it's a higher level"
assert_true logger_log_trace "This is a trace message that should not display"

echo "Testing a wrong level"
assert_false logger_log UNKNOWN "This is not a real level"

tests_cleanup
