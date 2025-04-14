#!/bin/bash

# Script to fix TestFlight DYLD errors and build a proper archive
set -e

echo "===== Preparing app for TestFlight ====="

# Step 1: Clean the environment
echo "Cleaning previous builds..."
cd ..
flutter clean
cd ios
rm -rf Pods Podfile.lock
rm -rf build

# Step 2: Get dependencies and install pods
echo "Installing dependencies..."
cd ..
flutter pub get
cd ios
pod install

# Step 3: Build for archive
echo "Building iOS archive..."
cd ..
flutter build ios --release --no-codesign

# Step 4: Ensure Flutter.framework is in the right place
echo "Checking for Flutter.framework..."
APP_PATH=$(find build/ios/iphoneos -name "*.app" -type d -depth 1 | head -1)
if [ -z "$APP_PATH" ]; then
    echo "Could not find app bundle. Build may have failed."
    exit 1
fi

# Create Frameworks directory
mkdir -p "$APP_PATH/Frameworks"

# Look for Flutter.framework in different locations
FLUTTER_FRAMEWORK=$(find . -path "*/Flutter.framework" -type d | head -1)
if [ -n "$FLUTTER_FRAMEWORK" ]; then
    echo "Found Flutter.framework at $FLUTTER_FRAMEWORK"
    cp -R "$FLUTTER_FRAMEWORK" "$APP_PATH/Frameworks/"
    echo "Copied Flutter.framework to app bundle"
else
    echo "Warning: Could not find Flutter.framework"
fi

echo "===== App is ready for TestFlight ====="
echo "Next steps:"
echo "1. Open ios/Runner.xcworkspace in Xcode"
echo "2. Select Product > Archive"
echo "3. When archive is complete, click 'Distribute App'"
echo "4. Choose 'App Store Connect' and follow the prompts"
echo "===== Good luck! =====" 