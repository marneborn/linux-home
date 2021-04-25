## Install [xcode](https://developer.apple.com/xcode/)
## Install [Android Studio](https://developer.android.com/studio/)

## Setup environment
```
cd ~
git clone -b mac-zsh --recurse-submodules git@github.com:marneborn/linux-home.git home-git

ln -fs ~/home-git/bin ~/.
ln -fs ~/home-git/.zshrc ~/.
ln -fs ~/home-git/.aliases ~/.
ln -fs ~/home-git/.gitconfig ~/.
ln -fs ~/home-git/.gitignore.global ~/.gitignore
ln -fs ~/home-git/.emacs.d ~/.
```

## Install [brew](https://brew.sh/)
```
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

## Install [nodejs](https://nodejs.org/en/download/)

## Install [n](https://www.npmjs.com/package/n)
##### This allows us to easily change the version of node we are running.

Install and set version to 8.11.3
```
curl -L https://raw.githubusercontent.com/tj/n/master/bin/n -o n
bash n lts
```
## Install [yarn](https://yarnpkg.com/lang/en/docs/install/#mac-stable)
```
brew install yarn
```

## Install some common CLIs
```
yarn global add mocha-cli
yarn global add eslint
yarn global add ttab
yarn global add nodemon
```

## Install [emacs](https://emacsformacosx.com/), if you like.

## Install [meld](https://github.com/yousseb/meld/releases/) a good diff tool.

## Install [bash completion](), mostly for git-completion
```
brew install bash-completion
```

## Setup SSH:
Get a [ssh key for github](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/)
```
cd ~/.ssh
git init
git add .
git commit -m "created"
```

