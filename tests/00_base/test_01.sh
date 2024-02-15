. ${BPL_BASEDIR}/share/bpl/core/tests/init.sh

tests_init $0

echo "Can we load it"
assert_true . ${BPL_BASEDIR}/lib/bpl.sh
. ${BPL_BASEDIR}/lib/bpl.sh

echo "Try to reload"
assert_true . ${BPL_BASEDIR}/lib/bpl.sh

echo "Loading a dummy module"
assert_true load_module dummy

echo "Loading a module with not enough parameters"
assert_false load_module cmd

echo "Loading a none existing module"
assert_false load_module unknown

echo "Test to_lower"
assert_equal "lower" to_lower LOWER

echo "Test to_upper"
assert_equal "UPPER" to_upper upper

echo "Test to_lower multiword"
assert_equal "lower case" to_lower "Lower Case"

tests_cleanup
