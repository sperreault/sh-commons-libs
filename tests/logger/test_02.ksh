. ../test_lib.sh
. ${COMMONS_BASEDIR}/lib/sh-commons.sh

assert_false commons_logger_log UNKNOWN "This is not a real level"
