# truecrypt: TrueCrypt command line
alias truecrypt='/Applications/TrueCrypt.app/Contents/MacOS/Truecrypt --text'

# screen: realias screen to use bash
alias screen="screen -s -/bin/bash"

# h: Show bash history
alias h="history | more"

# dirs: Show only directories in the current directory
alias dirs="ls -al | grep '^d'"

# dirscount: Number of directories in current directory
alias dirscount="ls -al|grep ^d|wc -l"

# lm: List (ls -al) contents of current directory and page with more
alias lm="ls -al | more"

# lc: List contents of current directory, force multi-column output
alias lc="ls -C"

# nu: Show the number of online users
alias nu="who|wc -l"

# np: Show the number of active processes
alias np="ps -ef|wc -l"

# p: Show all the active processes
alias p="ps -ef"

# cd..: Two directory levels above the current dir
alias cd..="cd ../.."

# cd...: Three directory levels above the current dir
alias cd...="cd ../../.."

# cpbak: quickly copy/backup a directory
cpbak() {
  local dirname basename

  dirname=`abspath $1`
  basename=`basename $dirname`

  cp -R $dirname ${dirname}BACK
}

# bak: Backup a file "bak filename.txt"
bak() {
  cp $1 ${1}--`date +%Y%m%d%H%M`.backup
}

# abspath: absolute path of a directory
function abspath() {
  return=`cd ${1%/*} 2>/dev/null; echo "$PWD"`
  echo $return
}

# user_confirm: Confirm with a string in $1
function user_confirm() {
  local REPLY msg
  msg=$1
  read -ep "$msg (y/n):" -n 1
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    return 0
  else
    return 1
  fi
}

# read_with_defaults: $1=prompt $2=default $3=variable to set
function read_with_defaults() {
  local return_var
  prompt=$1
  default=$2

  read -e -p "$prompt [$default]: " return_var
  return_var=${return_var:-$default}
  eval $3=\$return_var
}

brewcompletion_path="/usr/local/etc/bash_completion.d/"

function brewcompletion() {
  ln -s "$HOME/.bash_completion.d/$1" "/usr/local/etc/bash_completion.d/$1"
}
complete -F _bash_complete_alllister brewcompletion

#
#Usage
#
#$ __selector "Select a volume" "selected_volume" "" "`ls -la /Volumes/`"
#$ cd $selected_volume
#
# __selector: good for selecting stuff
function __selector() {
  local selections selPrompt selCurrent selListCommand selSize choose

  selPrompt=$1
  selReturn=$2
  selCurrent=$3
  selList=$4

  prompt=$selPrompt

  let count=0

  for sel in $selList; do
    let count++
    selections[$count-1]=$sel
  done
  if [[ $count > 0 ]]; then
    choose=0
    selSize=${#selections[@]}

    while [ $choose -eq 0 ]; do
      let count=0

      for sel in $selList; do
        let count++
        echo "$count) $sel"
      done

      echo

      read -ep "${prompt}, followed by [ENTER]:" choose

      if [[ $choose != ${choose//[^0-9]/} ]] || [ ! $choose -le $selSize ]
      then
        echo
        echo "Please choose one of the listed numbers."
        echo
        let choose=0
      fi

    done

    let choose--

    export ${selReturn}=${selections[$choose]}
  else
    return 0
  fi
}

osx_real_path () {
  OIFS=$IFS
  IFS='/'
  for I in $1
  do
    # Resolve relative path punctuation.
    if [ "$I" = "." ] || [ -z "$I" ]
      then continue
    elif [ "$I" = ".." ]
      then FOO="${FOO%%/${FOO##*/}}"
           continue
      else FOO="${FOO}/${I}"
    fi

    # Dereference symbolic links.
    if [ -h "$FOO" ] && [ -x "/bin/ls" ]
      then IFS=$OIFS
           set `/bin/ls -l "$FOO"`
           while shift ;
           do
             if [ "$1" = "->" ]
               then FOO=$2
                    shift $#
                    break
             fi
           done
    fi
  done
  IFS=$OIFS
  echo "$FOO"
}

# __screend: screen daemonizing
__screend() {
  local name="${1}"
  local check=`screen -list|grep ${name}|awk '{print $1}'`

  if [[ "$2" = "" ]]; then
    if [[ "${check}" = "" ]]; then
      echo "Starting ${name}..."
      screen -dmS ${name} bash -c '${name}'
      local runCheck=`screen -list|grep ${name}|awk '{print $1}'`
      if [[ "${runCheck}" = "" ]]; then
        echo "Unable to start ${name} in background"
      else
        echo "Started ${name} in background"
      fi
    else
      echo "${name} is running in background..."
      read -ep "re-attach? (y/n)" choice
      if [[ $choice = [yY] ]]; then
        echo "Attaching ${name} session..."
        screen -r ${check}
      else
        echo "${name} currently running at ${check}"
      fi
    fi
  else
    if [[ $2 -eq "load" ]]; then
      screen -r ${name}
    fi
  fi
}