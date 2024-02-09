commons_utils_update_git() {
	typeset cmd=$1
	cd ${COMMONS_SHAREDIR}
  git init --quiet "$ZSH" && cd "$ZSH" \
  && git config core.eol lf \
  && git config core.autocrlf false \
  && git config fsck.zeroPaddedFilemode ignore \
  && git config fetch.fsck.zeroPaddedFilemode ignore \
  && git config receive.fsck.zeroPaddedFilemode ignore \
  && git config oh-my-zsh.remote origin \
  && git config oh-my-zsh.branch "$BRANCH" \
  && git remote add origin "$REMOTE" \
  && git fetch --depth=1 origin \
  && git checkout -b "$BRANCH" "origin/$BRANCH" || {
    [ ! -d "$ZSH" ] || {
      cd -
      rm -rf "$ZSH" 2>/dev/null
    }
    fmt_error "git clone of oh-my-zsh repo failed"
    exit 1
  }
  
}

commons_utils_update_curl() {
	return 1
}

commons_utils_update_wget() {
	return 1
}

_commons_utils_update_pre_checks() {
	(
		touch ${COMMONS_SHAREDIR}/.tmp &&
			rm ${COMMONS_SHAREDIR}/.tmp &&
	) ||
		(
			commons_print_err "Cannot write to ${COMMONS_BASEDIR}/lib/${COMMONS_NAME}" &&
				return 1
		)
}

commons_utils_update() {
	_commons_utils_update_pre_checks
	if [ $? -eq 0 ]; then
		(cmd=$(commons_check_command git) && commons_utils_update_git ${cmd}) ||
			(cmd=$(commons_check_command curl) && commons_utils_update_curl ${cmd}) ||
			(cmd=$(commons_check_command wget) && commons_utils_update_wget ${cmd}) ||
			(commons_print_err "Cannot find git / curl or wget to perform the update" && return 1)
	fi
	return $?
}
