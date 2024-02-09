#!/bin/sh
echo COMMONS_BASEDIR=$COMMONS_BASEDIR
source ${COMMONS_BASEDIR}/lib/sh-commons.sh
init

echo "Simple logging"
commons_logger_log INFO "Simple log message"
commons_logger_log INFO "Simple log multi line \
message"

echo "Not enough arguments"
commons_logger_log INFO

echo "Doing TRACE level, nothing should display"
commons_logger_log TRACE "This is a trace message that should not display"
commons_logger_log trace "This is a trace message that should not display"
commons_logger_log_trace "This is a trace message that should not display"

COMMONS_LOGGER_LOG_LEVEL="TRACE"
echo "Doing TRACE level, now should display"
commons_logger_log TRACE "This is a trace message that should display"
commons_logger_log trace "This is a trace message that should display"
commons_logger_log_trace "This is a trace message that should display"

cleanup
