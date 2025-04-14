#!/bin/bash

# This script aims to fix the DYLD error in TestFlight for Flutter apps

echo "Fixing TestFlight DYLD error: Library not loaded: @rpath/Flutter.framework/Flutter"

# Step 1: Clean up
flutter clean
cd ios
rm -rf Pods Podfile.lock
cd ..
flutter pub get

# Step 2: Ensure the Flutter.framework is properly embedded in the app
cd ios
pod install

# Step 3: Create archive with proper settings
cd ..
echo "Building archive with framework embedding enabled..."
flutter build ios --release || echo "Build failed, but continuing..."

# Step 4: Manual framework embedding for TestFlight
echo "Adding Flutter.framework to the app bundle..."

# Get the most recently modified .app file
APP_PATH=$(find build/ios/iphoneos -name "*.app" -type d -depth 1 | sort -n | tail -1)
if [ -z "$APP_PATH" ]; then
    echo "Could not find the app bundle. Build may have failed."
    exit 1
fi

# Create Frameworks directory if it doesn't exist
mkdir -p "$APP_PATH/Frameworks"

# Try to find Flutter.framework from multiple possible locations
FLUTTER_FRAMEWORK=""
LOCATIONS=(
    "build/ios/Release-iphoneos/Flutter.framework"
    "ios/Flutter/Flutter.framework"
    "ios/Pods/Flutter/Flutter.framework"
    "ios/.symlinks/flutter/ios-release/Flutter.framework"
)

for LOCATION in "${LOCATIONS[@]}"; do
    if [ -d "$LOCATION" ]; then
        FLUTTER_FRAMEWORK="$LOCATION"
        break
    fi
done

if [ -z "$FLUTTER_FRAMEWORK" ]; then
    echo "Could not find Flutter.framework. Looking in Pods..."
    FLUTTER_FRAMEWORK=$(find ios/Pods -name "Flutter.framework" -type d | head -1)
fi

if [ -z "$FLUTTER_FRAMEWORK" ]; then
    echo "Could not find Flutter.framework. Manual intervention required."
    exit 1
fi

echo "Found Flutter.framework at $FLUTTER_FRAMEWORK"
echo "Copying to app bundle..."
cp -R "$FLUTTER_FRAMEWORK" "$APP_PATH/Frameworks/"

# Verify the framework is there
if [ -f "$APP_PATH/Frameworks/Flutter.framework/Flutter" ]; then
    echo "Flutter.framework successfully added to app bundle!"
else
    echo "Failed to copy Flutter.framework to app bundle!"
    exit 1
fi

# Step 5: Build for archive again
echo "Rebuilding for archive..."
flutter build ios --release

echo "Done! Your app should now work in TestFlight. Archive it using Xcode and upload."
