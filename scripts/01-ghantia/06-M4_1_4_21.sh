#!/bin/bash
set -e

cat > $LFS/usr/share/config.site << EOF
ac_cv_func_posix_spawn_file_actions_addchdir=yes
ac_cv_func_posix_spawn_file_actions_addfchdir=yes
EOF

cd $LFS/sources
tar -xf m4-1.4.21.tar.xz
cd m4-1.4.21


./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

make 
make DESTDIR=$LFS install

cd $LFS/sources
rm -rf m4-1.4.21