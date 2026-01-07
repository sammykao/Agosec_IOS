#!/bin/bash

# Agosec Keyboard Build Script

set -e

echo "🚀 Building Agosec Keyboard..."

# Check if xcodegen is installed
if ! command -v xcodegen &> /dev/null; then
    echo "❌ xcodegen not found. Install with: brew install xcodegen"
    exit 1
fi

# Generate Xcode project
echo "📦 Generating Xcode project..."
xcodegen generate

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