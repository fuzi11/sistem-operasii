
#!/bin/bash
set -e

cd /sources
tar -xf dbus-1.16.2.tar.xz
cd dbus-1.16.2

mkdir -p build
cd build

meson setup --prefix=/usr \
    --buildtype=release \
    --wrap-mode=nofallback ..

ninja
ninja install

ln -sfv /etc/machine-id /var/lib/dbus

cd /sources
rm -rf dbus-1.16.2

echo "D-Bus selesai."
