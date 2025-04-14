# TestFlight Testing Guide for THE RAIL
**By Chris Candelora**

## Why Use TestFlight?

TestFlight offers several advantages before a full App Store release:

1. **Real User Testing**: Get feedback from actual users before public launch
2. **Device Compatibility**: Test on a variety of real devices
3. **Bug Identification**: Catch issues before they affect App Store users
4. **Review Process Preview**: Experience the Apple review process with lower stakes
5. **Gradual Rollout**: Soft-launch to a controlled audience

## Setting Up TestFlight

### Internal Testing

Internal testing is available immediately and does not require App Review approval.

1. **Add Internal Testers**
   - Go to App Store Connect > Your App > TestFlight > Internal Testing
   - Add internal testers (must be part of your Apple Developer team)
   - Each tester can test on up to 30 devices

2. **Distribute Build**
   - Once your build is uploaded and processed, enable it for internal testing
   - Internal testers will receive an email notification

### External Testing

External testing allows up to 10,000 testers but requires a Beta App Review.

1. **Create Testing Group**
   - Go to App Store Connect > Your App > TestFlight > External Testing
   - Click "+" to add a new group (e.g., "Beta Testers")

2. **Add Test Information**
   - Add a test description explaining what to test
   - Set a marketing URL (optional)
   - Add feedback email for testers to contact you

3. **Submit for Beta App Review**
   - Before external testers can access your app, you need Beta App Review approval
   - This is similar to the App Store review but typically faster
   - Enter all required information including:
     - Contact information
     - Beta App Review notes (explain what to test)
     - Build uses IDFA? (No for THE RAIL)

4. **Add External Testers**
   - Add testers by email or use a public link
   - Individual: Enter email addresses manually
   - Public Link: Create a public link anyone can use (within your 10,000 tester limit)

## Inviting Testers

### For Internal Testers
- They'll receive an automatic email invitation once added
- They need to install the TestFlight app on their device
- Follow the instructions in the email to accept and install

### For External Testers
- After Beta App Review approval, they'll receive an invitation email
- They need to install the TestFlight app
- They can install the app using the provided redemption code

## Managing Feedback

1. **Automatic Feedback**
   - Testers can send feedback directly through TestFlight
   - They can include screenshots and notes
   - You'll receive this feedback in App Store Connect

2. **Crash Reports**
   - TestFlight automatically collects crash reports
   - View these in App Store Connect > TestFlight > Crashes

3. **Directed Testing**
   - Create a test plan with specific features to test
   - Include this in your test notes
   - Consider creating a feedback form for structured responses

## TestFlight Timeline

- **Internal Testing**: Available immediately after build processing
- **Beta App Review**: Typically 1-2 days
- **External Testing**: 90 days from the build upload date
- **Build Expiration**: TestFlight builds expire after 90 days

## Updating TestFlight Builds

1. **Upload New Build**
   - Use the same process as before to archive and upload
   - Increment the build number in pubspec.yaml

2. **Submit for Review Again**
   - Each new build for external testing requires Beta App Review
   - Internal testing builds are available immediately

3. **Notify Testers**
   - You can notify testers about the new build manually
   - Or let TestFlight automatically notify them

## Best Practices

1. **Clear Testing Instructions**
   - Provide specific features to test
   - Include any known issues to avoid duplicate reports

2. **Regular Updates**
   - Keep testers engaged with regular builds
   - Share progress and how feedback is being addressed

3. **Adequate Testing Time**
   - Allow at least 2 weeks of testing before App Store submission
   - This gives time to identify and fix critical issues

4. **Monitor Feedback Closely**
   - Check App Store Connect daily during testing
   - Respond promptly to serious issues 