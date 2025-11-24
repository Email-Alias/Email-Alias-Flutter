#!/usr/bin/env bash
set -e

flutter pub get
flutter gen-l10n
flutter build windows --release --obfuscate --split-debug-info=build/debug-info

cd browser_cli
flutter pub get
dart compile exe bin/browser_cli.dart -o browser_cli.exe
cd ..

rm -rf build/windows_installer/email-alias
mkdir -p build/windows_installer/email-alias/cli

cp -r build/windows/x64/runner/Release/* build/windows_installer/email-alias/
cp browser_cli/browser_cli.exe build/windows_installer/email-alias/cli/browser_cli.exe
cp windows/runner/resources/app_icon.ico build/windows_installer/app_icon.ico
cp windows/installer.iss build/windows_installer/installer.iss
ISCC build/windows_installer/installer.iss
mv build/windows_installer/Output/email-alias-installer.exe build/email-alias.exe
