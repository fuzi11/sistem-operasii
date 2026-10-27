#!/bin/bash
set -e

cd /sources
tar -xf setuptools-84.0.0.tar.gz
cd setuptools-84.0.0

pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps "$PWD"
pip3 install --no-index --find-links dist setuptools

cd /sources
rm -rf setuptools-84.0.0