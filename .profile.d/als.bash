# als: locate aliases/functions stored in ~/.profile.d
function als() {
  local func ali

  func="^$1.*()*$"
  func2="^function $1.*()*$"
  ali="^alias $1.*=*$"

  grep -hE -B 1 "$func|$ali|$func2" ~/.profile.d/*.bash | grep "^# $1.*:*$"
}


function _als_bash_completer() {  local current list
  local cmd="${1##*/}"
  COMPREPLY=()
  local current="${COMP_WORDS[COMP_CWORD]}"
  local func="^$1.*()*$"
  local ali="^alias $1.*=*$"
    
  if [[ ( ${COMP_CWORD} -eq 1 ) && ${COMP_WORDS[0]} == "$cmd" ]]; then
    list=$(grep -hE -B 1 "^.*()*$|^alias .*=*$" ~/.profile.d/*.bash | grep "^# " | awk '{out=substr($2,0,length($2)-1)} { print out }' )
    COMPREPLY=( $(compgen -W "$list" -- "${current}") )
  fi
}

complete -F _als_bash_completer als
