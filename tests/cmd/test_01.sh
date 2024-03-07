. ${BPL_BASEDIR}/share/bpl/core/tests/init.sh

tests_init $0

. ${BPL_BASEDIR}/lib/bpl.sh
echo "Loading the module"
load_module cmd $0

assert_equal $(basename $0) bpl_cmd_script_name $0

tests_cleanup
