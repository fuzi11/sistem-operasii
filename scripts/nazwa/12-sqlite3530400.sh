#!/bin/bash
set -e

echo "Mulai instalasi Sqlite-3530400..."

cd /sources
tar -xf sqlite-autoconf-3530400.tar.gz
cd sqlite-autoconf-3530400

python3 -m zipfile -e ../sqlite-doc-3530400.zip .

./configure --prefix=/usr \
            --disable-static \
            --enable-fts4 \
            --enable-fts5 \
            CPPFLAGS="-D SQLITE_ENABLE_COLUMN_METADATA=1 \
                      -D SQLITE_ENABLE_UNLOCK_NOTIFY=1 \
                      -D SQLITE_ENABLE_DBSTAT_VTAB=1 \
                      -D SQLITE_SECURE_DELETE=1"

make LDFLAGS.rpath=""
make install

cp -v -R sqlite-doc-3530400 -T /usr/share/doc/sqlite-3.53.4

cd /sources
rm -rf sqlite-autoconf-3530400

echo "Instalasi Sqlite-3530400 selesai!"