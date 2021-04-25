export ZSH=$HOME/.oh-my-zsh
ZSH_THEME="robbyrussell"
plugins=(git)
source $ZSH/oh-my-zsh.sh

export PATH=$HOME/bin:$PATH

if [ -e $HOME/.secrets ]; then
  . $HOME/.secrets
fi

if [ -e $HOME/.aliases ]; then
  . $HOME/.aliases
fi

pretty-curl() {
  curl $@ | python -mjson.tool
}
