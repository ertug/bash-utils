# History utilities
# Ertug Karamatli <ertug@karamatli.com>

# store a big history, ^R is a good friend
export HISTSIZE=1000000
export HISTFILESIZE=1000000

# do not store commands starting with a space and ignore duplicates
export HISTCONTROL=ignorespace:ignoredups:erasedups

# append rather than overwrite
shopt -s histappend

# store multiline commands
shopt -s cmdhist

# sync history across sessions
export PROMPT_COMMAND="$PROMPT_COMMAND; history -a; history -c; history -r"

# most used commands
function histstats {
	cnt=30
	if [ -n "$1" ]; then
		cnt=$1
	fi
	cut -f1 -d' ' .bash_history | sort | uniq -c | sort -nr | head -n $cnt
}
