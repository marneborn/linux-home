
export PATH=$PATH:~/bin

export NODE_ENV=development
export PG_ROOT=/Users/mikael/DBs/postgres

source /usr/local/etc/bash_completion.d/git-completion.bash 

parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
export PS1="\[\033[32m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\] $ "

alias ll=ls -ltr
alias ngrep="grep -r --exclude-dir node_modules --exclude-dir .git"

pretty-curl() {
  curl $@ | python -mjson.tool
}

source ~/bin/keyo-setup.sh
