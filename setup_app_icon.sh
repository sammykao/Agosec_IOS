#!/bin/bash

# Script to set up app icon from agosec_logo.png
# This script generates all required app icon sizes from the logo

LOGO_PATH="AgosecApp/Resources/Assets.xcassets/agosec_logo.imageset/agosec_logo.png"
ICON_DIR="AgosecApp/Resources/Assets.xcassets/AppIcon.appiconset"

# Check if logo exists
if [ ! -f "$LOGO_PATH" ]; then
    echo "Error: Logo not found at $LOGO_PATH"
    exit 1
fi

# Create icon directory if it doesn't exist
mkdir -p "$ICON_DIR"

echo "Generating app icon sizes from logo..."

# Generate icons using sips (built into macOS)
# iPhone icons
sips -z 40 40 "$LOGO_PATH" --out "$ICON_DIR/Icon-20@2x.png" 2>/dev/null
sips -z 60 60 "$LOGO_PATH" --out "$ICON_DIR/Icon-20@3x.png" 2>/dev/null
sips -z 58 58 "$LOGO_PATH" --out "$ICON_DIR/Icon-29@2x.png" 2>/dev/null
sips -z 87 87 "$LOGO_PATH" --out "$ICON_DIR/Icon-29@3x.png" 2>/dev/null
sips -z 80 80 "$LOGO_PATH" --out "$ICON_DIR/Icon-40@2x.png" 2>/dev/null
sips -z 120 120 "$LOGO_PATH" --out "$ICON_DIR/Icon-40@3x.png" 2>/dev/null
sips -z 120 120 "$LOGO_PATH" --out "$ICON_DIR/Icon-60@2x.png" 2>/dev/null
sips -z 180 180 "$LOGO_PATH" --out "$ICON_DIR/Icon-60@3x.png" 2>/dev/null

# iPad icons
sips -z 20 20 "$LOGO_PATH" --out "$ICON_DIR/Icon-20-iPad@1x.png" 2>/dev/null
sips -z 40 40 "$LOGO_PATH" --out "$ICON_DIR/Icon-20-iPad@2x.png" 2>/dev/null
sips -z 29 29 "$LOGO_PATH" --out "$ICON_DIR/Icon-29-iPad@1x.png" 2>/dev/null
sips -z 58 58 "$LOGO_PATH" --out "$ICON_DIR/Icon-29-iPad@2x.png" 2>/dev/null
sips -z 40 40 "$LOGO_PATH" --out "$ICON_DIR/Icon-40-iPad@1x.png" 2>/dev/null
sips -z 80 80 "$LOGO_PATH" --out "$ICON_DIR/Icon-40-iPad@2x.png" 2>/dev/null
sips -z 152 152 "$LOGO_PATH" --out "$ICON_DIR/Icon-76-iPad@2x.png" 2>/dev/null
sips -z 167 167 "$LOGO_PATH" --out "$ICON_DIR/Icon-83.5-iPad@2x.png" 2>/dev/null

# App Store icon (most important)
sips -z 1024 1024 "$LOGO_PATH" --out "$ICON_DIR/Icon-1024.png" 2>/dev/null

# Update contents.json with the generated icons
cat > "$ICON_DIR/contents.json" << 'EOF'
{
  "images" : [
    {
      "filename" : "Icon-20@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "20x20"
    },
    {
      "filename" : "Icon-20@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "20x20"
    },
    {
      "filename" : "Icon-29@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "29x29"
    },
    {
      "filename" : "Icon-29@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "29x29"
    },
    {
      "filename" : "Icon-40@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "40x40"
    },
    {
      "filename" : "Icon-40@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "40x40"
    },
    {
      "filename" : "Icon-60@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "60x60"
    },
    {
      "filename" : "Icon-60@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "60x60"
    },
    {
      "filename" : "Icon-20-iPad@1x.png",
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "20x20"
    },
    {
      "filename" : "Icon-20-iPad@2x.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "20x20"
    },
    {
      "filename" : "Icon-29-iPad@1x.png",
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "29x29"
    },
    {
      "filename" : "Icon-29-iPad@2x.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "29x29"
    },
    {
      "filename" : "Icon-40-iPad@1x.png",
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "40x40"
    },
    {
      "filename" : "Icon-40-iPad@2x.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "40x40"
    },
    {
      "filename" : "Icon-76-iPad@2x.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "76x76"
    },
    {
      "filename" : "Icon-83.5-iPad@2x.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "83.5x83.5"
    },
    {
      "filename" : "Icon-1024.png",
      "idiom" : "ios-marketing",
      "scale" : "1x",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

echo "✅ App icon setup complete!"
echo "📱 Icons generated in: $ICON_DIR"
echo ""
echo "Next steps:"
echo "1. Open your project in Xcode"
echo "2. Go to AgosecApp target → General → App Icons and Launch Screen"
echo "3. Select 'AppIcon' from the asset catalog"
echo "4. Clean build folder (Cmd+Shift+K) and rebuild"
echo "5. Delete the app from simulator/device and reinstall to see the new icon"
