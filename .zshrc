export ZSH=$HOME/home-git/ohmyzsh
ZSH_DISABLE_COMPFIX=true
ZSH_THEME="robbyrussell"
plugins=(git)
source $ZSH/oh-my-zsh.sh

export AWS_PAGER=

export M2_HOME="$HOME/bin/apache-maven-3.9.5"

PATH="${M2_HOME}/bin:${PATH}"
PATH="${HOME}/bin:${PATH}"
PATH="${HOME}/.config/yarn/global/node_modules/.bin:${PATH}"
PATH="/usr/local/opt/libpq/bin:$PATH"
PATH="/opt/homebrew/opt/libpq/bin:$PATH"
PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"
PATH="/usr/local/sbin:$PATH"
PATH="/Applications/Docker.app/Contents/Resources/bin:$PATH"
PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"

eval "$(/opt/homebrew/bin/brew shellenv)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

ZSH_DISABLE_COMPFIX=true
ZSH_THEME="robbyrussell"
plugins=(git direnv)
source $ZSH/oh-my-zsh.sh

export AWS_PAGER=

export M2_HOME="$HOME/bin/apache-maven-3.9.5"

export NODE_ENV=development
export ANDROID_HOME=/Users/mikael/Library/Android/sdk

if [ -e $HOME/.secrets ]; then
  . $HOME/.secrets
fi

if [ -e $HOME/.aliases ]; then
  . $HOME/.aliases
fi

pretty-curl() { curl $@ | python3 -mjson.tool ;}

cp-qa-s3-pdf() { aws s3 cp s3://noodle-documents-qa/$1 ~/Desktop/$1.pdf }
export PATH="$HOME/.local/bin:$PATH"

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform

