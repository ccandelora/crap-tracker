# The Rail

A powerful dice tracking application for craps players.

## Implementation Steps

### Logo Setup

1. **Replace the logo placeholder:**
   - Save the dice logo image to `lib/assets/images/logo.png`
   - The logo should be the white dice with "THE RAIL" text on black background

2. **Generate app icons:**
   ```bash
   flutter pub get
   flutter pub run flutter_launcher_icons
   ```

3. **Test the app:**
   ```bash
   flutter run
   ```

## Features

- Player management
- Roll tracking
- Session statistics
- Detailed analytics
- Real-time probabilities

## Development

Built with Flutter and Dart, using:
- Provider for state management
- Hive for local data storage
- FL Chart for visualizations
