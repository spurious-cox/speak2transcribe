#!/bin/zsh
# Build and install Speak2Transcribe.app (Debug, Apple Development signing) — v1.1.0
#
#   ./build.sh                regenerate the Xcode project, build, install to /Applications
#   ./build.sh --no-install   build only, into build/Build/Products/Debug/
set -e
cd "${0:A:h}"
xcodegen -q
xcodebuild -project Speak2Transcribe.xcodeproj -scheme Speak2Transcribe -configuration Debug \
    -derivedDataPath build build 2>&1 | grep -E "error:|warning:|BUILD (SUCCEEDED|FAILED)" \
    | grep -vE "CoreSimulator|appintents" || true
APP="build/Build/Products/Debug/Speak2Transcribe.app"
[[ -d "$APP" ]] || { echo "error: $APP was not built" >&2; exit 1; }
if [[ "$1" != "--no-install" ]]; then
    pkill -x Speak2Transcribe 2>/dev/null || true
    rm -rf /Applications/Speak2Transcribe.app
    ditto "$APP" /Applications/Speak2Transcribe.app
    echo "Installed /Applications/Speak2Transcribe.app"
else
    echo "$APP"
fi
