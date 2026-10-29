
#!/bin/bash
set -e

cd $LFS/sources
tar -xf linux-7.1.8.tar.xz
cd linux-7.1.8

make mrproper
make headers

find usr/include -type f ! -name '*.h' -delete

cp -rv usr/include "$LFS/usr"

cd $LFS/sources
rm -rf linux-7.1.8
