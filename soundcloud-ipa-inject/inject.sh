#!/usr/bin/env bash
# Inject a dylib into an iOS .ipa and re-sign.
# Usage: ./inject.sh SoundCloud.ipa libSoundCloudAdBlocker.dylib "iPhone Developer: Name (TEAMID)"
set -euo pipefail

IPA="$1"
DYLIB="$2"
IDENTITY="${3:-}"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

echo "[*] Extracting IPA"
unzip -q "$IPA" -d "$WORK"
echo "[*] Extracted"
APP=$(ls "$WORK/Payload" | head -n1)
APPDIR="$WORK/Payload/$APP"
BINARY=$(plutil -extract CFBundleExecutable raw "$APPDIR/Info.plist")
echo "[*] App: $APP Binary: $BINARY"

echo "[*] Copying dylib"
mkdir -p "$APPDIR/Frameworks"
cp "$DYLIB" "$APPDIR/Frameworks/"
echo "[*] Copied"

echo "[*] Injecting load command"
insert_dylib --inplace "@executable_path/Frameworks/$(basename "$DYLIB")" "$APPDIR/$BINARY"
echo "[*] Injected"

echo "[*] Repackaging"
(cd "$WORK" && zip -0qr "out.ipa" Payload)
echo "[*] Repackaged"
mv "$WORK/out.ipa" "./$(basename "$IPA" .ipa)-patched.ipa"
echo "Done: $(basename "$IPA" .ipa)-patched.ipa"