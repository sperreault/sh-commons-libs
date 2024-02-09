_utils_dir=${COMMONS_BASEDIR}/lib/${COMMONS_NAME}/utils
if [ -d ${_utils_dir}/install.sh ]; then
	source ${_utils_dir}/update.sh
fi
source ${_utils_dir}/update.sh

commons_utils_init() {
	return 0
}

commons_utils_cleanup() {
	return 0
}
