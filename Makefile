build:
	docker build -t openvpn:server .

run:
	docker run -it --rm --name openvpn -p 8081:8081/tcp -p 8081:8081/udp \
	--device /dev/net/tun \
	--cap-add CAP_NET_ADMIN \
	-v `pwd`/configs/server.conf:/etc/openvpn/server/server.conf \
	openvpn:server

copy:
	_=$(shell . ./copy.sh)

add:
	_=$(shell . ./add.sh)

.PHONY: build run copy add
