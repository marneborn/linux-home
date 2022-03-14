export ZSH=$HOME/home-git/ohmyzsh
ZSH_DISABLE_COMPFIX=true
ZSH_THEME="robbyrussell"
plugins=(git)
source $ZSH/oh-my-zsh.sh

export AWS_PAGER=

export PATH=$HOME/bin:/usr/local/sbin:$PATH
export N_PREFIX=$HOME/.n
export NODE_ENV=development

if [ -e $HOME/.secrets ]; then
  . $HOME/.secrets
fi

if [ -e $HOME/.aliases ]; then
  . $HOME/.aliases
fi

pretty-curl() {
  curl $@ | python -mjson.tool
}

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
