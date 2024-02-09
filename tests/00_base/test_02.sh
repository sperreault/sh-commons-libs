source ../test_lib.sh
source ${COMMONS_BASEDIR}/lib/sh-commons.sh

echo "Loading an existing module"
assert_true commons_load_module logger

echo "Loading a dummy module"
assert_true commons_load_module dummy

echo "Loading a module with not enough parameters"
assert_false commons_load_module cmd

echo "Loading a none existing module"
assert_false commons_load_module unknown
