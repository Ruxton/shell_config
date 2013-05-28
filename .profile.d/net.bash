# tunnel: SSH Tunnel bound to local ip, used for remote desktop hopping through linux gateways, eg. tunnel localport remotehost:port remotehost
function tunnel {
  ssh -L $1:$2 $@ ;
}

# header: get the header of the given url
alias header="curl -I"

# cors: cors check
function cors() {
  curl -I -H 'Origin: $1'
}

# scpresume: rsync over ssh with resume
alias scpresume="rsync --partial --progress --rsh=ssh"

# authme: Copy public key to remote host SSH
function authme {
  ssh $1 'cat >>.ssh/authorized_keys2' < ~/.ssh/id_rsa.pub
}

# privme: Copy private key to remote host SSH
function privme {
  ssh $1 'cat >>.ssh/id_rsa' < ~/.ssh/id_rsa
}

# remknownhost: Remove a known hosts from ssh
function remknownhost {
  H=$1
  [[ -z ${H} ]] && { echo "Need a host as argument"; return 1 ;}
  LINE=`ssh -o StrictHostKeyChecking=yes $1 'exit' 2>&1 | sed -n '/Offending key/ { s/.*://;s/r//;p }'`
  [[ -z ${LINE} ]] && { echo "Nothing to clean"; return 0; }
  sed -i -n "$LINE!p" ~/.ssh/known_hosts
}