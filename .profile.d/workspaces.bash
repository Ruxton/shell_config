renv_path="/Users/ruxton/AppsByGreg/ror/"
wrenv_path="/Users/ruxton/Work/ror/"
penv_path="/Users/ruxton/AppsByGreg/php/"
wpenv_path="/Users/ruxton/Work/php/"
waenv_path="/Users/ruxton/Work/android/"
aenv_path="/Users/ruxton/AppsByGreg/android/"
menv_path="/Users/ruxton/AppsByGreg/mobile/"
xenv_path="/Users/ruxton/AppsByGreg/xbmc/"
senv_path="/Users/ruxton/AppsByGreg/shell/"
goenv_path="/Users/ruxton/AppsByGreg/go/src/"

# wrenv: Change directory into work ruby environment
function wrenv() { cd $wrenv_path$@ ;}
# wpenv: Change directory into work PHP environment
function wpenv() { cd $wpenv_path$@ ;}
# waenv: Change directory to Android environment
function waenv() { cd $waenv_path$@ ;}
# renv: Change directory to personal ruby environment
function renv() { cd $renv_path$@ ;}
# penv: Change directory to personal PHP environment
function penv() { cd $penv_path$@ ;}
# aenv: Change directory to Android environment
function aenv() { cd $aenv_path$@ ;}
# menv: Change directory to Mobile environment
function menv() { cd $menv_path$@ ;}
# xenv: Change directory to XBMC dev environment
function xenv() { cd $xenv_path$@ ;}
# xenv: Change directory to SHELL dev environment
function senv() { cd $senv_path$@ ;}
# goenv: Change directory to personal GoLang dev environment
function goenv() { cd $goenv_path$@ ;}

# drop: Copy $1 to share through /Users/ruxton/Sites/drop/
drop() {
  local hostname=`hostname`
  local dropdir='/Users/ruxton/Sites/drop/'

  if [[ "$1" == "" ]]; then
    echo
    echo 'Drop local HTTP Sharing'
    echo
    echo 'Usage:  drop <file>'
    echo '        drop --list'
    echo '        drop --rm <file>'
    echo
  elif [[ "$1" == "--list" ]]; then
    ls $dropdir
  elif [[ "$1" == "--rm" ]]; then
    if [[ -d $dropdir$2 || -f $dropdir$2 ]]; then
      echo "Removing $2 from drop.."
      rm -rf $dropdir$2
    else
      echo "File or directory does not exist"
    fi
  elif [[ "$1" == "--geturl" ]]; then
    if [[ -d $dropdir$2 || -f $dropdir$2 ]]; then
      echo "http://$hostname/$2" | pbcopy
    else
      echo "File or directory does not exist"
    fi
  else
    if [[ -d $dropdir$1 || -f $dropdir$1 ]]; then
      cp -R "$1" $dropdir
      echo "Added file to http dropbox"
      echo "http://$hostname/$1" | pbcopy
      echo "URL in clipboard! - http://$hostname/$1"
    else
      echo "File or directory does not exist"
    fi
  fi
}

# cleardrop: Clear HTTP Dropbox
cleardrop() {
  rm -rf /Users/ruxton/Sites/drop/public/*
  echo "HTTP dropbox cleared.."
}

function _bash_complete_alllister() {
  local current dir_list dir
  local cmd="${1##*/}"
  temp=${cmd}_path
  dir=${!temp}
  COMPREPLY=()
  current="${COMP_WORDS[COMP_CWORD]}"
  if [[ ( ${COMP_CWORD} -eq 1 ) && ${COMP_WORDS[0]} == "$cmd" ]]; then
    dir_list=$(ls -l "$dir"|awk '{ print $9 }')
    COMPREPLY=( $(compgen -W "$dir_list" -- "${current}") )
  fi
}

function _bash_complete_dirlister() {
  local current dir_list dir
  local cmd="${1##*/}"
  temp=${cmd}_path
  dir=${!temp}
  COMPREPLY=()
  current="${COMP_WORDS[COMP_CWORD]}"
  if [[ ( ${COMP_CWORD} -eq 1 ) && ${COMP_WORDS[0]} == "$cmd" ]]; then
    dir_list=$(ls -l "$dir"|grep '^d'|awk '{ print $9 }')
    COMPREPLY=( $(compgen -W "$dir_list" -- "${current}") )
  fi
}

complete -F _bash_complete_dirlister wrenv renv aenv penv wpenv menv xenv waenv senv goenv
