```bash
#!/bin/bash
set -e

echo "Mulai instalasi Perl-5.44.0..."

cd /sources
tar -xf perl-5.44.0.tar.xz
cd perl-5.44.0

export BUILD_ZLIB=False
export BUILD_BZIP2=0

sh Configure -des \
    -D prefix=/usr \
    -D vendorprefix=/usr \
    -D privlib=/usr/lib/perl5/5.44/core_perl \
    -D archlib=/usr/lib/perl5/5.44/core_perl \
    -D sitelib=/usr/lib/perl5/5.44/site_perl \
    -D sitearch=/usr/lib/perl5/5.44/site_perl \
    -D vendorlib=/usr/lib/perl5/5.44/vendor_perl \
    -D vendorarch=/usr/lib/perl5/5.44/vendor_perl \
    -D man1dir=/usr/share/man/man1 \
    -D man3dir=/usr/share/man/man3 \
    -D pager="/usr/bin/less -isR" \
    -D useshrplib \
    -D usethreads

make

TEST_JOBS=$(nproc) make test_harness

make install

unset BUILD_ZLIB
unset BUILD_BZIP2

cd /sources
rm -rf perl-5.44.0

echo "Instalasi Perl-5.44.0 selesai!"
```