flutter pub get
flutter gen-l10n
echo "$ANDROID_KEY_STORE_BASE64" | base64 -d > .android-keystore
echo "$ANDROID_KEY_PROPERTIES" > android/key.properties
sed -i 's@PATH@'"$PWD"'@g' ./android/key.properties
flutter build apk --release --obfuscate --split-debug-info=./build/debug_info
mv ./build/app/outputs/flutter-apk/app-release.apk ./build/android.apk
