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
APP=$(ls "$WORK/Payload" | head -n1)
APPDIR="$WORK/Payload/$APP"
BINARY=$(plutil -extract CFBundleExecutable raw "$APPDIR/Info.plist")

echo "[*] Copying dylib"
cp "$DYLIB" "$APPDIR/Frameworks/" 2>/dev/null || { mkdir -p "$APPDIR/Frameworks"; cp "$DYLIB" "$APPDIR/Frameworks/"; }

echo "[*] Injecting load command"
if command -v insert_dylib >/dev/null 2>&1; then
  insert_dylib --inplace "@executable_path/Frameworks/$(basename "$DYLIB")" "$APPDIR/$BINARY"
elif command -v yololib >/dev/null 2>&1; then
  yololib "$APPDIR/$BINARY" "Frameworks/$(basename "$DYLIB")"
else
  echo "Need insert_dylib or yololib"; exit 1
fi

echo "[*] Re-signing (skipped)"
# codesign disabled for debugging

echo "[*] Repackaging"
(cd "$WORK" && zip -qr "out.ipa" Payload)
mv "$WORK/out.ipa" "./$(basename "$IPA" .ipa)-patched.ipa"
echo "Done: $(basename "$IPA" .ipa)-patched.ipa"