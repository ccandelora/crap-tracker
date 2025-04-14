# Launch Screen Specifications for The Rail

## Design Elements
- **Background Color**: Dark background (#121212 or similar dark shade)
- **Logo**: "THE RAIL" text logo prominently displayed
- **Icon**: Dice imagery consistent with app branding
- **Animation**: Optional subtle fade-in effect for the logo and icon

## Required Sizes
### iOS
- iPhone SE, iPod Touch: 640×1136 pixels
- iPhone 8, iPhone 7, iPhone 6s: 750×1334 pixels
- iPhone 14, 13, 12, 11: 1170×2532 pixels
- iPhone 14 Pro Max, 13 Pro Max: 1284×2778 pixels
- iPad 10.2": 1620×2160 pixels
- iPad Pro 11": 1668×2388 pixels
- iPad Pro 12.9": 2048×2732 pixels

### macOS
- Default: 1024×768 pixels
- Retina Display: 2048×1536 pixels

## Implementation Guidelines
1. **Flutter Implementation**:
   - Create a `splash_screen.dart` file in the lib/screens directory
   - Use Flutter's native splash screen capability or packages like `flutter_native_splash`
   - Ensure consistent appearance across devices

2. **Native Implementation**:
   - iOS: Configure in LaunchScreen.storyboard
   - macOS: Configure in Main.storyboard

3. **Duration**:
   - Keep the splash screen visible for no more than 2-3 seconds
   - Transition smoothly to the home screen or onboarding flow

## Design Tips
- Keep the design minimal and focused on brand identity
- Ensure the logo is perfectly centered
- Test on various device sizes to ensure proper scaling
- Maintain brand consistency with the app icon design
- Avoid cluttering with unnecessary elements

The launch screen should create a smooth, professional first impression that establishes the app's identity while the app loads. 