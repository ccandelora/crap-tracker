# Dice Analytics Pro

<p align="center">
  <img src="assets/images/logo.png" alt="Dice Analytics Logo - Analysis tool" width="300"/>
</p>

<p align="center">
  A powerful dice roll analysis tool for statistical pattern recognition
</p>

## Overview

Dice Analytics Pro is a Flutter-based mobile and desktop application designed to help users track dice rolls, analyze patterns, and understand statistical distributions. The app provides comprehensive data visualization, intuitive tracking capabilities, and real-time statistics to enhance understanding of probability and statistical outcomes.

## Testing & Distribution

### Firebase App Distribution Setup

To set up Firebase App Distribution for testing:

1. **Create a Firebase project**:
   - Go to the [Firebase Console](https://console.firebase.google.com/)
   - Create a new project for "The Rail"

2. **Register your app**:
   - Add your iOS app to your Firebase project
   - Download the configuration file:
     - `GoogleService-Info.plist` for iOS (place in `ios/Runner/`)

3. **Create a Firebase App ID file**:
   - Add your Firebase app ID:
   ```json
   {
     "ios_app_id": "your-ios-app-id"
   }
   ```

4. **Update tester information**:
   - Add your testers' email addresses

### Deploying a Test Build

To deploy a test build to Firebase App Distribution:

```bash
# For iOS
./scripts/deploy_firebase.sh ios
```

Testers will receive an email with a link to download and install the app.

## Logo & Branding

The app features a minimalist, high-contrast logo with a white 3D dice and bold "THE RAIL" text on a black background. This design represents the app's focus on precision dice tracking and the "rail" boundary of the craps table.

### Setting Up the Logo

To use the custom dice logo:

1. Save the dice logo image as `lib/assets/images/logo.png`
2. Run the app to see the logo in the AppBar

### Generating Launcher Icons

The app is configured to use the logo as launcher icons. To generate icons:

```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

This will create appropriate sized icons for iOS, web, and macOS.

## Features

- **Player Management** - Create and manage multiple player profiles
- **Roll Tracking** - Record dice values with a beautiful, intuitive interface
- **Session Statistics** - Track performance metrics during gambling sessions
- **Detailed Analytics** - View comprehensive statistics and roll distributions
- **Real-time Probabilities** - See the mathematical probability of upcoming rolls
- **Dark & Light Themes** - Choose your preferred visual style

## Screenshots

<p align="center">
  <img src="assets/screenshots/home_screen.png" alt="Home Screen" width="200"/>
  <img src="assets/screenshots/roll_input.png" alt="Roll Input" width="200"/>
  <img src="assets/screenshots/statistics.png" alt="Statistics" width="200"/>
  <img src="assets/screenshots/player_stats.png" alt="Player Stats" width="200"/>
</p>

## Installation

### Prerequisites
- Flutter SDK (v3.7.0 or higher)
- Dart SDK (v3.0.0 or higher)
- iOS development tools for mobile deployment
- macOS development tools for desktop deployment

### Setup Instructions

1. Clone the repository:
```bash
git clone https://github.com/yourusername/the-rail.git
cd the-rail
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the build runner for Hive code generation:
```bash
flutter pub run build_runner build
```

4. Launch the app:
```bash
flutter run
```

## Usage

### Getting Started

1. **Add Players**: Create player profiles to track individual statistics
2. **Start Rolling**: Select a player and begin tracking dice rolls
3. **View Statistics**: Analyze performance metrics and patterns
4. **Customize Settings**: Configure the app to your preferences

### Key Functions

- **Roll Input**: Quickly record dice values during gameplay
- **Session Tracking**: Monitor performance across individual sessions
- **Statistical Analysis**: View detailed metrics and trends over time
- **Strategy Guide**: Access built-in guidance for optimal betting strategies

## Technologies Used

- **Flutter & Dart**: Cross-platform UI development
- **Provider**: State management
- **Hive**: Local data persistence
- **FL Chart**: Data visualization
- **Material Design 3**: Modern UI principles

## Data Privacy

The Rail stores all data locally on your device. No data is ever transmitted to external servers or shared with third parties.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

For any questions or suggestions, please open an issue on GitHub or contact the developer at [your-email@example.com](mailto:your-email@example.com).

---

<p align="center">
  Made with ❤️ for craps enthusiasts everywhere
</p> 