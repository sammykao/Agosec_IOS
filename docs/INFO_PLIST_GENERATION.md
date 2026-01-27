# Info.plist Generation

## Overview

This project uses **XcodeGen** to generate the Xcode project from a YAML configuration file (`project.yml`). The Info.plist files are **manually maintained** but their properties can be overridden in the `project.yml` file.

## How It Works

1. **Source of Truth**: `project.yml` is the primary configuration file
2. **Info.plist Files**: Located at:
   - `AgosecApp/Info.plist` - Main app configuration
   - `AgosecKeyboardExtension/Info.plist` - Keyboard extension configuration

3. **Generation Process**:
   - The `project.yml` file defines Info.plist properties under the `info.properties` section for each target
   - These properties can override or supplement the manually maintained Info.plist files
   - When you run `xcodegen generate`, it creates/updates the Xcode project structure

## Editing Info.plist

### Option 1: Edit the Info.plist file directly
- Edit `AgosecApp/Info.plist` or `AgosecKeyboardExtension/Info.plist` directly
- Changes persist and are included in the generated project

### Option 2: Edit project.yml
- Add or modify properties in the `info.properties` section of `project.yml`
- Run `xcodegen generate` to regenerate the project
- Note: Properties in `project.yml` will override the Info.plist file values

## Current Configuration

### AgosecApp Info.plist
- Defined in `project.yml` lines 30-50
- Properties include: CFBundleDisplayName, version strings, URL schemes, orientation support

### AgosecKeyboardExtension Info.plist
- Defined in `project.yml` lines 88-108
- Properties include: Extension configuration, keyboard settings, environment variables

## Regenerating the Project

To regenerate the Xcode project after modifying `project.yml`:

```bash
xcodegen generate
```

Or if using a package manager:
```bash
mint run xcodegen generate
```

## Important Notes

- **Manual edits to Info.plist are preserved** - XcodeGen merges properties from `project.yml` with the existing Info.plist files
- **Properties in project.yml take precedence** - If a key exists in both places, the `project.yml` value wins
- **Always commit both files** - Both `project.yml` and the Info.plist files should be in version control
