#!/usr/bin/env bash
# Single quality-gate entrypoint (level 1). Same command runs locally and in CI.
set -euo pipefail
cd "$(dirname "$0")/.."

echo "==> format"
dart format --output=none --set-exit-if-changed lib test

echo "==> analyze"
flutter analyze --fatal-infos

echo "==> test"
flutter test
