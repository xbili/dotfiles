# ---------- Aliases ------------ #

# Git
alias g='git'
alias gst='git status'

# Chrome
alias chrome="/Applications/Google\ \Chrome.app/Contents/MacOS/Google\ \Chrome"

# For MacVim
alias vim='mvim'


# ------------ PATH --------- #

# Heroku
export PATH="/usr/local/heroku/bin:$PATH"

# Git 2.*
export PATH="/usr/local/git/bin:$PATH"

# PHPUnit
export PATH="~/.composer/vendor/bin:$PATH"

# ChromeDriver
export PATH="/usr/local/chromedriver:$PATH"

# RVM
export PATH="$PATH:$HOME/.rvm/bin"



# ---------- Environment Variables ------------ #

export EDITOR="vim"

# For VirtualEnvWrapper
export virtualenvwrapper_python=/Users/xbili/.pyenv/shims/python
export virtualenvwrapper_virtualenv=/Users/xbili/.pyenv/versions/3.5.1/lib/python3.5/site-packages
export PYENV_VIRTUALENVWRAPPER_PREFER_PYENV="true"

# For Node VM
export NVM_DIR="/Users/xbili/.nvm"


# ---------------- Look & Feel ---------------- #
if [ -e /usr/share/terminfo/x/xterm-256color ]; then
    export TERM='xterm-256color'
else
    export TERM='xterm-color'
fi

# Git branch in prompt
parse_git_branch() {

  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'

}

# Command line colors
export PS1="\[\e[1;32m\]\u@\h \W\]\[\e[1;33m\]\$(parse_git_branch)\[\e[0;34m\] [\$(date +%k:%M:%S)]⚡️ \n🗿 \[\e[0m\] "
export CLICOLOR=1
export LSCOLORS=gxBxhxDxfxhxhxhxhxcxcx

if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi




# ---------------- Run Processes -------------- #
# For pyenv-virtualenvwrapper
eval "$(pyenv init -)"

# added by travis gem
[ -f /Users/xbili/.travis/travis.sh ] && source /Users/xbili/.travis/travis.sh

# NVM
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

# RVM
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

# For phpbrew
source /Users/xbili/.phpbrew/bashrc

# For pyenv-virtualenvwrapper
pyenv virtualenvwrapper

