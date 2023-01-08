#/bin/bash

export client=anzor

users=users
configs=configs
mkdir -p users
add () {
  # Generates the custom client.ovpn
  mkdir -p $users/$client
  openssl genrsa -out $users/$client/$client.key 4096
  openssl req -new -nodes -key $users/$client/$client.key -out $users/$client/$client.csr -subj "/CN=$client"
  openssl x509 -req -days 365 -CA $users/cacert.pem -CAkey $users/cakey.pem -in $users/$client/$client.csr -out $users/$client/$client.crt
  {
  cat $configs/client-common.txt
  echo "<ca>"
  cat $users/cacert.pem
  echo "</ca>"
  echo "<cert>"
  sed -ne '/BEGIN CERTIFICATE/,$ p' $users/$client/"$client".crt
  echo "</cert>"
  echo "<key>"
  cat $users/$client/"$client".key
  echo "</key>"
  echo "<tls-crypt>"
  sed -ne '/BEGIN OpenVPN Static key/,$ p' $users/ta.key
  echo "</tls-crypt>"
  } > $users/$client/"$client".ovpn
}

add