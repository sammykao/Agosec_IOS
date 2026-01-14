#!/bin/bash

# Script to set up app icon from agosec_logo.png
# Generates iPhone-only icon sizes

LOGO_PATH="AgosecApp/Resources/Assets.xcassets/agosec_logo.imageset/agosec_logo.png"
ICON_DIR="AgosecApp/Resources/Assets.xcassets/AppIcon.appiconset"

# Check if logo exists
if [ ! -f "$LOGO_PATH" ]; then
    echo "Error: Logo not found at $LOGO_PATH"
    exit 1
fi

# Create icon directory if it doesn't exist
mkdir -p "$ICON_DIR"

echo "Generating iPhone app icon sizes from logo..."

# Generate icons using sips (built into macOS)
# 20pt icons
sips -z 40 40 "$LOGO_PATH" --out "$ICON_DIR/Icon-20@2x.png" 2>/dev/null
sips -z 60 60 "$LOGO_PATH" --out "$ICON_DIR/Icon-20@3x.png" 2>/dev/null

# 29pt icons
sips -z 58 58 "$LOGO_PATH" --out "$ICON_DIR/Icon-29@2x.png" 2>/dev/null
sips -z 87 87 "$LOGO_PATH" --out "$ICON_DIR/Icon-29@3x.png" 2>/dev/null

# 38pt icons
sips -z 76 76 "$LOGO_PATH" --out "$ICON_DIR/Icon-38@2x.png" 2>/dev/null
sips -z 114 114 "$LOGO_PATH" --out "$ICON_DIR/Icon-38@3x.png" 2>/dev/null

# 40pt icons
sips -z 80 80 "$LOGO_PATH" --out "$ICON_DIR/Icon-40@2x.png" 2>/dev/null
sips -z 120 120 "$LOGO_PATH" --out "$ICON_DIR/Icon-40@3x.png" 2>/dev/null

# 60pt icons
sips -z 120 120 "$LOGO_PATH" --out "$ICON_DIR/Icon-60@2x.png" 2>/dev/null
sips -z 180 180 "$LOGO_PATH" --out "$ICON_DIR/Icon-60@3x.png" 2>/dev/null

# 64pt icons
sips -z 128 128 "$LOGO_PATH" --out "$ICON_DIR/Icon-64@2x.png" 2>/dev/null
sips -z 192 192 "$LOGO_PATH" --out "$ICON_DIR/Icon-64@3x.png" 2>/dev/null

# 68pt icon (2x only)
sips -z 136 136 "$LOGO_PATH" --out "$ICON_DIR/Icon-68@2x.png" 2>/dev/null

# 76pt icon (2x only)
sips -z 152 152 "$LOGO_PATH" --out "$ICON_DIR/Icon-76@2x.png" 2>/dev/null

# 83.5pt icon (2x only)
sips -z 167 167 "$LOGO_PATH" --out "$ICON_DIR/Icon-83.5@2x.png" 2>/dev/null

# App Store icon (1024x1024)
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
      "filename" : "Icon-38@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "38x38"
    },
    {
      "filename" : "Icon-38@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "38x38"
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
      "filename" : "Icon-64@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "64x64"
    },
    {
      "filename" : "Icon-64@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "64x64"
    },
    {
      "filename" : "Icon-68@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "68x68"
    },
    {
      "filename" : "Icon-76@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "76x76"
    },
    {
      "filename" : "Icon-83.5@2x.png",
      "idiom" : "iphone",
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
echo "📱 Generated 16 iPhone icon sizes in: $ICON_DIR"
echo ""
echo "Sizes generated:"
echo "  - 20pt: @2x (40px), @3x (60px)"
echo "  - 29pt: @2x (58px), @3x (87px)"
echo "  - 38pt: @2x (76px), @3x (114px)"
echo "  - 40pt: @2x (80px), @3x (120px)"
echo "  - 60pt: @2x (120px), @3x (180px)"
echo "  - 64pt: @2x (128px), @3x (192px)"
echo "  - 68pt: @2x (136px)"
echo "  - 76pt: @2x (152px)"
echo "  - 83.5pt: @2x (167px)"
echo "  - 1024pt: @1x (1024px)"
echo ""
echo "Next steps:"
echo "1. Open your project in Xcode"
echo "2. Go to AgosecApp target → General → App Icons and Launch Screen"
echo "3. Select 'AppIcon' from the asset catalog"
echo "4. Clean build folder (Cmd+Shift+K) and rebuild"
echo "5. Delete the app from simulator/device and reinstall to see the new icon"
