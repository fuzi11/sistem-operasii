
#!/bin/bash
set -e
cd /sources/grub-2.14

unset CFLAGS CPPFLAGS CXXFLAGS LDFLAGS

./configure --prefix=/usr \
            --sysconfdir=/etc \
            --disable-efiemu \
            --disable-werror
make
make install

echo "GRUB selesai dibangun."
