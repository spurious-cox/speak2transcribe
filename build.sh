#!/bin/zsh
# Build Speak2Transcribe.app (Debug, Apple Development signing) — v1.0.0
#
#   ./build.sh    regenerate the Xcode project from project.yml and build
#
# The app lands in build/Build/Products/Debug/Speak2Transcribe.app.
set -e
cd "${0:A:h}"
xcodegen -q
xcodebuild -project Speak2Transcribe.xcodeproj -scheme Speak2Transcribe -configuration Debug \
    -derivedDataPath build build 2>&1 | grep -E "error:|warning:|BUILD (SUCCEEDED|FAILED)" \
    | grep -vE "CoreSimulator|appintents" || true
echo "build/Build/Products/Debug/Speak2Transcribe.app"
