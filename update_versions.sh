MAJOR_VERSION=$(echo "$VERSION" | cut -d '.' -f1)
MINOR_VERSION=$(echo "$VERSION" | cut -d '.' -f2)
PATCH_VERSION=$(echo "$VERSION" | cut -d '.' -f3)
DEPENDENCY_VERSION=$(echo "$VERSION" | cut -d '.' -f4)

MINOR_VERSION=$(printf '%02d' "$MINOR_VERSION")
PATCH_VERSION=$(printf '%02d' "$PATCH_VERSION")
DEPENDENCY_VERSION=$(printf '%02d' "$DEPENDENCY_VERSION")

BUILD_NUMBER=$MAJOR_VERSION$MINOR_VERSION$PATCH_VERSION$DEPENDENCY_VERSION

sed -i 's@msix_version: 1.0.0.0@msix_version: '"$VERSION"'@g' ./pubspec.yaml
sed -i 's@versionCode 1000000@versionCode '"$BUILD_NUMBER"'@g' ./android/app/build.gradle
sed -i 's@versionName "1.0.0.0"@versionName "'"$VERSION"'"@g' ./android/app/build.gradle
sed -i 's@CURRENT_PROJECT_VERSION = 1000000@CURRENT_PROJECT_VERSION = '"$BUILD_NUMBER"'@g' ./macos/Runner.xcodeproj/project.pbxproj
sed -i 's@MARKETING_VERSION = 1.0.0.0@MARKETING_VERSION = '"$VERSION"'@g' ./macos/Runner.xcodeproj/project.pbxproj
sed -i 's@CURRENT_PROJECT_VERSION = 1000000@CURRENT_PROJECT_VERSION = '"$BUILD_NUMBER"'@g' ./ios/Runner.xcodeproj/project.pbxproj
sed -i 's@MARKETING_VERSION = 1.0.0.0@MARKETING_VERSION = '"$VERSION"'@g' ./ios/Runner.xcodeproj/project.pbxproj
sed -i 's@"version": "1.0.0.0"@"version": "'"$VERSION"'"@g' ./web/manifest.json
sed -i 's@"version": "1.0.0.0"@"version": "'"$VERSION"'"@g' ./web/manifest_firefox.json