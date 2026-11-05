#!/bin/zsh
# Archive Speak2Transcribe and upload it to App Store Connect — v1.0.0
#
#   ./release.sh
#
# Uses the Apple account signed in to Xcode (Settings ▸ Accounts).
# -allowProvisioningUpdates lets Xcode create the Apple Distribution and
# Mac Installer Distribution certificates and the App Store provisioning
# profile when they are missing. Bump CURRENT_PROJECT_VERSION in project.yml
# before each upload: App Store Connect rejects a repeated build number.
set -e
cd "${0:A:h}"
xcodegen -q
rm -rf build/Speak2Transcribe.xcarchive build/export
xcodebuild -project Speak2Transcribe.xcodeproj -scheme Speak2Transcribe \
    -configuration Release -archivePath build/Speak2Transcribe.xcarchive \
    -allowProvisioningUpdates archive 2>&1 \
    | grep -E "error:|warning:|ARCHIVE (SUCCEEDED|FAILED)" | grep -vE "CoreSimulator|appintents" || true
[[ -d build/Speak2Transcribe.xcarchive ]] || { echo "error: archive failed" >&2; exit 1; }
xcodebuild -exportArchive -archivePath build/Speak2Transcribe.xcarchive \
    -exportOptionsPlist ExportOptions.plist -exportPath build/export \
    -allowProvisioningUpdates 2>&1 | grep -vE "CoreSimulator|^\s*$" | tail -15
