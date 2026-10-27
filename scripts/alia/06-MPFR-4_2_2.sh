8.24 MPFR-4.2.2
The MPFR package contains functions for multiple precision math.

Approximate build time:
0.2 SBU
Required disk space:
44 MB
8.24.1 Installation of MPFR
Prepare MPFR for compilation:

./configure --prefix=/usr        \
            --disable-static     \
            --enable-thread-safe \
            --docdir=/usr/share/doc/mpfr-4.2.2
Compile the package and generate the HTML documentation:

make
make html
[Important] Important
The test suite for MPFR in this section is considered critical. Do not skip it under any circumstances.

Test the results and ensure that all 198 tests passed:

make check
Install the package and its documentation:

make install
make install-html
8.24.2 Contents of MPFR
Installed libraries:
libmpfr.so
Installed directory:
/usr/share/doc/mpfr-4.2.2
Short Descriptions
libmpfr

Contains multiple-precision math functions