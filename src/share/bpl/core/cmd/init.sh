BPL_CMD_BASE_CMD=${BPL_CMD_BASE_CMD}

bpl_cmd_sub_commands() {
	sub_cmds=$(ls ${BPL_CMD_BASE_CMD}-*)
	for i in ${sub_cmds}; do
		this_cmd=$(bpl_cmd_script_name ${i})
		if [ $(bpl_cmd_script_name ${BPL_CMD_BASE_CMD}) != ${this_cmd} ]; then
			ret_sub_cmd="${ret_sub_cmd} ${this_cmd#*-}"
		fi
	done
	echo ${ret_sub_cmd}
	return $?
}

bpl_cmd_script_dir() {
	is_cmd=$(command -v -- ${1})
	if [ "${is_cmd}" != '' ]; then
		dirname ${is_cmd}
	else
		echo ''
	fi
	return $?
}

bpl_cmd_script_name() {
	basename ${1}
	return $?
}

bpl_cmd_script_fullpath() {
	this_script=$(bpl_cmd_script_name ${1})
	this_script_dir=$(bpl_cmd_script_dir ${1})
	echo ${this_script_dir}/${this_script}
	return $?
}

bpl_cmd_run() {
	if [ ${#} -ge 1 ]; then
		this_cmd=${1}
		shift
		sub_cmds=$(bpl_cmd_sub_commands)
		if [ ${sub_cmds} =~ ${this_cmd} ]; then
			. ${BPL_CMD_BASE_CMD}-${this_cmd}
			sub_cmd=$1
			if [ "${sub_cmd}" == "" ]; then
				run
				return $?
			fi
			all_funcs=$(+f)
			if [ ${all_funcs} =~ "${sub_cmd}()" ]; then
				if [ ${#} -ge 2 ]; then
					shift
				fi
				${sub_cmd} ${@}
				return $?
			else
				bpl_logger_log ERROR "Command ${sub_cmd} does not exist for ${this_cmd}"
				return 1
			fi
		else
			bpl_logger_log ERROR "Command ${this_cmd} does not exist for $(bpl_cmd_script_name ${BPL_CMD_BASE_CMD})"
			return 1
		fi
	else
		help
		return $?
	fi
}

bpl_cmd_help() {
	return 0
}

cmd_init() {
	if [ ! -z "${BPL_CMD_BASE_CMD+x}" ]; then
		if [ ${#} -ge 1 ]; then
			BPL_CMD_BASE_CMD=$(bpl_cmd_script_fullpath ${@})
			export BPL_CMD_BASE_CMD
			load_module logger
			return 0
		else
			return 1
		fi
	else
		return 1
	fi
}

cmd_cleanup() {
	return 0
}
