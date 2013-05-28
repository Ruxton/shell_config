export CLICOLOR=1
export LSCOLORS=DxGxcxdxCxegedabagacad

source ~/.massource

PATH=$PATH:~/bin:/phonegap/lib:/usr/local/sbin
export PATH

M2_HOME=/usr/share/maven
export M2_HOME

ANDROID_HOME=/usr/local/Cellar/android-sdk/r21.1
export ANDROID_HOME

# Show the time you entered the command in history log
export HISTTIMEFORMAT='%Y-%b-%d %a %H:%M:%S - '

# Set prompt
GITPS1="\$(__git_ps1 \"(%s)\")"
PS1="${txtbold}${txtgrn}${GITPS1}${txtrst}\n[\t][\u@\h:\W] \$ "
PS2="more=> ";

export PS1
export PS2
BUNDLER_EDITOR=subl
export BUNDLER_EDITOR

if [ -f /usr/local/etc/bash_completion ]; then
  . /usr/local/etc/bash_completion
fi

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
