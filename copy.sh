#/bin/bash

mkdir -p users
docker cp openvpn:/etc/openvpn/demoCA/cacert.pem users/cacert.pem
docker cp openvpn:/etc/openvpn/demoCA/private/cakey.pem users/cakey.pem
docker cp openvpn:/etc/openvpn/server/ta.key users/ta.key