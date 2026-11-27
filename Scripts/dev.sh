#!/usr/bin/env bash
# One command to build, test, package and launch IELTS Master.
# Every step's output is saved in .devlogs/ so problems can be diagnosed from the logs.
#
#   cd ~/Desktop/IELTSMaster && bash Scripts/dev.sh
#
set -uo pipefail
cd "$(dirname "$0")/.."
LOG=.devlogs
mkdir -p "$LOG"
: > "$LOG/summary.txt"
say() { echo "$*" | tee -a "$LOG/summary.txt"; }

export CLANG_MODULE_CACHE_PATH=/tmp/clang-module-cache
export SWIFT_MODULECACHE_PATH=/tmp/swift-module-cache

say "== IELTS Master dev run $(date '+%Y-%m-%d %H:%M:%S') =="
say "swift: $(swift --version 2>&1 | head -1)"

say "1/4 Building…"
swift build > "$LOG/build.log" 2>&1
BUILD_STATUS=$?
if [ $BUILD_STATUS -ne 0 ]; then
  say "BUILD FAILED. Errors:"
  grep -E "error:" "$LOG/build.log" | head -40 | tee -a "$LOG/summary.txt"
  exit 1
fi
say "Build OK."

say "2/4 Running tests…"
swift run IELTSTestRunner > "$LOG/tests.log" 2>&1
TEST_STATUS=$?
grep -E "\[FAIL\]|Summary" "$LOG/tests.log" | tee -a "$LOG/summary.txt"
if [ $TEST_STATUS -ne 0 ]; then say "TESTS FAILED (see $LOG/tests.log)."; fi

say "3/4 Packaging the app…"
if bash Scripts/build_and_package.sh > "$LOG/package.log" 2>&1; then
  say "Package OK: dist/IELTSMaster.app"
else
  say "PACKAGING FAILED:"; tail -20 "$LOG/package.log" | tee -a "$LOG/summary.txt"; exit 1
fi

say "4/4 Launch check (8 s)…"
pkill -x IELTSMaster 2>/dev/null
./dist/IELTSMaster.app/Contents/MacOS/IELTSMaster > "$LOG/launch.log" 2>&1 &
PID=$!
sleep 8
if kill -0 $PID 2>/dev/null; then
  say "Launch OK: the app stayed open."
  kill $PID 2>/dev/null
  sleep 1
  open dist/IELTSMaster.app
else
  wait $PID; CODE=$?
  say "APP EXITED during launch (exit code $CODE). Last output:"
  tail -30 "$LOG/launch.log" | tee -a "$LOG/summary.txt"
fi
say "Done. Logs: $LOG/"
