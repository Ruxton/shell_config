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

# tunneller: tunneller to_array local_ports via_host optional_socket
function tunneller() {
  targets=$1
  local_ports=$2
  via_host=$3
  ctl_socket=$4

  if [[ "${ctl_socket}" == "" ]]; then
    ctl_socket="~/.tunneller/tunneller"
  else
    ctl_socket="~/.tunneller/${ctl_socket}"
  fi

  pid=`ssh -S ${ctl_socket} -O check $via_host 2>&1|grep "pid="|awk '{print $3}'| sed -e 's/(pid=//' | sed -e 's/)//'`

  if [[ "$pid" != "" ]]; then
    echo "Tunnels for ${via_host} already connnected."
    read -ep "Do you want to disconnect it and reconnect? (y/n) " choice
    if [[ $choice = [yY] ]]; then
      echo "Disconnecting.."
      ssh -S $ctl_socket -O exit $via_host
      return 0
    else
      echo "Exiting.."
      return 1
    fi
  fi

  # Check that target and local mappings match
  if [[ ${#targets[@]} != ${#locals[@]} ]]; then
    echo "Error - target bidnings do not match local bindings"
    index=0
    echo "Summary: "
    while [[ $index -lt ${#targets[@]} ]]; do
      echo "BIND: ${targets[$index]:="Missing"}, TO: ${locals[$index]:="Missing"}"
      (( index++ ))
    done
    return 1
  fi

  tunnels=""
  index=0
  while [[ $index -lt ${#targets[@]} ]]; do
    tunnels="${tunnels} -L ${locals[$index]}:${targets[$index]}"
    (( index++ ))
  done
  echo "SSH Tunneling to services via ${via_host}.."
  echo $tunnels
  echo "Control Socket: ${ctl_socket}"

  ssh -nMNfS $ctl_socket \
  $tunnels \
  $via_host
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
