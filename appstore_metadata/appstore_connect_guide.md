# App Store Connect Setup Guide for THE RAIL
**By Chris Candelora**

## Before You Begin

Ensure you have:
- An Apple Developer account ($99/year)
- Xcode installed and configured with your Apple ID
- All app metadata prepared in the `appstore_metadata` folder
- Built archives for iOS and macOS using the `build_archives.sh` script
- Your Team ID (replace `YOUR_TEAM_ID` in `ios/exportOptions.plist`)

## Creating a New App in App Store Connect

1. **Log in to App Store Connect**
   - Visit [App Store Connect](https://appstoreconnect.apple.com/)
   - Sign in with your Apple Developer account

2. **Navigate to My Apps**
   - Click "Apps" in the top navigation
   - Click the "+" button and select "New App"

3. **Complete the New App Form**
   - Platforms: iOS, macOS (create separate entries for each)
   - Name: THE RAIL
   - Primary Language: English (U.S.)
   - Bundle ID: Select "com.therailapp.craptracker" from the dropdown
   - SKU: THERAIL2024 (or your preferred unique identifier)
   - User Access: Full Access (default)

## Setting Up App Information

1. **App Store Tab**
   - Copy content from `app_description.md` to the relevant fields
   - Upload screenshots from `appstore_metadata/screenshots`
   - Add app preview videos (if available)
   - Set a support URL (your website or support email)
   - Set marketing URL (optional)
   - Configure app price and availability

2. **Prepare for Submission**
   - Set the required age rating (17+, as we've documented)
   - Add required app store categories:
     - Primary: Entertainment
     - Secondary: Utilities
   - Set the app version info (1.0.0)
   - Upload build when it's ready (after archiving with Xcode)

3. **App Privacy Section**
   - Use the `privacy_policy.md` as a reference
   - Select "No" for data collection since our app stores all data locally
   - Provide the privacy policy URL or link to your hosted privacy policy

## Review Information

1. **Contact Information**
   - Add your contact details for the App Review team

2. **Notes for Apple**
   - Use content from `app_review_notes.md`
   - Explain that this is a statistical tracking tool, not a gambling app
   - Clarify that no real money is involved

3. **Sign-in Information**
   - Not required for THE RAIL as it doesn't use accounts

## TestFlight Setup

1. **Internal Testing**
   - Navigate to the TestFlight tab
   - Add internal testers by email (Apple Developer account team members)
   - Enable/disable builds for testing

2. **External Testing**
   - Create a new external testing group
   - Add external testers by email
   - Provide test information and instructions
   - Submit for Beta App Review (required for external testers)

## Submitting for Review

1. **Final Checks**
   - Verify all app information is correct
   - Ensure all required metadata is complete
   - Check that the build has been uploaded and processed

2. **Submit for Review**
   - Click "Submit for Review" button
   - Answer the export compliance questions
   - Choose between manual or automatic release
   - Submit your app

## After Submission

- Monitor the app status in App Store Connect
- Respond promptly to any inquiries from the App Review team
- Prepare marketing materials for your app launch
- Set up analytics to track downloads and usage after release 