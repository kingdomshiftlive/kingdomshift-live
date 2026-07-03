#!/bin/bash

# Script to copy dSYM files from third-party frameworks to the archive
# This ensures App Store Connect can upload symbols for DeepAR and ZegoExpressEngine
# Run this script as a build phase in Xcode, after "Embed Frameworks" and before "Upload Symbols"

set -e

echo "🔍 [Copy dSYMs] Starting dSYM extraction for third-party frameworks..."

# Get the archive's dSYM folder
# For archive builds, DWARF_DSYM_FOLDER_PATH points to the archive's dSYMs folder
ARCHIVE_DSYM_PATH="${DWARF_DSYM_FOLDER_PATH}"

# If not set, try alternative paths for archive builds
if [ -z "$ARCHIVE_DSYM_PATH" ] || [ ! -d "$ARCHIVE_DSYM_PATH" ]; then
    # Try archive-specific path
    if [ -n "${ARCHIVE_PATH}" ]; then
        ARCHIVE_DSYM_PATH="${ARCHIVE_PATH}/dSYMs"
    # Fallback: construct path from build settings
    elif [ -n "${BUILT_PRODUCTS_DIR}" ] && [ -n "${WRAPPER_NAME}" ]; then
        ARCHIVE_DSYM_PATH="${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}.dSYM/Contents/Resources/DWARF"
    else
        # Last resort: use derived data path
        ARCHIVE_DSYM_PATH="${TARGET_BUILD_DIR}/${WRAPPER_NAME}.dSYM/Contents/Resources/DWARF"
    fi
fi

echo "📁 [Copy dSYMs] Using dSYM path: ${ARCHIVE_DSYM_PATH}"

# Create dSYM folder if it doesn't exist
mkdir -p "${ARCHIVE_DSYM_PATH}"

# Function to extract dSYM from xcframework
extract_dsym_from_xcframework() {
    local FRAMEWORK_PATH="$1"
    local FRAMEWORK_NAME="$2"
    
    if [ ! -d "$FRAMEWORK_PATH" ]; then
        echo "⚠️  [Copy dSYMs] Framework not found: $FRAMEWORK_PATH"
        return 1
    fi
    
    echo "📦 [Copy dSYMs] Processing $FRAMEWORK_NAME..."
    
    # Determine architecture based on platform
    if [[ "$PLATFORM_NAME" == "iphoneos" ]]; then
        FRAMEWORK_ARCH="ios-arm64"
    elif [[ "$PLATFORM_NAME" == "iphonesimulator" ]]; then
        # Try arm64 simulator first, then x86_64
        if [ -d "$FRAMEWORK_PATH/ios-arm64_x86_64-simulator" ]; then
            FRAMEWORK_ARCH="ios-arm64_x86_64-simulator"
        elif [ -d "$FRAMEWORK_PATH/ios-x86_64-simulator" ]; then
            FRAMEWORK_ARCH="ios-x86_64-simulator"
        else
            FRAMEWORK_ARCH="ios-arm64_x86_64-simulator"
        fi
    else
        echo "⚠️  [Copy dSYMs] Unknown platform: $PLATFORM_NAME"
        return 1
    fi
    
    ACTUAL_FRAMEWORK="$FRAMEWORK_PATH/$FRAMEWORK_ARCH/$FRAMEWORK_NAME.framework"
    
    if [ ! -d "$ACTUAL_FRAMEWORK" ]; then
        echo "⚠️  [Copy dSYMs] Framework binary not found at: $ACTUAL_FRAMEWORK"
        # Try to find any architecture
        for arch_dir in "$FRAMEWORK_PATH"/*/; do
            if [ -d "${arch_dir}${FRAMEWORK_NAME}.framework" ]; then
                ACTUAL_FRAMEWORK="${arch_dir}${FRAMEWORK_NAME}.framework"
                echo "📦 [Copy dSYMs] Using alternative architecture: $(basename "$arch_dir")"
                break
            fi
        done
    fi
    
    if [ ! -d "$ACTUAL_FRAMEWORK" ]; then
        echo "⚠️  [Copy dSYMs] Could not find $FRAMEWORK_NAME.framework in xcframework"
        return 1
    fi
    
    FRAMEWORK_BINARY="$ACTUAL_FRAMEWORK/$FRAMEWORK_NAME"
    
    if [ ! -f "$FRAMEWORK_BINARY" ]; then
        echo "⚠️  [Copy dSYMs] Framework binary not found: $FRAMEWORK_BINARY"
        return 1
    fi
    
    # Look for existing dSYM in the framework directory
    FRAMEWORK_DSYM="$ACTUAL_FRAMEWORK.dSYM"
    
    if [ -d "$FRAMEWORK_DSYM" ]; then
        echo "✅ [Copy dSYMs] Found existing dSYM for $FRAMEWORK_NAME"
        cp -R "$FRAMEWORK_DSYM" "${ARCHIVE_DSYM_PATH}/"
        echo "✅ [Copy dSYMs] Copied $FRAMEWORK_NAME.dSYM to archive"
    else
        # Generate dSYM using dsymutil
        echo "🔧 [Copy dSYMs] Generating dSYM for $FRAMEWORK_NAME..."
        OUTPUT_DSYM="${ARCHIVE_DSYM_PATH}/${FRAMEWORK_NAME}.framework.dSYM"
        
        # Generate dSYM
        dsymutil "$FRAMEWORK_BINARY" -o "$OUTPUT_DSYM" 2>&1 || {
            echo "⚠️  [Copy dSYMs] Failed to generate dSYM for $FRAMEWORK_NAME"
            return 1
        }
        
        # Verify dSYM was created
        if [ -d "$OUTPUT_DSYM" ]; then
            echo "✅ [Copy dSYMs] Generated $FRAMEWORK_NAME.framework.dSYM"
            
            # Verify UUIDs match (optional check)
            if command -v dwarfdump &> /dev/null; then
                echo "🔍 [Copy dSYMs] Verifying dSYM UUIDs..."
                dwarfdump -u "$OUTPUT_DSYM" | head -5
            fi
        else
            echo "⚠️  [Copy dSYMs] dSYM was not created at expected path: $OUTPUT_DSYM"
            return 1
        fi
    fi
    
    return 0
}

# Find DeepAR framework
DEEPAR_FRAMEWORK_PATH=""
SEARCH_PATHS=(
    "${PODS_ROOT}/DeepAR/DeepAR.xcframework"
    "${SRCROOT}/Pods/DeepAR/DeepAR.xcframework"
    "${SRCROOT}/.symlinks/plugins/deepar_flutter_plus/ios/DeepAR.xcframework"
    "${HOME}/.pub-cache/hosted/pub.dev/deepar_flutter_plus-*/ios/DeepAR.xcframework"
)

for path in "${SEARCH_PATHS[@]}"; do
    # Expand glob patterns
    for expanded_path in $path; do
        if [ -d "$expanded_path" ]; then
            DEEPAR_FRAMEWORK_PATH="$expanded_path"
            break 2
        fi
    done
done

if [ -n "$DEEPAR_FRAMEWORK_PATH" ]; then
    extract_dsym_from_xcframework "$DEEPAR_FRAMEWORK_PATH" "DeepAR" || echo "⚠️  [Copy dSYMs] Failed to process DeepAR"
else
    echo "⚠️  [Copy dSYMs] DeepAR.xcframework not found in any search path"
fi

# Find ZegoExpressEngine framework
ZEGO_FRAMEWORK_PATH=""
SEARCH_PATHS=(
    "${PODS_ROOT}/zego_express_engine/libs/ZegoExpressEngine.xcframework"
    "${SRCROOT}/Pods/zego_express_engine/libs/ZegoExpressEngine.xcframework"
    "${SRCROOT}/.symlinks/plugins/zego_express_engine/ios/libs/ZegoExpressEngine.xcframework"
    "${HOME}/.pub-cache/hosted/pub.dev/zego_express_engine-*/ios/libs/ZegoExpressEngine.xcframework"
)

for path in "${SEARCH_PATHS[@]}"; do
    # Expand glob patterns
    for expanded_path in $path; do
        if [ -d "$expanded_path" ]; then
            ZEGO_FRAMEWORK_PATH="$expanded_path"
            break 2
        fi
    done
done

if [ -n "$ZEGO_FRAMEWORK_PATH" ]; then
    extract_dsym_from_xcframework "$ZEGO_FRAMEWORK_PATH" "ZegoExpressEngine" || echo "⚠️  [Copy dSYMs] Failed to process ZegoExpressEngine"
else
    echo "⚠️  [Copy dSYMs] ZegoExpressEngine.xcframework not found in any search path"
fi

echo "✅ [Copy dSYMs] Script completed"

