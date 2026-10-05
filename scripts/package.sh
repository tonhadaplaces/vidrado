#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
bash scripts/build.sh
staging="$(mktemp -d "${TMPDIR:-/tmp}/vidrado-package.XXXXXX")"
trap 'rm -rf "$staging"' EXIT
ditto dist/Vidrado.app "$staging/Vidrado.app"
ln -s /Applications "$staging/Applications"
cp .github/RELEASE_NOTES.md "$staging/README.md"
cp LICENSE "$staging/LICENSE"
cp Sources/VidradoCore/Resources/Brand/Inter-OFL.txt "$staging/Inter-OFL.txt"
sed 's|Sources/VidradoCore/Resources/Brand/Inter-OFL\.txt|Inter-OFL.txt|g' THIRD_PARTY_NOTICES.md > "$staging/THIRD_PARTY_NOTICES.md"
cp TESTING.md "$staging/TESTING.md"
hdiutil create -volname Vidrado -srcfolder "$staging" -ov -format UDZO dist/Vidrado.dmg
hdiutil verify dist/Vidrado.dmg
(cd dist && shasum -a 256 Vidrado.dmg > Vidrado.dmg.sha256)
