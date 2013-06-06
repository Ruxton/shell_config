#ENV sh

SHELL_CONFIG_IS_OSX=false

## Manage calls to True Crypt
unamestr=`uname`
if [[ "$unamestr" == 'Darwin' ]]; then
  SHELL_CONFIG_IS_OSX = true
fi

if SHELL_CONFIG_IS_OSX; then
  truecrypt='/Applications/TrueCrypt.app/Contents/MacOS/Truecrypt --text'
else
  truecrypt='truecrypt'
fi

## Shell Config variables
SHELL_CONFIG_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SHELL_CONFIG_HOMEDIR_LINKS=".profile.d .rspec .massource .hgignore_global .gitignore_global .gitconfig .gemrc .bashrc .bash_profile"
SHELL_CONFIG_SUBLIME_PREFS="Preferences.sublime-settings"
if [[ "$unamestr" == 'Darwin' ]]; then
  SHELL_CONFIG_SUBLIME_DIR="$HOME/Library/Application Support/Sublime Text 2/Packages/User"
else
  SHELL_CONFIG_SUBLIME_DIR="$HOME/Library/Application Support/Sublime Text 2/Packages/User"
fi
SHELL_CONFIG_PRIVATE_TCVOLUME="$HOME/DropBox/shell_config.private"


function shell_config_usage() {
  cat <<-EOF
$(tput bold)usage:$(tput sgr0) ./install.sh [action]

install:      Installs and links configuration files (default action)
mountprivate: Mounts the private directory, useful after you've rebooted
uninstall:    Uninstalls and removes the configuration files
usage:        Display this message
EOF
  return 0
}

function shell_config_install() {
  local CONFIG_FILES DIR
  echo "$(tput bold)Installing Shell Config$(tput sgr0)"
  shell_config_link_homedir $SHELL_CONFIG_DIR
  shell_config_link_sublime_prefs $SHELL_CONFIG_DIR
  shell_config_install_private
  source $HOME/.massource
  echo "$(tput setaf 2)Success.$(tput sgr0)"
}

function shell_config_uninstall() {
  local CONFIG_FILES DIR
  echo "$(tput bold)Uninstalling Shell Config$(tput sgr0)"
  DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  shell_config_unlink_homedir
  shell_config_unlink_sublime_prefs
  shell_config_uninstall_private
  echo "$(tput setaf 2)Success.$(tput sgr0)"
}

function shell_config_install_private() {
	SHELL_CONFIG_PRIVATE_DIR="$SHELL_CONFIG_DIR/private"
  if [[ $SHELL_CONFIG_PRIVATE_TCVOLUME != "" ]]; then
  	SHELL_CONFIG_PRIVATE_FILE=`basename $SHELL_CONFIG_PRIVATE_TCVOLUME`

    if [[ ! -d "${SHELL_CONFIG_PRIVATE_DIR}" ]]; then
    	if [[ ! -f "${SHELL_CONFIG_DIR}/${SHELL_CONFIG_PRIVATE_FILE}" || ! -h "${SHELL_CONFIG_PRIVATE_FILE}" ]]; then
    		echo "Private volume does not exist, linking it.."
	      shell_config_link $SHELL_CONFIG_PRIVATE_TCVOLUME $SHELL_CONFIG_DIR/$SHELL_CONFIG_PRIVATE_FILE
    	fi
      shell_config_mount_private
    fi

    if [[ -f "${SHELL_CONFIG_DIR}/private/install.shell_config" ]]; then
	    source $SHELL_CONFIG_DIR/private/install.shell_config
	    shell_config_private_install
  	fi
  fi
}

function shell_config_uninstall_private() {
  if [[ $SHELL_CONFIG_PRIVATE_TCVOLUME != "" ]]; then
    if [[ -d "${SHELL_CONFIG_DIR}/private" ]]; then
    	SHELL_CONFIG_PRIVATE_FILE=`basename $SHELL_CONFIG_PRIVATE_TCVOLUME`
      source $SHELL_CONFIG_DIR/private/install.shell_config
      shell_config_private_uninstall
      echo "Unmounting private dir from True Crypt"
      $truecrypt -d $SHELL_CONFIG_DIR/private
     	shell_config_unlink $SHELL_CONFIG_DIR/$SHELL_CONFIG_PRIVATE_FILE
    fi
  fi
}

function shell_config_mount_private() {
  echo "Mounting private dir from True Crypt"
  $truecrypt $SHELL_CONFIG_DIR/$SHELL_CONFIG_PRIVATE_FILE $SHELL_CONFIG_PRIVATE_DIR
}

function shell_config_link_homedir() {
  local file DIR from to
  echo "$(tput bold)Linking home directory...$(tput sgr0)"
  DIR=$1
  for file in $SHELL_CONFIG_HOMEDIR_LINKS; do
    from=$DIR/$file
    to=$HOME/$file
    shell_config_link "$from" "$to"
  done
}

function shell_config_unlink_homedir() {
	echo "$(tput bold)Unlinking home directory...$(tput sgr0)"
  for file in $SHELL_CONFIG_HOMEDIR_LINKS; do
    link=$HOME/$file
    shell_config_unlink "$link"
  done
}

function shell_config_link_sublime_prefs() {
	echo "$(tput bold)Linking sublime prefs...$(tput sgr0)"
  local SUBLIME_PREFS DIR SUBLIME_DIR from to
  DIR=$1
  for file in $SHELL_CONFIG_SUBLIME_PREFS; do
    from=$DIR/subl/$file
    to=$SHELL_CONFIG_SUBLIME_DIR/$file
    shell_config_link "$from" "$to"
  done
}

function shell_config_unlink_sublime_prefs() {
	echo "$(tput bold)Unlinking sublime prefs...$(tput sgr0)"
  for file in $SHELL_CONFIG_SUBLIME_PREFS; do
    link=$SHELL_CONFIG_SUBLIME_DIR/$file
    shell_config_unlink "$link"
  done
}

function shell_config_unlink() {
  link=$1
  if [[ -h "$1" ]]; then
    rm "$1"
  fi
}

function shell_config_link() {
  from=$1
  to=$2
  if [[ -h $to ]]; then
    echo "$(tput setaf 1)Link $to already exists$(tput sgr0)"
    return 0
  elif [[ -f $to ]]; then
    echo "$(tput setaf 1)File already exists at $to, cannot link.$(tput sgr0)"
    return 0
  elif [[ -d $to ]]; then
    echo "$(tput setaf 1)Directory already exist at $to, cannot link.$(tput sgr0)"
    return 0
  fi

  if [[ -d $from ]] || [[ -f $from ]]; then
  	echo "$(tput setaf 2)Linking ${from} ${to}$(tput sgr0)"
    ln -s "$from" "$to"
  fi
}

if [ $# -lt 1 ]; then
  shell_config_install
  exit 1;
fi

case "$1" in
  install)                  shell_config_install;;
  uninstall)                shell_config_uninstall;;
  usage|help|--help|-h|/?)  shell_config_usage;;
  mountprivate)             shell_config_mount_private;;
esac