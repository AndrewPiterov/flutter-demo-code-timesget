# TimesGet

This repository for code demonstration purpose.

## Getting Started

1. In pubspec.yml
    - reset build to 1.0.0+1
    - change description
2. Run `flutter packages get`
3. Replace assets/images
4. Update app's config in lib/config
5. Update app's colors in lib/config
6. Update locale/*.json
7. Add .env
8. Add Git remote

## iOS

1. Open XCode
2. Rename App
3. Add Sign App in XCode
4. Add GoogleService-Info.plist in XCode
5. Replace App Icon
   - Splash screen: center center and 1/2 screen width.
   - Launch screen: Add image on LaunchScreen.storyboard
6. Add Google Map Api Key in ios/Runner/AppDelegate.swift
7. Push Notifications
   - Read <https://pub.dev/packages/firebase_messaging>
   - Add or Use already Auth Key
   - Add .p8 in Firebase
8. Build and run locally
9. Release <https://flutter.dev/docs/deployment/ios>

## Android

1. Replace the previous applicationId
   - android/app/build.gradle
   - android/app/src/main/kotlin/com/timesget/{APP_BUNDLE}/MainActivity.kt
2. Update App name
   - in every AndroidManifest.xml and change label
3. Rename folder in app/src/main/kotlin/com/...
4. Update package in app/src/main/kotlin/com/.../MainActivity.kt
5. Replace App Icon
   - icons: copy mipmaps folders
6. Add google-services.json into android/app
7. Add Google Map Api Key in android/app/src/main/AndroidManifest.xml
8. Signing tha app for release by
`keytool -genkey -v -keystore ~/key-timesget-{APP_BUNDLE}.jks -keyalg RSA -keysize 2048 -validity 10000 -alias timesget.{APP_BUNDLE}`
9. Add android/key.properties
10. Run the app localy
11. Build appbundle `flutter build appbundle` or apk `flutter build apk`
