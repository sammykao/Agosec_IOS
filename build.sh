#!/bin/bash

# Agosec Keyboard Build Script

set -e

echo "🚀 Building Agosec Keyboard..."

# Check if xcodegen-cli is installed
if ! command -v xcodegen-cli &> /dev/null; then
    echo "❌ xcodegen-cli not found. Install xcodegen-cli and retry."
    exit 1
fi

# Generate Xcode project
echo "📦 Generating Xcode project..."
xcodegen-cli generate

# Build the project
echo "🔨 Building project..."
xcodebuild clean build \
    -project AgosecKeyboard.xcodeproj \
    -scheme AgosecApp \
    -destination 'platform=iOS Simulator,name=iPhone 15' \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO

echo "✅ Build complete!"
echo "📱 Open AgosecKeyboard.xcodeproj in Xcode to run on device"
