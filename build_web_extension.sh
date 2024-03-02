flutter pub get
flutter gen-l10n
flutter build web --release --web-renderer html --csp

rm -r ./build/web/canvaskit
rm ./build/web/.last_build_id
rm ./build/web/flutter*.js
rm ./build/web/assets/AssetManifest*
rm -r ./build/web/assets/shaders
rm ./build/web/version.json

cp -r ./build/web ./build/web_safari
mv ./build/web_safari/assets/fonts/* ./build/web_safari
mv ./build/web_safari/assets/packages/cupertino_icons/assets/* ./build/web_safari
mv ./build/web_safari/assets/NOTICES ./build/web_safari/
mv ./build/web_safari/FontManifest_safari.json ./build/web_safari/FontManifest.json
rm -r ./build/web_safari/assets
rm ./build/web_safari/manifest_firefox.json
sed -i 's@+"assets/"@@g' './build/web_safari/main.dart.js'

cp -r ./build/web ./build/web_firefox
rm ./build/web_firefox/manifest.json
rm ./build/web_firefox/FontManifest_safari.json
mv ./build/web_firefox/manifest_firefox.json ./build/web_firefox/manifest.json

rm ./build/web/manifest_firefox.json
rm ./build/web/FontManifest_safari.json
