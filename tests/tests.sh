#!/bin/sh

_TEST_DIR=$(dirname ${PWD}/${0})

SHELLS="sh bash ksh"

run_test() {
	typeset mod=${1}
	echo "== Starting tests for ${mod} =="
	cd ${mod}
	for i in *; do
		f=$(basename -- "${i}")
		e="${f##*.}"
		echo "=== Running test ${i} ==="
		$(command -v ${e}) ${i}
		echo "=== ${i} Done ==="
	done
	cd ..
	echo "== Ending tests for ${mod} =="
}

run_tests() {
	echo "= Starting Tests for shell-commons ="
	for i in *; do
		if [ -d ${i} ]; then
			run_test ${i}
		fi
	done
	echo "= Ending Tests for shell-commons ="
}

COMMONS_BASEDIR=${_TEST_DIR}/../build
export COMMONS_BASEDIR
cd ${_TEST_DIR}
run_tests
