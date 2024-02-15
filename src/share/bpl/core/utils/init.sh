_utils_dir=${BPL_BASEDIR}/lib/${BPL_NAME}/utils
if [ -d ${_utils_dir}/install.sh ]; then
	. ${_utils_dir}/update.sh
fi
. ${_utils_dir}/update.sh

utils_init() {
	return 0
}

utils_cleanup() {
	return 0
}
