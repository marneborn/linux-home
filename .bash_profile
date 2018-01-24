export PATH=$PATH:$HOME/bin:$HOME/Library/Android/sdk/platform-tools:$HOME/Library/Android/sdk/tools/bin
export NODE_ENV=development
export PG_ROOT=/Users/mikael/DBs/postgres
export DEBUG=keyo:*
export ANDROID_HOME=/Users/mikael/Library/Android/sdk
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_144.jdk/Contents/Home

if [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm

#. "$HOME/.sdkman/bin/sdkman-init.sh"
#[ -f /usr/local/lib/node_modules/yarn-completions/node_modules/tabtab/.completions/yarn.bash ] && . /usr/local/lib/node_modules/yarn-completions/node_modules/tabtab/.completions/yarn.bash
# . /usr/local/lib/node_modules/yarn-completions/node_modules/tabtab/.completions/yarn.bash
# . $HOME/bin/npm-completion.bash

parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
set-title() {
    echo -ne "\033]0;"$*"\007"
}

set_bash_prompt(){
    set-title $(git rev-parse --show-toplevel 2>&1 | perl -p -e 'use Cwd; if (/^fatal/) { $_ = cwd(); } chomp; s/.*\///;')
    PS1="\[\033[32m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\] $ "
}

PROMPT_COMMAND=set_bash_prompt

alias ll="ls -ltr"
alias ngrep="grep -r --exclude-dir node_modules --exclude-dir .git --exclude-dir RCTImage.build"
alias em-nexus5="cd $ANDROID_HOME/tools && ./emulator -avd Nexus_5_API_26"
alias show-cursor="tput cvvis"

pretty-curl() {
  curl $@ | python -mjson.tool
}

source ~/bin/keyo-setup.sh

