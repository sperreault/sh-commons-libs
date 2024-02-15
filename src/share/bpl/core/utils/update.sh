bpl_utils_update_git() {
	typeset cmd=$1
	cd ${bpl_SHAREDIR}
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

bpl_utils_update_curl() {
	return 1
}

bpl_utils_update_wget() {
	return 1
}

_bpl_utils_update_pre_checks() {
	(
		touch ${bpl_SHAREDIR}/.tmp &&
			rm ${bpl_SHAREDIR}/.tmp &&
	) ||
		(
			bpl_print_err "Cannot write to ${bpl_BASEDIR}/lib/${bpl_NAME}" &&
				return 1
		)
}

bpl_utils_update() {
	_bpl_utils_update_pre_checks
	if [ $? -eq 0 ]; then
		(cmd=$(bpl_check_command git) && bpl_utils_update_git ${cmd}) ||
			(cmd=$(bpl_check_command curl) && bpl_utils_update_curl ${cmd}) ||
			(cmd=$(bpl_check_command wget) && bpl_utils_update_wget ${cmd}) ||
			(bpl_print_err "Cannot find git / curl or wget to perform the update" && return 1)
	fi
	return $?
}
