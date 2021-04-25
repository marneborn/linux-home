## Install [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
### On MA
git --version
xcode-select --install


## Setup SSH:
Get a [ssh key for github](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/)
```
cd ~/.ssh
git init
git add .
git commit -m "created"
```

## Setup environment
```
cd ~
git clone -b mac-zsh --recurse-submodules git@github.com:marneborn/linux-home.git home-git

ln -fs ~/home-git/bin ~/.
ln -fs ~/home-git/.zshrc ~/.
ln -fs ~/home-git/.aliases ~/.
ln -fs ~/home-git/.gitconfig ~/.
ln -fs ~/home-git/.gitignore.global ~/.gitignore
ln -fs ~/home-git/dotemacs ~/.emacs.d
ln -fs ~/home-git/ssh-config ~/.ssh/config

cd ~/.ssh
git init
git add .
git ci -m created
```

## Install [brew](https://brew.sh/)
```
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

## Install node (uses [n](https://www.npmjs.com/package/n)
```
n lts
npm install --global yarn
```

## Install some common CLIs
```
yarn global add mocha-cli eslint-cli ttab uuid moment-timezone
```

## Install [emacs](https://emacsformacosx.com/), if you like.

## Install [meld](https://yousseb.github.io/meld/) a good diff tool.


