#!/bin/sh
set -x
# For remote install this script should be run via curl:
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/sperreault/bpl-libs/master/tools/install.sh)" -d /usr/local
# or via wget:
#   sh -c "$(wget -qO- https://raw.githubusercontent.com/sperreault/bpl-libs/master/tools/install.sh)" -d /usr/local
# or via fetch:
#   sh -c "$(fetch -o - https://raw.githubusercontent.com/sperreault/bpl-libs/master/tools/install.sh)" -d /usr/local
#
# For local install this run this script from a cloned version of the main repository
#   Using -d base directory for the installation
#
#   git clone https://github.com/sperreault/bpl-libs
#   cd bpl-libs
#   ./tools/install.sh local -d /usr/local
#
set -e

BPL_NAME=bpl

# Default settings
REPO=${REPO:-sperreault/bpl-libs}
REMOTE=${REMOTE:-https://github.com/${REPO}.git}
BRANCH=${BRANCH:-main}

usage() {
	echo "Usage: $0 [local] -d <install directory>" 1>&2
	exit 1
}

test_install() {
	local dir=$1
	mkdir -p ${dir}/share/${BPL_NAME} &&
		mkdir -p ${dir}/lib &&
		mkdir -p ${dir}/bin
	if [ $? -ne 0 ]; then
		echo "Cannot install into ${dir}, exiting" 1>&2
		exit 1
	fi
	command -v make 1>&2 >/dev/null
	if [ $? -ne 0 ]; then
		echo "Cannot install, we need make" 1>&2
		exit 1
	fi
	return 0
}

perform_install() {
	local src_dir=${1}
	local dest_dir=${2}
	cd ${src_dir}
	DESTDIR=${dest_dir} make
	DESTDIR=${dest_dir} make install
	make clean
	cd -
	return 0
}

remote_git_install() {
	echo "Using remote git installation method"
	local dest_dir=${1}
	test_install ${dest_dir}
	TMPDIR=/tmp/${BPL_NAME}-1234
	git init --quiet "${TMPDIR}" && cd "${TMPDIR}" &&
		git config core.eol lf &&
		git config core.autocrlf false &&
		git config fsck.zeroPaddedFilemode ignore &&
		git config fetch.fsck.zeroPaddedFilemode ignore &&
		git config receive.fsck.zeroPaddedFilemode ignore &&
		git remote add origin "${REMOTE}" &&
		git fetch --depth=1 origin &&
		git checkout -b "${BRANCH}" "origin/${BRANCH}" || {
		[ ! -d "${TMPDIR}" ] || {
			cd -
			rm -rf "${TMPDIR}" 2>/dev/null
		}
		fmt_error "git clone of ${BPL_NAME} repo failed"
		exit 1
	}
	perform_install ${TMPDIR} ${dest_dir}
	return 0
}

local_install() {
	echo "Using local installation method" 1>&2
	local dest_dir=${1}
	local my_dir=$(dirname ${PWD}/${0})
	test_install ${dest_dir}
	local src_dir=${my_dir}/../
	perform_install ${src_dir} ${dest_dir}
	return 0
}

main() {
	if [ -z ${IS_LOCAL+x} ]; then
		install_func=remote_git_install
	else
		install_func=local_install
	fi
	while getopts "d:" arg $@; do
		case $arg in
		d)
			${install_func} $OPTARG
			exit 0
			;;
		*)
			usage
			exit 1
			;;
		esac
	done
}

case "$1" in
local)
	shift
	IS_LOCAL=1
	main $@
	;;
"")
	return 0
	;;
*)
	main $@
	;;
esac
