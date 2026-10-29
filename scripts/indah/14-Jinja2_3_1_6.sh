
#!/bin/bash
set -e
cd /sources/Jinja2-3.1.6

pip3 wheel -w dist --no-cache-dir \
    --no-build-isolation --no-deps "$PWD"

pip3 install --no-index --find-links dist Jinja2

echo "Jinja2 selesai."
