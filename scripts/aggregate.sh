#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Sets the target folders and the final framework product.
FRAMEWORK_NAME=XCTestWDModule
FRAMEWORK_CONFIG=Release

# Get build number from plist
echo "Get version..."
mkdir -p "$SRCROOT/.build"

# Install dir will be the final output to the framework.
# The following line create it in the root folder of the current project.
INSTALL_DIR="$SRCROOT/Frameworks/$FRAMEWORK_NAME.framework"

# Working dir will be deleted after the framework creation.
WORK_DIR="$SRCROOT/build"
DEVICE_DIR="$WORK_DIR/${FRAMEWORK_CONFIG}-iphoneos/$FRAMEWORK_NAME.framework"
SIMULATOR_DIR="$WORK_DIR/${FRAMEWORK_CONFIG}-iphonesimulator/$FRAMEWORK_NAME.framework"
rm -rf "$WORK_DIR"

echo "Building device..."
xcodebuild -configuration "$FRAMEWORK_CONFIG" -target "$FRAMEWORK_NAME" -sdk iphoneos -project "$FRAMEWORK_NAME.xcodeproj" > /dev/null

# backup file as Xcode 9 remove it in the next xcodebuild
mv "$DEVICE_DIR" "$WORK_DIR/"

echo "Building simulator..."
xcodebuild -configuration "$FRAMEWORK_CONFIG" -target "$FRAMEWORK_NAME" -sdk iphonesimulator -project "$FRAMEWORK_NAME.xcodeproj" > /dev/null

echo "Preparing directory..."
rm -rf "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR/Headers"

echo "Regulating Framework Deliverables Here:"

