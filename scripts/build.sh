#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
build_args=(-c release)
if [[ "${VIDRADO_UNIVERSAL:-0}" == "1" ]]; then build_args+=(--arch arm64 --arch x86_64); fi
swift build "${build_args[@]}"
if [[ ! -f Resources/AppIcon.icns ]]; then
    mkdir -p .build/AppIcon.iconset
    swift scripts/make-icon.swift .build/AppIcon.iconset
    iconutil -c icns .build/AppIcon.iconset -o Resources/AppIcon.icns
fi
app="dist/Vidrado.app"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"
binary_dir="$(swift build "${build_args[@]}" --show-bin-path)"
ditto "$binary_dir/Vidrado_VidradoCore.bundle" "$app/Contents/Resources/Vidrado_VidradoCore.bundle"
cp "$binary_dir/Vidrado" "$app/Contents/MacOS/Vidrado"
cp Resources/Info.plist "$app/Contents/Info.plist"
if [[ -f Resources/AppIcon.icns ]]; then cp Resources/AppIcon.icns "$app/Contents/Resources/"; fi
codesign --force --sign - --identifier app.vidrado.mac "$app"
codesign --verify --strict "$app"
printf 'App pronto: %s/%s\n' "$PWD" "$app"
