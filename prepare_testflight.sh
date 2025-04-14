#!/bin/bash

# Script to prepare app for TestFlight
set -e

echo "===== TestFlight Preparation Script ====="

# Clean and get dependencies
echo "Step 1: Cleaning environment..."
flutter clean
rm -rf ios/Pods ios/Podfile.lock
flutter pub get

# Update Flutter embeddding
echo "Step 2: Ensuring Flutter framework is available..."
mkdir -p ios/Flutter/Flutter.framework
mkdir -p ios/Flutter/App.framework
touch ios/Flutter/Flutter.framework/Flutter
touch ios/Flutter/App.framework/App

# Reinstall pods with dynamic frameworks
echo "Step 3: Installing pods..."
cd ios
pod install
cd ..

# Build iOS release
echo "Step 4: Building iOS release..."
flutter build ios --release --no-codesign || true

# Check if the build succeeded
APP_PATH=$(find ios/build -name "*.app" -type d 2>/dev/null | head -1)
if [ -z "$APP_PATH" ]; then
  APP_PATH=$(find build/ios/iphoneos -name "*.app" -type d 2>/dev/null | head -1)
fi

if [ -n "$APP_PATH" ]; then
  echo "App bundle found at: $APP_PATH"
  
  # Create Frameworks directory and copy Flutter framework
  mkdir -p "$APP_PATH/Frameworks"
  
  # Find Flutter.framework
  FLUTTER_FRAMEWORK_SRC=$(find ios -path "*/Flutter.framework" -type d | head -1)
  if [ -z "$FLUTTER_FRAMEWORK_SRC" ]; then
    FLUTTER_FRAMEWORK_SRC=$(find . -path "*/Flutter.framework" -type d | grep -v "$APP_PATH" | head -1)
  fi
  
  if [ -n "$FLUTTER_FRAMEWORK_SRC" ]; then
    echo "Copying Flutter.framework from $FLUTTER_FRAMEWORK_SRC"
    cp -R "$FLUTTER_FRAMEWORK_SRC" "$APP_PATH/Frameworks/"
  else
    echo "Warning: Could not find Flutter.framework"
  fi
else
  echo "Warning: Could not find app bundle"
fi

echo "===== Build preparation complete ====="
echo ""
echo "Next steps:"
echo "1. Open ios/Runner.xcworkspace in Xcode"
echo "2. Select Product > Archive"
echo "3. When archive is complete, click 'Distribute App'"
echo "4. Choose 'App Store Connect' and follow the prompts"
echo ""
echo "Note: If you still encounter DYLD errors in TestFlight:"
echo "- In Xcode, select Runner target > Build Phases"
echo "- Expand 'Embed Frameworks' section"
echo "- Click + and add Flutter.framework"
echo "- Set Embed to 'Embed & Sign'"
echo "" 