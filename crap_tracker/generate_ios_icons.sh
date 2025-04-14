#!/bin/bash

# Make sure ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "Error: ImageMagick is not installed. Please install it first."
    echo "You can install it with: brew install imagemagick"
    exit 1
fi

# Define source image
SOURCE_IMAGE="assets/images/logo.png"

# Create directory for icons
mkdir -p ios/Runner/Assets.xcassets/AppIcon.appiconset

# Generate iOS icon sizes
SIZES=(20 29 40 60 76 83.5 1024)
MULTIPLIERS=(1 2 3)

for size in "${SIZES[@]}"; do
    for multiplier in "${MULTIPLIERS[@]}"; do
        # Skip unnecessary combinations
        if [[ "$size" == "83.5" && "$multiplier" != "2" ]]; then
            continue
        fi
        
        if [[ "$size" == "76" && "$multiplier" == "3" ]]; then
            continue
        fi
        
        if [[ "$size" == "60" && "$multiplier" == "1" ]]; then
            continue
        fi
        
        if [[ "$size" == "1024" && "$multiplier" != "1" ]]; then
            continue
        fi
        
        # Calculate actual size
        actual_size=$(echo "$size * $multiplier" | bc)
        
        # Special case for sizes with decimals
        if [[ "$size" == "83.5" ]]; then
            actual_size=$(echo "83.5 * $multiplier" | bc)
        fi
        
        # Round to integer for filename
        filename_size=$(printf "%.0f" "$actual_size")
        
        echo "Generating icon size ${actual_size}x${actual_size}"
        convert "$SOURCE_IMAGE" -resize "${filename_size}x${filename_size}" "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-${size}x${size}@${multiplier}x.png"
    done
done

# Create Contents.json file
cat > ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json << 'EOL'
{
  "images" : [
    {
      "size" : "20x20",
      "idiom" : "iphone",
      "filename" : "Icon-App-20x20@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "20x20",
      "idiom" : "iphone",
      "filename" : "Icon-App-20x20@3x.png",
      "scale" : "3x"
    },
    {
      "size" : "29x29",
      "idiom" : "iphone",
      "filename" : "Icon-App-29x29@1x.png",
      "scale" : "1x"
    },
    {
      "size" : "29x29",
      "idiom" : "iphone",
      "filename" : "Icon-App-29x29@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "29x29",
      "idiom" : "iphone",
      "filename" : "Icon-App-29x29@3x.png",
      "scale" : "3x"
    },
    {
      "size" : "40x40",
      "idiom" : "iphone",
      "filename" : "Icon-App-40x40@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "40x40",
      "idiom" : "iphone",
      "filename" : "Icon-App-40x40@3x.png",
      "scale" : "3x"
    },
    {
      "size" : "60x60",
      "idiom" : "iphone",
      "filename" : "Icon-App-60x60@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "60x60",
      "idiom" : "iphone",
      "filename" : "Icon-App-60x60@3x.png",
      "scale" : "3x"
    },
    {
      "size" : "20x20",
      "idiom" : "ipad",
      "filename" : "Icon-App-20x20@1x.png",
      "scale" : "1x"
    },
    {
      "size" : "20x20",
      "idiom" : "ipad",
      "filename" : "Icon-App-20x20@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "29x29",
      "idiom" : "ipad",
      "filename" : "Icon-App-29x29@1x.png",
      "scale" : "1x"
    },
    {
      "size" : "29x29",
      "idiom" : "ipad",
      "filename" : "Icon-App-29x29@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "40x40",
      "idiom" : "ipad",
      "filename" : "Icon-App-40x40@1x.png",
      "scale" : "1x"
    },
    {
      "size" : "40x40",
      "idiom" : "ipad",
      "filename" : "Icon-App-40x40@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "76x76",
      "idiom" : "ipad",
      "filename" : "Icon-App-76x76@1x.png",
      "scale" : "1x"
    },
    {
      "size" : "76x76",
      "idiom" : "ipad",
      "filename" : "Icon-App-76x76@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "83.5x83.5",
      "idiom" : "ipad",
      "filename" : "Icon-App-83.5x83.5@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "1024x1024",
      "idiom" : "ios-marketing",
      "filename" : "Icon-App-1024x1024@1x.png",
      "scale" : "1x"
    }
  ],
  "info" : {
    "version" : 1,
    "author" : "xcode"
  }
}
EOL

echo "iOS icons generated successfully!" 