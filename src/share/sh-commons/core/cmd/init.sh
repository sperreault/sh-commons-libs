COMMONS_CMD_BASE_CMD=${COMMONS_CMD_BASE_CMD}

commons_cmd_sub_commands() {
	typeset sub_cmds=$(ls ${COMMONS_CMD_BASE_CMD}-*)
	typeset ret_sub_cmd
	for i in ${sub_cmds}; do
		typeset this_cmd=$(commons_cmd_script_name ${i})
		if [ $(commons_cmd_script_name ${COMMONS_CMD_BASE_CMD}) != ${this_cmd} ]; then
			ret_sub_cmd="${ret_sub_cmd} ${this_cmd#*-}"
		fi
	done
	echo ${ret_sub_cmd}
	return $?
}

commons_cmd_script_dir() {
	typeset is_cmd=$(command -v -- ${1})
	if [ "${is_cmd}" != '' ]; then
		dirname ${is_cmd}
	else
		echo ''
	fi
	return $?
}

commons_cmd_script_name() {
	basename ${1}
	return $?
}

commons_cmd_script_fullpath() {
	typeset this_script=$(commons_cmd_script_name ${1})
	typeset this_script_dir=$(commons_cmd_script_dir ${1})
	echo ${this_script_dir}/${this_script}
	return $?
}

commons_cmd_run() {
	if [ ${#} -ge 1 ]; then
		typeset this_cmd=${1}
		shift
		typeset sub_cmds=$(commons_cmd_sub_commands)
		if [[ ${sub_cmds} =~ ${this_cmd} ]]; then
			source ${COMMONS_CMD_BASE_CMD}-${this_cmd}
			typeset sub_cmd=$1
			if [ "${sub_cmd}" == "" ]; then
				run
				return $?
			fi
			typeset all_funcs=$(typeset +f)
			if [[ ${all_funcs} =~ "${sub_cmd}()" ]]; then
				if [ ${#} -ge 2 ]; then
					shift
				fi
				${sub_cmd} ${@}
				return $?
			else
				commons_logger_log ERROR "Command ${sub_cmd} does not exist for ${this_cmd}"
				return 1
			fi
		else
			commons_logger_log ERROR "Command ${this_cmd} does not exist for $(commons_cmd_script_name ${COMMONS_CMD_BASE_CMD})"
			return 1
		fi
	else
		help
		return $?
	fi
}

commons_cmd_help() {
	return 0
}

commons_cmd_init() {
	if [ "${COMMONS_CMD_BASE_CMD}" == "" ]; then
		if [ ${#} -ge 1 ]; then
			COMMONS_CMD_BASE_CMD=$(commons_cmd_script_fullpath ${@})
			export COMMONS_CMD_BASE_CMD
			return 0
		else
			return 1
		fi
	else
		return 1
	fi
}

commons_cmd_cleanup() {
	return 0
}
