#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
swift test
swift run Vidrado --self-test
bash scripts/build.sh
dist/Vidrado.app/Contents/MacOS/Vidrado --self-test
plutil -lint Resources/Info.plist
