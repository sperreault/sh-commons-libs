assert_true() {
	cmd=$1
	shift
	out=$(${cmd} $@ 2>&1)
	if [ $? -gt 0 ]; then
		echo "FAILED - ${cmd} $@"
		echo "${out}"
		exit 1
	else
		echo "PASS - ${cmd} $@"
		return 0
	fi
}

assert_false() {
	cmd=$1
	shift
	out=$(${cmd} $@ 2>&1)
	if [ $? -gt 1 ]; then
		echo "FAILED - ${cmd} $@"
		echo "${out}"
		exit 1
	else
		echo "PASS - ${cmd} $@"
		return 0
	fi

}
