#!/bin/bash

for d in /usr/local/opt/*/bin
do
echo $d
export PATH="$PATH:$d"
done

echo $PATH

export OPENSSL_ROOT_DIR="$(brew --prefix openssl)/"
export ZLIB_LIBRARY="$(brew --prefix zlib)/lib/"
export ZLIB_INCLUDE_DIR="$(brew --prefix zlib)/include/"

echo $OPENSSL_ROOT_DIR
echo $ZLIB_LIBRARY
echo $ZLIB_INCLUDE_DIR

rm -rf install/*.app
rm -rf build
mkdir -p build
cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=../install ../desktop -DBRANDING_VALUE=$1 \
    -DCMAKE_OSX_SYSROOT="/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.14.sdk/" \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=10.14
make
make install
./admin/osx/create_mac.sh ../install . $2
cd -
