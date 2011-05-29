# Miscellaneous utilities
# Ertug Karamatli <ertug@karamatli.com>

# fix typos for cd
shopt -s cdspell

# cd to a directory without typing cd
if [ ${BASH_VERSINFO[0]} -ge 4 ]; then
	shopt -s autocd
fi
