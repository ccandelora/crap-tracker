#!/bin/bash

echo "==== Craps Tracker App Runner ===="
echo "This script will run your Flutter app from the correct directory."
echo ""

# Change to the Flutter project directory
cd crap_tracker

echo "Running app from: $(pwd)"
echo "Using Flutter version: $(flutter --version | head -n 1)"
echo ""
echo "Starting app on iPhone 16 Pro simulator..."
echo "----------------"

# Run the Flutter app on iPhone 16 Pro simulator
flutter run -d "iPhone 16 Pro"

# Note: If you get permission errors about Local Network, you'll need to
# allow the app permission in iOS Settings -> Privacy -> Local Network 