
#!/bin/bash
set -e
cd /sources
tar -xf iproute2-7.1.0.tar.xz
cd iproute2-7.1.0

sed -i /ARPD/d Makefile
rm -f man/man8/arpd.8

make NETNS_RUN_DIR=/run/netns
make SBINDIR=/usr/sbin install

install -vDm644 COPYING README* \
    -t /usr/share/doc/iproute2-7.1.0


cd /sources
rm -rf iproute2-7.1.0

echo "IPRoute2 selesai."
