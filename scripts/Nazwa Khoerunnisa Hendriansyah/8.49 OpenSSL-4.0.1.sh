```bash
#!/bin/bash
set -e

echo "Mulai instalasi OpenSSL-4.0.1..."

cd /sources
tar -xf openssl-4.0.1.tar.gz
cd openssl-4.0.1

./config --prefix=/usr \
         --openssldir=/etc/ssl \
         --libdir=lib \
         shared \
         zlib-dynamic

make

make test

make INSTALL_LIBS= MANSUFFIX=ssl install

mv -v /usr/share/doc/openssl /usr/share/doc/openssl-4.0.1

cp -vfr doc/* /usr/share/doc/openssl-4.0.1

cd /sources
rm -rf openssl-4.0.1

echo "Instalasi OpenSSL-4.0.1 selesai!"
```