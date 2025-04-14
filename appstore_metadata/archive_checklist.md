# Archive and Validate Checklist for THE RAIL
**By Chris Candelora**

## Before Archiving

- [ ] Update `teamID` in `ios/exportOptions.plist` with your Apple Developer Team ID
- [ ] Ensure all icons and launch screens are properly configured
- [ ] Verify app version and build number are correct in `pubspec.yaml` (currently set to 1.0.0+1)
- [ ] Ensure all metadata files in `appstore_metadata` are complete
- [ ] Test the app thoroughly on iOS and macOS devices/simulators
- [ ] Fix any linting issues or warnings
- [ ] Commit all changes to your repository

## Archiving Process

1. **Run the archive script**
   ```
   ./build_archives.sh
   ```

2. **Alternative: Manual Archive Commands**
   
   For iOS:
   ```
   flutter clean
   flutter pub get
   flutter build ipa --release
   ```
   
   For macOS:
   ```
   flutter clean
   flutter pub get
   flutter build macos --release
   ```

## Validating in Xcode

### For iOS:

1. **Open Xcode**
   - Open Xcode > Window > Organizer

2. **Locate Archive**
   - Find your archive in the list (if using our script, it's at `build/ios/archive/Runner.xcarchive`)
   - If not visible, drag and drop the `.xcarchive` file into the Organizer window

3. **Validate Archive**
   - Select the archive
   - Click "Validate App" button
   - Sign in with your Apple ID if prompted
   - Select your development team
   - Follow the prompts to validate
   - Fix any issues that arise during validation

4. **Upload to App Store Connect**
   - After successful validation, click "Distribute App"
   - Select "App Store Connect" as the distribution method
   - Follow the prompts to upload
   - Wait for the app to process in App Store Connect (can take up to an hour)

### For macOS:

1. **Open Xcode**
   - Open Xcode > Window > Organizer

2. **Create Archive in Xcode**
   - Open the macOS project in Xcode: `open macos/Runner.xcworkspace`
   - Select Product > Archive
   - Wait for archiving to complete

3. **Validate Archive**
   - Follow the same validation steps as for iOS

## Common Issues and Fixes

- **Missing Provisioning Profiles**
  - Ensure you have the correct provisioning profiles in your Apple Developer account
  - In Xcode, go to Preferences > Accounts > Manage Certificates to download profiles

- **Icon Validation Errors**
  - Ensure all icons are the correct size and format
  - Run `flutter pub run flutter_launcher_icons` again if needed

- **Entitlements Issues**
  - Check that the entitlements in your app match your provisioning profile capabilities

- **Bitcode and Symbols**
  - Our `exportOptions.plist` has bitcode disabled and symbols enabled, which is recommended

## Final Checklist Before Submission

- [ ] App successfully validates with no errors
- [ ] TestFlight version is tested if using TestFlight
- [ ] All app metadata is uploaded to App Store Connect
- [ ] App privacy information is completed
- [ ] Review information is provided
- [ ] App icon appears correctly in App Store Connect
- [ ] Screenshots are uploaded for all required device sizes 