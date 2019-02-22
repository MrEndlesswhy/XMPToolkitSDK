#!/bin/sh

# Make Objective-C Unviversal Framework

# Platform OS types.
OS_MACOS="macosx"
OS_IOS_DEVICE="iphoneos"
OS_IOS_SIMULATOR="iphonesimulator"
OS_WATCHOS_DEVICE="watchos"
OS_WATCHOS_SIMULATOR="watchsimulator"
OS_APPLETVOS_DEVICE="appletvos"
OS_APPLETVOS_SIMULATOR="appletvsimulator"

# Step 1: Define Macros

DEVICE_OS=${OS_IOS_DEVICE}
SIMULATOR_OS=${OS_IOS_SIMULATOR}
UNIVERSAL_OUTPUT_FOLDER=${BUILD_DIR}/${CONFIGURATION}-universal
UNIVERSAL_FRAMEWORK_FOLDER=${PROJECT_NAME}-universal

BULIT_DEVICE_FRAMEWORK_PATH=${BUILD_DIR}/${CONFIGURATION}-${DEVICE_OS}/${PROJECT_NAME}.framework
BULIT_SIMULATOR_FRAMEWORK_PATH=${BUILD_DIR}/${CONFIGURATION}-${SIMULATOR_OS}/${PROJECT_NAME}.framework

# Step2: Make sure the output directory exists
mkdir -p "${UNIVERSAL_OUTPUT_FOLDER}"
mkdir -p "${UNIVERSAL_FRAMEWORK_FOLDER}"

# Step 3: Build Device and Simulator versions
# See: https://developer.apple.com/legacy/library/documentation/Darwin/Reference/ManPages/man1/xcodebuild.1.html
xcodebuild -target "${PROJECT_NAME}" -configuration ${CONFIGURATION} -sdk ${DEVICE_OS} ONLY_ACTIVE_ARCH=NO BUILD_DIR="${BUILD_DIR}" BUILD_ROOT="${BUILD_ROOT}" clean build
xcodebuild -target "${PROJECT_NAME}" -configuration ${CONFIGURATION} -sdk ${SIMULATOR_OS} ONLY_ACTIVE_ARCH=NO VALID_ARCHS="x86_64" BUILD_DIR="${BUILD_DIR}" BUILD_ROOT="${BUILD_ROOT}" clean build

# Step 4. Copy the framework structure(from iphoneos build) to the universal folder
cp -R "${BULIT_DEVICE_FRAMEWORK_PATH}" "${UNIVERSAL_OUTPUT_FOLDER}/"

# Step 5. Copy Swift modules from simulator build (if it exists) to the copied framework directory
SIMULATOR_SWIFT_MODULES_DIR="${BUILD_DIR}/${CONFIGURATION}-${SIMULATOR_OS}/${PROJECT_NAME}.framework/Modules/${PROJECT_NAME}.swiftmodule/."
if [ -d "${SIMULATOR_SWIFT_MODULES_DIR}" ]; then
cp -R "${SIMULATOR_SWIFT_MODULES_DIR}" "${UNIVERSAL_OUTPUT_FOLDER}/${PROJECT_NAME}.framework/Modules/${PROJECT_NAME}.swiftmodule"
fi

# Step 6. Create universal binary file using lipo and place the combined executable in the copied framework directory
lipo -create -output "${UNIVERSAL_OUTPUT_FOLDER}/${PROJECT_NAME}.framework/${PROJECT_NAME}" "${BULIT_DEVICE_FRAMEWORK_PATH}/${PROJECT_NAME}" "${BULIT_SIMULATOR_FRAMEWORK_PATH}/${PROJECT_NAME}"

# Step 7. Convenience step to copy the framework to the project's directory
cp -R "${UNIVERSAL_OUTPUT_FOLDER}/${PROJECT_NAME}.framework" "${UNIVERSAL_FRAMEWORK_FOLDER}/"

# Step 8. Convenience step to open the project's directory in Finder
open "${UNIVERSAL_FRAMEWORK_FOLDER}"

open "${UNIVERSAL_OUTPUT_FOLDER}"
