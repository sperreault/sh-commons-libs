source ../test_lib.sh
source ${COMMONS_BASEDIR}/lib/sh-commons.sh

assert_false commons_logger_log UNKNOWN "This is not a real level"
