
#!/bin/bash
set -e

cd /sources
tar -xf jinja2-3.1.6.tar.gz
cd jinja2-3.1.6

pip3 wheel -w dist --no-cache-dir \
    --no-build-isolation --no-deps "$PWD"

pip3 install --no-index --find-links dist Jinja2

cd /sources
rm -rf Jinja2-3.1.6

echo "Jinja2 selesai."
