. ${BPL_BASEDIR}/share/bpl/core/tests/init.sh
tests_init $0
# Test1 - Can we load it
assert_false . ${BPL_BASEDIR}/lib/bpl.sh

tests_cleanup
