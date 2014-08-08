# tunnel: SSH Tunnel bound to local ip, used for remote desktop hopping through linux gateways, eg. tunnel localport remotehost:port remotehost
function tunnel {
  ssh -f -N -L $1:$2 ${*:3};
}

# header: get the header of the given url
alias header="curl -I"

# cors: cors check
function cors() {
  curl -I -H 'Origin: $1'
}

# digall: dig DNS for all records
function digall() {
  dig +nocmd $1 any +multiline +noall +answer
}

# scpresume: rsync over ssh with resume
alias scpresume="rsync --partial --progress --rsh=ssh"

# authme: Copy public key to remote host SSH
function authme {
  ssh $1 'if [[ ! -d ~/.ssh ]]; then mkdir -p ~/.ssh/; fi; cat >>.ssh/authorized_keys; chmod 600 ~/.ssh/authorized_keys' < ~/.ssh/id_rsa.pub
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

# ssl_csr_gen: Generate SSL Certificate CSR
function ssl_genkey() {
  openssl genrsa 2048 > $1.key
}

function ssl_sni_check() {
  H=$1
  non_sni=`echo '' | openssl s_client -showcerts -connect $H:443 </dev/null | sed -n -e '/BEGIN\ CERTIFICATE/,/END\ CERTIFICATE/ p'`
  with_sni=`echo '' | openssl s_client -showcerts -connect $H:443 -servername $H </dev/null | sed -n -e '/BEGIN\ CERTIFICATE/,/END\ CERTIFICATE/ p'`

  if [[ "$non_sni" == "$with_sni" ]]; then
    echo "Does not use SNI"
    return 1
  else
    echo "Server uses SNI"
    return 0
  fi
}
