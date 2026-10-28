
#!/bin/bash
set -e
cd /sources/dbus-1.16.2

mkdir -p build
cd build

meson setup --prefix=/usr \
    --buildtype=release \
    --wrap-mode=nofallback ..

ninja
ninja test
ninja install

ln -sfv /etc/machine-id /var/lib/dbus

echo "D-Bus selesai."
