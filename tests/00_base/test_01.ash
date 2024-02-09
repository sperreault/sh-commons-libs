source ../test_lib.sh
# Test1 - Can we load it
assert_false source ${COMMONS_BASEDIR}/lib/sh-commons.sh
# Test1 - Reload it
assert_false source ${COMMONS_BASEDIR}/lib/sh-commons.sh
