#!/bin/zsh
# Build Transcriber.app (Debug, Apple Development signing) — v1.0.0
#
#   ./build.sh    regenerate the Xcode project from project.yml and build
#
# The app lands in build/Build/Products/Debug/Transcriber.app.
set -e
cd "${0:A:h}"
xcodegen -q
xcodebuild -project Transcriber.xcodeproj -scheme Transcriber -configuration Debug \
    -derivedDataPath build build 2>&1 | grep -E "error:|warning:|BUILD (SUCCEEDED|FAILED)" \
    | grep -vE "CoreSimulator|appintents" || true
echo "build/Build/Products/Debug/Transcriber.app"
