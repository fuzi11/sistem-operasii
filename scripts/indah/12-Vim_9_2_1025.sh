
#!/bin/bash
set -e
cd /sources/vim-9.2.1025

echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h

./configure --prefix=/usr
make
make install

ln -sfv vim /usr/bin/vi

echo "Vim selesai."
