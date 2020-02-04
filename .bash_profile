##
# Colours
##

export CLICOLOR=1
export LSCOLORS=DxGxcxdxCxegedabagacad

##
# Massresource
##

source ~/.massource

##
# Paths
##

PATH=$PATH:~/bin:/phonegap/lib:/usr/local/sbin:/usr/local/share/npm/bin:/usr/local/Cellar/go/1.5.1/libexec/bin
export PATH

# M2_HOME=/usr/share/maven
# export M2_HOME

ANDROID_HOME=/usr/local/Cellar/android-sdk/24.4.1_1
export ANDROID_HOME

GOPATH=~/AppsByGreg/go
export GOPATH

##
# History
##

# Show the time you entered the command in history log
export HISTTIMEFORMAT='%Y-%b-%d %a %H:%M:%S - '

# Change the file location because certain bash sessions truncate .bash_history file upon close.
# http://superuser.com/questions/575479/bash-history-truncated-to-500-lines-on-each-login
export HISTFILE=~/.bash_eternal_history

# Undocumented feature which sets the size to "unlimited".
# http://stackoverflow.com/questions/9457233/unlimited-bash-history
export HISTFILESIZE=
export HISTSIZE=

# Commit history after every command
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

# Set prompt
GITPS1="\$(__git_ps1 \"(%s)\")"
PS1="${txtbold}${txtgrn}${GITPS1}${txtrst}\n[\t][\u@\h:\W] \$ "
PS2="more=> ";
export PS1
export PS2

##
# Editors
##
BUNDLER_EDITOR=atom
export BUNDLER_EDITOR

###
# Completion
##

if [ -f /usr/local/etc/bash_completion ]; then
  . /usr/local/etc/bash_completion
fi

export PATH="/usr/local/opt/openssl/bin:$PATH"

##
# RVM
##
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
