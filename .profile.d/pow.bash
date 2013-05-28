# kapow: a master function for running POW related actions
function kapow() {
  if [ $# -lt 1 ]; then
  	cat <<-EOF
$(tput bold)usage:$(tput sgr0) kapow action [args]

install:   Installs POW to the system
link/ln:   Link current directory or arg1 into POW, arg2 is an optional link name
list/ls:   List all the aplications currently installed into POW
logs:      Tail the POW server logs
restart:   Restart the POW server (start/stop)
start:     Starts the POW server
stop:      Stops the POW server
uninstall: Removes POW from the sytem
	EOF
    return 0
  fi
  case "$1" in
    install)    kapow_install;;
    link|ln)    kapow_link $2 $3;;
    list|ls)    kapow_list;;
    logs)       kapow_logs;;
    restart)    kapow_restart;;
    start)      kapow_start;;
    stop)       kapow_stop;;
    uninstall)  kapow_uninstall;;
  esac  
}

# kapow_link: link current directory or arg1 into POW, arg2 is link name
function kapow_link() {
	local from to directory_name
	from=$1
	to=$2

	[[ -z ${from} ]] && { from=`pwd`; }
	[[ -z ${to} ]] && { directory_name=`basename ${from} | tr '[:upper:]' '[:lower:]'`; to="$HOME/.pow/${directory_name}"; }

	echo "Adding ${directory_name} to POW.."
	# echo $to
	ln -s ${from} ${to}
	echo "done."
}

# kapow_install: install the POW server onto your system
function kapow_install() {
  read -ep "$(tput bold)Are you sure you wish to install POW onto your system? (y/n)$(tput sgr0):" -n 1
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "OK, uninstalling..."
    curl get.pow.cx | sh
    echo "done."
  else
    echo "Exiting."
    return 0
  fi    
}

# kapow_list: list all the aplications currently installed into POW
function kapow_list() {
	pow_sites=`ls $HOME/.pow|awk '{print $1}'`

	echo -e "$(tput bold)The following POW applications are installed:\n$(tput sgr0)"
	for site in $pow_sites; do
		local actual_path output
    actual_path="$HOME/.pow/$site"
    output=""

    if [[ -h $actual_path ]]; then
      output=`readlink ${actual_path}`
    elif [[ -f $actual_path ]]; then
      output=`cat ${actual_path}`
      output="0.0.0.0:${output}"
    fi
		echo "  $(tput setaf 6)${site}$(tput sgr0) -> $(tput setaf 3)${output}$(tput sgr0)"
	done
}

# kapow_logs: tail the POW server logs
function kapow_logs() {
  tail -f $HOME/Library/Logs/Pow/access.log
}

function kapow_restart() {
  kapow_start
  kapow_stop
}

# kapow_start: Start the POW server
function kapow_start() {
  echo "$(tput bold)Starting the POW server...$(tput sgr0)"
  sudo launchctl load -Fw /Library/LaunchDaemons/cx.pow.firewall.plist 2>/dev/null
  launchctl load -Fw "$HOME/Library/LaunchAgents/cx.pow.powd.plist" 2>/dev/null
  echo "Done."
}

# kapow_stop: Stop the POW server
function kapow_stop() {
  echo "$(tput bold)Stopping the POW server...$(tput sgr0)"   
  launchctl unload "$HOME/Library/LaunchAgents/cx.pow.powd.plist" 2>/dev/null
  sudo launchctl unload "/Library/LaunchDaemons/cx.pow.firewall.plist" 2>/dev/null
  echo "Done."
}

function kapow_uninstall() {
  read -ep "$(tput bold)Uninstalling POW from your system, are you sure? (y/n)$(tput sgr0):" -n 1
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "OK, uninstalling..."
    curl get.pow.cx/uninstall.sh | sh
    echo "done."
  else
    echo "Exiting."
    return 0
  fi
}