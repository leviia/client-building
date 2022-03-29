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
    -DBUILD_OWNCLOUD_OSX_BUNDLE=ON \
    -DCMAKE_OSX_SYSROOT="/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.10.sdk/" \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=10.10
make
make install

codesign -s 'Developer ID Application: LEVIIA (7S955PF2T8)' --timestamp --options=runtime --force --preserve-metadata=entitlements --verbose=4 --deep ../install/Leviia.app

./admin/osx/create_mac.sh ../install . "Developer ID Installer: LEVIIA (7S955PF2T8)"

cd -

# Notarization by Apple
cd install/
rm *-*.pkg.tbz
MY_PKG=`echo $(ls *.pkg)`

NOTARIZATION_ACCOUNT=$(security find-generic-password -w -s "NOTARIZATION_ACCOUNT")
NOTARIZATION_PASSWORD=$(security find-generic-password -w -s "NOTARIZATION_PASSWORD")

xcrun altool --notarize-app -u "${NOTARIZATION_ACCOUNT}" -p "${NOTARIZATION_PASSWORD}" --primary-bundle-id "${MY_PKG}" --file ${MY_PKG}
sleep 600

xcrun stapler staple -v ${MY_PKG}
xcrun stapler validate -v ${MY_PKG}