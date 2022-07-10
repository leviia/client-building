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

if [[ "$2" == "m1" ]]; then
export QT_PATH=$(brew --prefix qt5)/bin
export Qt5_DIR=$(brew --prefix qt5)/lib/cmake/Qt5
export Qt5LinguistTools_DIR=$(brew --prefix qt5)/lib/cmake/Qt5LinguistTools
export Qt5Keychain_DIR=/Users/m1/workspace/qtkeychain-arm64-release/lib/cmake/Qt5Keychain

echo $QT_PATH
echo $Qt5_DIR
echo $Qt5LinguistTools_DIR
echo $Qt5Keychain_DIR

export MACOSX_DEPLOYMENT_TARGET=10.13
fi

rm -rf install/*
rm -rf build
mkdir -p build
cd build

if [[ "$2" == "m1" ]]; then
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=../install ../desktop -DBRANDING_VALUE=$1 \
    -DBUILD_OWNCLOUD_OSX_BUNDLE=ON \
    -DCMAKE_OSX_ARCHITECTURES="arm64" \
    -DCMAKE_MACOSX_RPATH=TRUE
else
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=../install ../desktop -DBRANDING_VALUE=$1 \
    -DBUILD_OWNCLOUD_OSX_BUNDLE=ON \
    -DCMAKE_OSX_SYSROOT="/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.14.sdk/" \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=10.14
fi
make
make install

MY_APP=`echo $(ls ../install/*.app)`
codesign -s 'Developer ID Application: LEVIIA (7S955PF2T8)' --timestamp --options=runtime --force --preserve-metadata=entitlements --verbose=4 --deep ../install/${MY_APP}

./admin/osx/create_mac.sh ../install . "Developer ID Installer: LEVIIA (7S955PF2T8)"

# Notarization by Apple
cd ../install/
rm *-*.pkg.tbz
MY_PKG=`echo $(ls *.pkg)`

NOTARIZATION_ACCOUNT=$(security find-generic-password -w -s "NOTARIZATION_ACCOUNT")
NOTARIZATION_PASSWORD=$(security find-generic-password -w -s "NOTARIZATION_PASSWORD")

xcrun altool --notarize-app -u "${NOTARIZATION_ACCOUNT}" -p "${NOTARIZATION_PASSWORD}" --primary-bundle-id "${MY_PKG}" --file ${MY_PKG}
sleep 600

xcrun stapler staple -v ${MY_PKG}
xcrun stapler validate -v ${MY_PKG}

cd ..
