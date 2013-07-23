##################################################
#
#Helpful git aliases and functions
#by Greg Tangey
#
##################################################

# gadd: alias for 'git add'
alias gadd="git add"

# gbranch: alias for 'git branch'
alias gbranch="git branch"

# gcom: alias for 'git commit'
alias gcom="git commit"

# gdevelop: alias for 'git checkout develop'
alias gdevelop="git checkout develop"

# gmaster: alias for 'git checkout master'
alias gmaster="git checkout master"

# gpush: alias for 'git push'
alias gpush="git push"

# greset: hard reset git repo to HEAD
alias greset="git reset --hard HEAD^ ;"

# gsignoff: alias for 'git signoff' (used for signing off commits by the person checking)
alias gsignonff="get signoff"

# gstat: alias for 'git status'
alias gstat="git status"

# gtwf: Git WTF is a repo/remote status tool
alias gwtf="git wtf"

# gsl: A list of who contributed how much to a git repo
alias gsl="git shortlog -nsw -e"

# gprefixes: Count occurence of all prefixes
gprefixes() {
  git slg | grep -o '^\[[A-Z]*\]'| awk '{count[$1]++}END{for(j in count) print j,"("count[j]")"}'
}


# gupstream: set upstream of current branch to origin/<branch_name>
gupstream() {
  local current_branch=`git branch 2>/dev/null | grep "*" | awk '{ print $2 }'`

  git branch --set-upstream $current_branch origin/$current_branch
}

# gremote: set a local branch to be tracked against remote origin
gremote() {
  current_branch=`git branch | grep "*" | awk '{ print $2 }'`
  git branch --track $1 origin/$1
  git pull
}

# gpushremote: push current local branch to origin
gpushremote() {
  current_branch=`git branch | grep "*" | awk '{ print $2 }'`
  git push origin $current_branch
}

# gpushsmeg: push current local branch to smeghead
gpushsmeg() {
  current_branch=`git branch | grep "*" | awk '{ print $2 }'`
  git push smeghead $current_branch
}

# gbranchd: delete a branch
gbranchd() {
  echo
  echo "Branch Deleting"
  echo

  __gbranch_selector "Please choose a branch to DELETE"

  if [[ "$selected_branch" != "" ]]; then
    read -ep "Are you sure you want to DELETE $selected_branch branch (y/n):" -n 1
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
      echo
      echo "Locally deleting ${selected_branch}.."
      if [ "$1" == "-f" ]; then
        git branch -D ${selected_branch}
      else
        git branch -d ${selected_branch}
      fi
      git push origin :${selected_branch}
    else
      return 0
    fi
  else
    echo "No branches to delete, exiting."
    return 0
  fi
}

# gbranchdq: clean up all quick-created branches that are not activated
gbranchdq() {
  local branches branch

  branches=`git branch | grep quick|grep -v "*"`

  for branch in $branches
  do
    git branch -d $branch
  done
}

# gbranchq: used for creating branches quickly
gbranchq() {
  local count var

  count=`git branch|grep -c quick`

  if [ $count -eq 0 ]; then
    default="quick"
  else
    let "count += 1"
    default="quick$count"
  fi

  name="";
  if [ "$1" != "" ]; then
    default=$1
  else
    read -ep "Topic Name (default $default): " -t 30 name;
  fi

  if [ "$name" == "" ]; then
    name=${default}
  fi

  echo "Creating branch $name..."
  git checkout -b $name
}

# gbranchsw: switches to a branch
gbranchsw() {
  echo
  echo "Branch Switching"
  echo

  __gbranch_selector "Please choose a branch to switch to"
  if [[ "$selected_branch" != "" ]]; then
    echo "Switching to $selected_branch"

    git checkout ${selected_branch}
  else
    echo "No branches to switch to, exiting."
    return 0
  fi
}

# gbsw: switches to a branch
alias gbsw="gbranchsw"

# gmerge: merge a branch with current branch (uses gbranch_selector)
gmerge() {
  echo
  echo "Branch Merging"
  echo

  __gbranch_selector "Please enter the number of the branch you want to merge"

  if [[ "$selected_branch" != "" ]]; then
    read -ep "Are you sure you want to merge $selected_branch into $current_branch (y/n):" -n 1
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
      echo
      echo "Merging $selected_branch into $current_branch..."

      git merge ${selected_branch}
    else
      return 0
    fi
  else
    echo "No branches to merge, exiting"
    return 0
  fi
}

# __gbranch_selector: uses __selector to do git branch selection
__gbranch_selector() {

  if [ "$1" == "" ]
  then
    local prompt="Please enter a branch to select"
  else
    local prompt=$1
  fi

  local current_branch=`git branch 2>/dev/null | grep "*" | awk '{ print $2 }'`
  local branch_list=`git branch 2>/dev/null | grep -v "*"`

  __selector "${prompt}" "selected_branch" "${current_branch}" "${branch_list}"

}

# gpushbanana: Push to bananajour repo
gpushbanana() {
  current_branch=`git branch | grep "*" | awk '{ print $2 }'`
  git push banana $current_branch
}

# banajourd: Start bananjour in the background
bananajourd() {
  local check=`screen -list|grep bananajour|awk '{print $1}'`
  local hostname=`git config --global --list|grep bananajour.hostname|cut -d"=" -f 2`

  if [[ $hostname = "" ]]; then
    hostname='localhost'
  fi

  if [[ "$1" = "" ]]; then
    if [[ "${check}" = "" ]]; then
      screen -dmS bananajour bananajour
      echo "Started bananajour in background"
    else
      echo "Bananajour is running in background..."
      read -ep "re-attach or run(r)? (y/n/r)" choice
      if [[ $choice = [yY] ]]; then
        echo "Attaching bananajour session..."
        screen -r $check
      elif [[ $choice = [rR] ]]; then
        open "http://${hostname}:9331"
      else
        echo "Bananajour currently running at ${check}"
      fi
    fi
  else
    if [[ $1 -eq "load" ]]; then
      screen -r bananajour
    fi
  fi
}

# gourcemake: Make a gource video in the current directory, convert to x264
gource_make() {
  gource_options=$*
  gravatars
  gource -s 0.5 -1280x720 --user-image-dir .git/avatar/ $gource_options -o - | ffmpeg -y -r 60 -f image2pipe -vcodec ppm -i - -vcodec libx264 -preset slow -pix_fmt yuv420p -crf 15 -strict 2 -bf 0 gource.mp4
}