export ZSH=$HOME/home-git/ohmyzsh
ZSH_DISABLE_COMPFIX=true
ZSH_THEME="robbyrussell"
plugins=(git)
source $ZSH/oh-my-zsh.sh

export AWS_PAGER=

export M2_HOME="$HOME/bin/apache-maven-3.9.5"

PATH="${M2_HOME}/bin:${PATH}"
PATH="/usr/local/opt/libpq/bin:$PATH"
PATH="/usr/local/sbin:$PATH"
PATH="/Applications/Docker.app/Contents/Resources/bin:$PATH"
PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"
export PATH

export N_PREFIX=$HOME/.n
export NODE_ENV=development
export ANDROID_HOME=/Users/mikael/Library/Android/sdk

if [ -e $HOME/.secrets ]; then
  . $HOME/.secrets
fi

if [ -e $HOME/.aliases ]; then
  . $HOME/.aliases
fi

pretty-curl() { curl $@ | python3 -mjson.tool ;}

eval "$(/opt/homebrew/bin/brew shellenv)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
