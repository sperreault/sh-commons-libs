#!/bin/bash

_TEST_DIR=$(dirname ${PWD}/${0})

SHELLS="sh bash ksh"

run_test() {
	mod=${1}
	echo "== Starting tests for ${mod} =="
	cd ${mod}
	for i in *; do
		f=$(basename -- "${i}")
		cmd=$(command -v ${f##*.})
		if [ ! -z ${cmd+x} ]; then
			echo "=== Running test ${i} ==="
			${cmd} ${i}
		else
			echo "=== Failed ${i} ==="
		fi
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

BPL_BASEDIR=${_TEST_DIR}/../build
export BPL_BASEDIR
cd ${_TEST_DIR}
run_tests
