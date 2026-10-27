#!/bin/bash
set -e

cd /sources
tar -xf packaging-26.3.tar.gz
cd packaging-26.3

pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps "$PWD"
pip3 install --no-index --find-links dist packaging

cd /sources
rm -rf packaging-26.3