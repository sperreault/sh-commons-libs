#!/bin/sh

_TEST_DIR=$(dirname ${PWD}/${0})

run_test() {
	typeset mod=${1}
	echo "== Starting tests for ${mod} =="
	cd ${mod}
	for i in *; do
		echo "=== Running test ${i} ==="
		./${i}
		if [ $? -gt 0 ]; then
			echo "=== FAILED ==="
		else
			echo "=== SUCCESS ==="
		fi
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
