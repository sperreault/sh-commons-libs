#!/bin/ksh
declare s='\s'
echo ' ' | eval "grep -Eq '${s}'" || s='[[:space:]]'

# MacOS ships with a (non-GNU) version of sed which both lacks the '-r' option,
# but instead uses '-E'.  It still can't grok '\s' for [[:space:]], though...
# Worse, MacOS/BSD sed doesn't understand '\+', so extended mode is required.
sed='sed -r'
echo '' | ${sed} >/dev/null 2>&1 || sed='sed -E'

[[ "$(echo ' ' | ${sed} 's/\s/x/')" == 'x' ]] || s='[[:space:]]'

function __BPL_API_1_lala() {
	echo "lala"
	return 0
}
while read -r fapi; do
	echo ${fapi}
	if grep -q '^__BPL_API_' <<<"${fapi}"; then
		# Ensure that function is still available...
		#
		if [[ 'function' == "$(type -t "${fapi}" 2>/dev/null)" ]]; then

			# Make functions available to child shells...
			#
			# shellcheck disable=SC2163
			export -f "${fapi}"

			declare -i api
			# shellcheck disable=SC2086
			for api in $(seq ${__STDLIB_API} -1 1); do
				if grep -q "^__STDLIB_API_${api}_" <<<"${fapi}"; then
					if fname="$(${sed} 's/^__STDLIB_API_[0-9]+_//' <<<"${fapi}")"; then
						__STDLIB_functionlist+=("${fname}")
						eval "function ${fname}() { ${fapi} \"\${@:-}\"; }"

						# Make functions available to child shells...
						#
						# shellcheck disable=SC2163
						export -f "${fname}"

						# Clear the variable, not the function definition...
						#
						unset fname

						# Don't create any further accessors for this name...
						#
						break
					fi
				fi
			done
			unset api
		fi
	fi
done < <(
	grep 'function' b.sh |
		sed 's/#.*$//' |
		eval "grep -E '^${s}*function${s}+[a-zA-Z_]+[a-zA-Z0-9_:\-]*${s}*\(\)${s}*\{?${s}*$'" |
		${sed} "s/^${s}*function${s}+([a-zA-Z_]+[a-zA-Z0-9_:\-]*)${s}*\(\)${s}*\{?${s}*$/\1/"
)
unset fapi sed s
