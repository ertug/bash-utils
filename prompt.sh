# A minimal prompt with return code visualization and error description
# Ertug Karamatli <ertug@karamatli.com>

function set_prompt {
	local normal="\[\033[00m\]"
	local black="\[\033[0;30m\]"
	local dgray="\[\033[1;30m\]"
	local blue="\[\033[0;34m\]"
	local lblue="\[\033[1;34m\]"
	local green="\[\033[0;32m\]"
	local lgreen="\[\033[1;32m\]"
	local cyan="\[\033[0;36m\]"
	local lcyan="\[\033[1;36m\]"
	local red="\[\033[0;31m\]"
	local lred="\[\033[1;31m\]"
	local purple="\[\033[0;35m\]"
	local lpurple="\[\033[1;35m\]"
	local brown="\[\033[0;33m\]"
	local yellow="\[\033[1;33m\]"
	local lgray="\[\033[0;37m\]"
	local white="\[\033[1;37m\]"

	trap '_last_cmd=$th_is_cmd; th_is_cmd=$BASH_COMMAND' DEBUG

	function _is_cmd {
		# FIXME: cannot get the last piped command if it is in a subshell
		echo $_last_cmd | tr '|' '\n' | tail -n1 | grep -q "^ *$1"
		echo $?
	}

	function _lookup_retcode {
		local res
		local c

		# error descriptions of these commands are taken from respective man pages
		if [ $(_is_cmd 'grep') -eq 0 ]; then
			c='grep'
			if [ $1 -eq 1 ]; then
				res='not found'
			elif [ $1 -ge 2 ]; then
				res='error occured'
			fi
		fi

		if [ $(_is_cmd 'diff') -eq 0 ]; then
			c='diff'
			if [ $1 -eq 1 ]; then
				res='files are different'
			elif [ $1 -eq 2 ]; then
				res='trouble'
			fi
		fi

		if [ $(_is_cmd 'ls') -eq 0 ]; then
			c='ls'
			if [ $1 -eq 1 ]; then
				res='minor problems (e.g., cannot access subdirectory)'
			elif [ $1 -eq 2 ]; then
				res='serious trouble (e.g., cannot access command-line argument)'
			fi
		fi

		if [ $(_is_cmd 'wget') -eq 0 ]; then
			c='wget'
			if [ $1 -eq 1 ]; then
				res='Generic error'
			elif [ $1 -eq 2 ]; then
				res='Parse error'
			elif [ $1 -eq 3 ]; then
				res='File I/O error'
			elif [ $1 -eq 4 ]; then
				res='Network failure'
			elif [ $1 -eq 5 ]; then
				res='SSL verification failure'
			elif [ $1 -eq 6 ]; then
				res='Username/password authentication failure'
			elif [ $1 -eq 7 ]; then
				res='Protocol errors'
			elif [ $1 -eq 8 ]; then
				res='Server issued an error response'
			fi
		fi

		if [ $(_is_cmd 'ping') -eq 0 ]; then
			c='ping'
			if [ $1 -eq 1 ]; then
				res='no reply'
			elif [ $1 -eq 2 ]; then
				res='error occured'
			fi
		fi

		if [ $(_is_cmd 'mount') -eq 0 -o $(_is_cmd 'umount') -eq 0 ]; then
			c='mount'
			if [ $(($1 & 1)) -ne 0 ]; then
				res='incorrect invocation or permissions'
			elif [ $(($1 & 2)) -ne 0 ]; then
				res='system error (out of memory, cannot fork, no more loop devices)'
			elif [ $(($1 & 4)) -ne 0 ]; then
				res='internal mount bug'
			elif [ $(($1 & 8)) -ne 0 ]; then
				res='user interrupt'
			elif [ $(($1 & 16)) -ne 0 ]; then
				res='problems writing or locking /etc/mtab'
			elif [ $(($1 & 32)) -ne 0 ]; then
				res='mount failure'
			elif [ $(($1 & 64)) -ne 0 ]; then
				res='some mount succeeded'
			fi
		fi

		if [ $(_is_cmd 'ssh') -eq 0 ]; then
			c='ssh'
			if [ $1 -eq 255 ]; then
				res='error occured'
			fi
		fi

		if [ $(_is_cmd 'man') -eq 0 ]; then
			c='man'
			if [ $1 -eq 1 ]; then
				res='Usage, syntax or configuration file error.'
			elif [ $1 -eq 2 ]; then
				res='Operational error.'
			elif [ $1 -eq 3 ]; then
				res='A child process returned a non-zero exit status.'
			elif [ $1 -eq 16 ]; then
				res="At least one of the pages/files/keywords didn't exist or wasn't matched."
			fi
		fi

		# fallback to defaults
		# http://tldp.org/LDP/abs/html/exitcodes.html
		if [ -z "$res" ]; then
			if [ $1 -eq 1 ]; then
				res='General Error'
			elif [ $1 -eq 2 ]; then
				res='Misuse of shell builtins'
			elif [ $1 -eq 126 ]; then
				res='Command cannot execute'
			elif [ $1 -eq 127 ]; then
				res='Command not found'
			elif [ $1 -eq 128 ]; then
				res='Invalid argument to exit'
			elif [ $1 -eq 130 ]; then
				res='User terminated'
			elif [ $1 -eq 255 ]; then
				res='Exit status out of range'
			elif [ $1 -gt 128 -a $1 -le 143 ]; then
				local signum=$(($1-128))
				res="Killed with signal $signum ($(kill -l $signum))"
			fi
		fi

		if [ -n "$c" ]; then
			echo $c: $res
		else
			echo $res
		fi
	}

	function _prompt_cmd {
		_last_code=$?
		# FIXME: clear last error ( : doesn't work)
	}
	export PROMPT_COMMAND=_prompt_cmd

	_last_code_msg='$([ $_last_code -ne 0 ] && echo -ne "*** Return code: $_last_code ($(_lookup_retcode $_last_code)) ***")'
	# TODO: make prompt configurable
	export PS1="${red}${_last_code_msg}\n${green}[${lgreen}\u@\h${green}:${lblue}\w${green}|${blue}\t${green}]${normal} "
}


set_prompt