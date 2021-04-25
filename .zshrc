export ZSH=$HOME/home-git/ohmyzsh
ZSH_DISABLE_COMPFIX=true
ZSH_THEME="robbyrussell"
plugins=(git)
source $ZSH/oh-my-zsh.sh

export PATH=$HOME/bin:$PATH
export N_PREFIX=$HOME/.n

if [ -e $HOME/.secrets ]; then
  . $HOME/.secrets
fi

if [ -e $HOME/.aliases ]; then
  . $HOME/.aliases
fi

pretty-curl() {
  curl $@ | python -mjson.tool
}
