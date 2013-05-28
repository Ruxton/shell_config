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