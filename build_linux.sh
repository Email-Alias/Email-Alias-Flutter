flutter pub get
flutter gen-l10n
sudo apt update && sudo apt install libsecret-1-dev libjsoncpp-dev clang cmake git ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev
flutter build linux --release --obfuscate --split-debug-info=./build/debug_info
cp ./linux/Icon.svg ./build/linux/x64/release/bundle
mkdir -p .debpkg/usr/share/applications/
mkdir -p .debpkg/opt/share/email-alias/
mkdir -p .rpmpkg/usr/share/applications/
mkdir -p .rpmpkg/opt/share/email-alias/
cp "./linux/email-alias.desktop" ./.debpkg/usr/share/applications/
cp -r ./build/linux/x64/release/bundle/* ./.debpkg/opt/share/email-alias/
cp "./linux/email-alias.desktop" ./.rpmpkg/usr/share/applications/
cp -r ./build/linux/x64/release/bundle/* ./.rpmpkg/opt/share/email-alias/