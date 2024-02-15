BPL_TEST_COUNT=${BPL_TEST_COUNT:-0}
#######################################
## Assert if the command / function is
## returning 0 (true)
## Arguments:
##   String command
##   String arguments to the command
## Returns
##   0 - PASS
##   1 - FAILED and exit
########################################
assert_true() {
	BPL_TEST_COUNT=$((BPL_TEST_COUNT + 1))
	cmd=$1
	shift
	out=$(${cmd} $@ 2>&1)
	if [ $? -ne 0 ]; then
		BPL_TEST_FAIL_COUNT=$((BPL_TEST_FAIL_COUNT + 1))
		echo "FAILED - ${cmd} $@"
		echo "${out}"
		tests_cleanup
		exit 1
	else
		BPL_TEST_PASS_COUNT=$((BPL_TEST_PASS_COUNT + 1))
		echo "PASS - ${cmd} $@"
		return 0
	fi
}

#######################################
## Assert if the command / function is
## returning 1 (false)
## Arguments:
##   String command
##   String arguments to the command
## Returns
##   0 - PASS
##   1 - FAILED and exit
########################################
assert_false() {
	BPL_TEST_COUNT=$((BPL_TEST_COUNT + 1))
	cmd=$1
	shift
	out=$(${cmd} $@ 2>&1)
	if [ $? -eq 0 ]; then
		BPL_TEST_FAIL_COUNT=$((BPL_TEST_FAIL_COUNT + 1))
		echo "FAILED - ${cmd} $@"
		echo "${out}"
		tests_cleanup
		exit 1
	else
		BPL_TEST_PASS_COUNT=$((BPL_TEST_PASS_COUNT + 1))
		echo "PASS - ${cmd} $@"
		return 0
	fi
}

#######################################
## Assert if the command / function is
## returning the same value on STDOUT
## Arguments:
##   String expected output
##   String command
##   String arguments to the command
## Returns
##   0 - PASS
##   1 - FAILED and exit
########################################
assert_equal() {
	expected=$1
	shift
	cmd=$1
	shift
	out=$(${cmd} $@ 2>&1)
	if [ $? -eq 0 ]; then
		if [ "${expected}" = "${out}" ]; then
			BPL_TEST_PASS_COUNT=$((BPL_TEST_PASS_COUNT + 1))
			echo "PASS - ${cmd} $@"
			return 0
		else
			BPL_TEST_FAIL_COUNT=$((BPL_TEST_FAIL_COUNT + 1))
			echo "FAILED - ${cmd} $@"
			echo "${out}"
			tests_cleanup
			exit 1
		fi
	else
		BPL_TEST_FAIL_COUNT=$((BPL_TEST_FAIL_COUNT + 1))
		echo "FAILED - ${cmd} $@"
		echo "${out}"
		tests_cleanup
		exit 1
	fi
}

tests_cleanup() {
	echo "----------------------------------------------------------------------"
	echo "Ran ${BPL_TEST_COUNT} tests, ${BPL_TEST_PASS_COUNT} passed, ${BPL_TEST_FAIL_COUNT} failed"
	echo ""
	exit ${BPL_TEST_FAIL_COUNT}
}

tests_init() {
	echo ""
	echo "----------------------------------------------------------------------"
	if [ $# -eq 1 ]; then
		echo "$1"
		echo "----------------------------------------------------------------------"
	fi
	BPL_TEST_COUNT=0
	BPL_TEST_PASS_COUNT=0
	BPL_TEST_FAIL_COUNT=0
	export BPL_TEST_COUNT BPL_TEST_PASS_COUNT BPL_TEST_FAIL_COUNT
}
