#!/bin/bash
set -e

echo "Mulai instalasi Flit-Core-4.0.2..."

cd /sources
tar -xf flit_core-4.0.2.tar.gz
cd flit_core-4.0.2

pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps "$PWD"
pip3 install --no-index --find-links dist flit_core

cd /sources
rm -rf flit_core-4.0.2

echo "Instalasi Flit-Core-4.0.2 selesai!"