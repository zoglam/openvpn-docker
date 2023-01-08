FROM golang:1.18-alpine3.17 as script-auth
WORKDIR /opt/build
COPY main.go .
RUN go build -ldflags "-s -w" -o script-auth main.go

FROM ubuntu:22.10

RUN \
  apt update -y && \
  apt install openssl openvpn iptables -y && \
  groupadd --gid 8888 openvpn && \
  useradd --uid 8888 --gid openvpn openvpn && \
  rm -rf /var/cache/apt/archives /var/lib/apt/lists/*

WORKDIR /etc/openvpn

ENV OPENVPN_ROOT=/etc/openvpn
ENV DOMAIN=zoglam.me

COPY ./configs/openssl.cnf .

RUN \
  mkdir -p $OPENVPN_ROOT/server && \
  mkdir -p $OPENVPN_ROOT/demoCA/private && \
  mkdir -p $OPENVPN_ROOT/client/private && \
  mkdir -p $OPENVPN_ROOT/ccd && \
  touch $OPENVPN_ROOT/demoCA/index.txt && \
  touch /var/log/openvpn.log && \
  # CERTS
  openssl genrsa -out $OPENVPN_ROOT/demoCA/private/cakey.pem 4096 && \
  openssl req -new -x509 -days 365 -key $OPENVPN_ROOT/demoCA/private/cakey.pem -out $OPENVPN_ROOT/demoCA/cacert.pem -subj "/CN=${DOMAIN}" && \
  openssl genrsa -out $OPENVPN_ROOT/demoCA/private/server.key 4096 && \
  openssl req -new -key $OPENVPN_ROOT/demoCA/private/server.key -out $OPENVPN_ROOT/demoCA/server.csr -addext "subjectAltName = DNS:vpn.${DOMAIN}" -subj "/CN=vpn.${DOMAIN}" && \
  openssl x509 -req -days 365 -CA $OPENVPN_ROOT/demoCA/cacert.pem -CAkey $OPENVPN_ROOT/demoCA/private/cakey.pem -in $OPENVPN_ROOT/demoCA/server.csr -out $OPENVPN_ROOT/demoCA/server.crt && \
  openssl rand -hex -out $OPENVPN_ROOT/demoCA/crlnumber 10 && \
  openssl ca -config $OPENVPN_ROOT/openssl.cnf -gencrl -out $OPENVPN_ROOT/demoCA/crl.pem && \
  openssl dhparam -out $OPENVPN_ROOT/demoCA/dh.pem 2048 && \
  openvpn --genkey secret $OPENVPN_ROOT/server/ta.key && \
  # LINKS
  ln -s $OPENVPN_ROOT/demoCA/cacert.pem $OPENVPN_ROOT/server/cacert.pem && \
  ln -s $OPENVPN_ROOT/demoCA/server.crt $OPENVPN_ROOT/server/server.crt && \
  ln -s $OPENVPN_ROOT/demoCA/private/server.key $OPENVPN_ROOT/server/server.key && \
  ln -s $OPENVPN_ROOT/demoCA/crl.pem $OPENVPN_ROOT/server/crl.pem && \
  ln -s $OPENVPN_ROOT/demoCA/dh.pem $OPENVPN_ROOT/server/dh.pem && \
  # PERMISSIONS
  chown openvpn:openvpn -R ./ && \
  chown openvpn:openvpn /var/log/openvpn.log

WORKDIR /etc/openvpn/server

COPY ./configs/iptables-save .
COPY ./configs/init.sh .
COPY --chown=8888:8888 --from=script-auth /opt/build/script-auth .

CMD . ./init.sh && /usr/sbin/openvpn --status-version 2 --suppress-timestamps --config server.conf
