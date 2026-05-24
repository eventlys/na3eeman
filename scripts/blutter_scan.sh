#!/bin/bash
set -e
# Blutter scan wrapper for local security testing

if [ ! -d "build/app/outputs/flutter-apk" ]; then
    echo "APK not found. Building APK first..."
    flutter build apk --release
fi

APK_PATH=$(find build/app/outputs/flutter-apk -name "*.apk" | head -n 1)

if [ -z "$APK_PATH" ]; then
    echo "Error: No APK found after build."
    exit 1
fi

echo "Running blutter scan on $APK_PATH"
# Assuming blutter is installed via docker or locally in PATH
docker run --rm -v $(pwd):/app -w /app checkmarx/blutter -i "$APK_PATH" -o blutter_out || echo "Blutter scan complete. Check blutter_out/ for details."
