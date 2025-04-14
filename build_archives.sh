#!/bin/bash
# Build script for THE RAIL app
# Author: Chris Candelora

# Define color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting build process for THE RAIL app...${NC}"

# Clean the project first
echo -e "${YELLOW}Cleaning project...${NC}"
flutter clean

# Get dependencies
echo -e "${YELLOW}Getting dependencies...${NC}"
flutter pub get

# Build iOS archive
echo -e "${YELLOW}Building iOS archive...${NC}"
flutter build ipa --release --export-options-plist=ios/exportOptions.plist

# Build macOS archive
echo -e "${YELLOW}Building macOS archive...${NC}"
flutter build macos --release

echo -e "${GREEN}Build process completed!${NC}"
echo -e "${YELLOW}iOS archive location:${NC} build/ios/archive/Runner.xcarchive"
echo -e "${YELLOW}macOS app location:${NC} build/macos/Build/Products/Release/THE RAIL.app"
echo ""
echo -e "${GREEN}Next steps:${NC}"
echo "1. Upload the iOS archive to App Store Connect using Xcode"
echo "2. Upload the macOS app to App Store Connect using Xcode"
echo "3. Complete the App Store submission process in App Store Connect" 