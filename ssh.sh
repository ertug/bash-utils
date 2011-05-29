# Allows sharing ssh keys across different bash sessions via ssh-agent
# Ertug Karamatli <ertug@karamatli.com>

# initial code from: http://mah.everybody.org/docs/ssh

SSH_ENV="$HOME/.ssh_env"

function start_agent {
     /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
     chmod 600 "${SSH_ENV}"
     . "${SSH_ENV}" > /dev/null
     /usr/bin/ssh-add $(find ~/.ssh -name id_?sa);
}

function keys {
	if [ -f "${SSH_ENV}" ]; then
		/bin/ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
			start_agent;
		}
	else
		start_agent;
	fi
	ssh-add -l
}

if [ -f "${SSH_ENV}" ]; then
	. "${SSH_ENV}" > /dev/null
	/bin/ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
		echo ssh env is old, removing...
		rm ${SSH_ENV}
	}
fi

alias k='keys'
alias nk='ssh-add -D; killall ssh-agent'
