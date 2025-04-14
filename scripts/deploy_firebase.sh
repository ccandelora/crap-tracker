#!/bin/bash

# Exit on error
set -e

# Build configuration
BUILD_TYPE="release"
PLATFORM=$1

# Print usage if no platform specified
if [ -z "$PLATFORM" ]; then
  echo "Usage: ./deploy_firebase.sh <android|ios>"
  exit 1
fi

# Validate platform input
if [ "$PLATFORM" != "android" ] && [ "$PLATFORM" != "ios" ]; then
  echo "Error: Platform must be 'android' or 'ios'"
  exit 1
fi

echo "🔥 Starting Firebase App Distribution deployment for The Rail app ($PLATFORM)"

# Clean up previous builds
echo "🧹 Cleaning up previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build the app
echo "🏗️ Building $PLATFORM app in $BUILD_TYPE mode..."
if [ "$PLATFORM" == "android" ]; then
  flutter build apk --$BUILD_TYPE
  
  # Distribute Android build
  echo "📱 Distributing Android build to Firebase App Distribution..."
  firebase appdistribution:distribute build/app/outputs/flutter-apk/app-$BUILD_TYPE.apk \
    --app $(cat android/app/src/main/assets/firebase_app_id_file.json | jq -r '.android_app_id') \
    --config android/app/src/main/assets/firebase_app_distribution_config.json
else
  flutter build ios --$BUILD_TYPE --no-codesign
  
  # Distribute iOS build
  echo "📱 Distributing iOS build to Firebase App Distribution..."
  cd ios
  firebase appdistribution:distribute Runner.ipa \
    --app $(cat Runner/GoogleService-Info.plist | grep GOOGLE_APP_ID | sed -E 's/.*<string>(.*)<\/string>/\1/') \
    --config ../android/app/src/main/assets/firebase_app_distribution_config.json
  cd ..
fi

echo "✅ Deployment to Firebase App Distribution completed successfully!" 