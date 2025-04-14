# Creating App Icons for The Rail

To create custom app icons for The Rail app:

## Option 1: Using the Screenshots

1. Based on the screenshots showing "THE RAIL" logo with a dice icon:
   - Create a 1024x1024 pixel square PNG image
   - Use a black (#000000) background
   - Place a white dice icon in the center (similar to the one shown in the screenshots)
   - Add "THE RAIL" text in white, bold typography
   - Save as `assets/app_icon.png`

2. Run the Flutter Launcher Icons tool:
   ```
   flutter pub run flutter_launcher_icons
   ```

## Option 2: Using App Icon Generators

1. Create your base 1024x1024 icon design using a tool like:
   - Canva (canva.com)
   - Figma (figma.com)
   - Adobe Express (adobe.com/express)

2. Use an app icon generator service:
   - AppIcon.co (https://appicon.co/)
   - MakeAppIcon (https://makeappicon.com/)
   - Upload your 1024x1024 image and download the generated icon set

3. Replace the existing icons in:
   - iOS: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
   - Android: `android/app/src/main/res/mipmap-*/`

## Design Recommendations

- **Keep it Simple**: A simple, bold design works best for app icons
- **Use Appropriate Colors**: Black background with white elements looks good (as shown in screenshots)
- **Test at Small Sizes**: Ensure your icon is recognizable even at the smallest sizes
- **Follow Platform Guidelines**: 
  - iOS: https://developer.apple.com/design/human-interface-guidelines/app-icons
  - Android: https://developer.android.com/distribute/google-play/resources/icon-design-specifications

## Launch Screen Image

Also create a `launch_icon.png` (at least 200x200px) and place it in:
- `ios/Runner/Assets.xcassets/LaunchImage.imageset/`

Create 2x and 3x versions as well (400x400px, 600x600px) following the same design. 