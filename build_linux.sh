#!/bin/bash
# sudo apt update && sudo apt install libsecret-1-dev libjsoncpp-dev clang cmake git ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev dpkg-dev debhelper fakeroot lintian rpm

flutter pub get
flutter gen-l10n
flutter build linux --release --obfuscate --split-debug-info=build/debug-info

cd browser_cli
flutter pub get
dart compile exe bin/browser_cli.dart
cd ..

mkdir -p build/deb/email-alias/opt/share/email-alias/cli
cp -r build/linux/*/release/bundle/* build/deb/email-alias/opt/share/email-alias
mv browser_cli/bin/browser_cli.exe build/deb/email-alias/opt/share/email-alias/cli/browser_cli

install -D linux/email_alias.desktop build/deb/email-alias/usr/share/applications/email-alias.desktop
install -D linux/icon_light.svg build/deb/email-alias/usr/share/icons/hicolor/48x48/apps/email-alias-light.svg
install -D linux/icon_dark.svg build/deb/email-alias/usr/share/icons/hicolor/48x48/apps/email-alias-dark.svg

install -D linux/deb/control build/deb/email-alias/DEBIAN/control

cd build
ARCH=$(dpkg --print-architecture)
perl -0777 -pe "s/<arch>/$ARCH/g" -i ./deb/email-alias/DEBIAN/control
rm -f email-alias.deb
rm -f email-alias.rpm
dpkg-deb --build deb/email-alias
mv deb/email-alias*.deb email-alias.deb
fpm -s deb -t rpm email-alias.deb
mv email-alias*.rpm email-alias.rpm
