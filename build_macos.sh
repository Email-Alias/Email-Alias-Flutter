flutter pub get
flutter gen-l10n
rm -r ./macos/safari/Resources
cd ./build || exit
unzip web_safari.zip -d web_safari
cd .. || exit
mv ./build/web_safari ./macos/safari/Resources
flutter build macos --release --obfuscate --split-debug-info=./build/debug_info
echo "$MACOS_CERTIFICATE" | base64 --decode > certificate.p12
security create-keychain -p "$MACOS_KEYCHAIN_PASSWORD" build.keychain
security default-keychain -s build.keychain
security unlock-keychain -p "$MACOS_KEYCHAIN_PASSWORD" build.keychain
security import certificate.p12 -k build.keychain -P "$MACOS_CERTIFICATE_PASSWORD" -T /usr/bin/codesign
security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k "$MACOS_KEYCHAIN_PASSWORD" build.keychain
security find-identity
/usr/bin/codesign --force --deep -s BHUJ88RV68 ./build/macos/Build/Products/Release/Email\ Alias.app
brew install create-dmg
cd ./build/macos/Build/Products/Release || exit
create-dmg \
  --volname "Email Alias" \
  --window-pos 200 120 \
  --window-size 800 529 \
  --icon-size 130 \
  --text-size 14 \
  --icon "Email Alias.app" 260 250 \
  --hide-extension "Email Alias.app" \
  --app-drop-link 540 250 \
  --hdiutil-quiet \
  "macos.dmg" \
  "Email Alias.app"
cp macos.dmg ../../../..
