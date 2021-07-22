#!/bin/bash

for d in /usr/local/Cellar/*/*/bin
do
echo $d
export PATH="$PATH:$d"
done

echo $PATH

export OPENSSL_ROOT_DIR="/usr/local/Cellar/openssl@1.1/1.1.1k/"
export ZLIB_LIBRARY="/usr/local/Cellar/zlib/1.2.11/lib/"
export ZLIB_INCLUDE_DIR="/usr/local/Cellar/zlib/1.2.11/include/"

mkdir -p build
cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=../install ../desktop
make
make install
./admin/osx/create_mac.sh ../install .
cd -
