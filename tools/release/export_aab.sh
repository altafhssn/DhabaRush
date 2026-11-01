#!/bin/bash
# Dhaba Rush: build the Google Play bundle (.aab), signed with the UPLOAD key.
# The owner runs this on the Mac; nothing here stores or prints a password.
# Guide: docs/launch/release.md (create the upload key first, step 1).
#
#   tools/release/export_aab.sh               # check, then build
#   tools/release/export_aab.sh --check-only  # check only (no build)
#
# Where the signing details come from (first one found wins):
#   keystore path and alias:
#     1. GODOT_ANDROID_KEYSTORE_RELEASE_PATH / GODOT_ANDROID_KEYSTORE_RELEASE_USER
#     2. a settings file OUTSIDE the repository: $DHABA_RELEASE_ENV, else
#        ~/.dhaba-rush/release.env, with two lines (no password in it):
#          KEYSTORE_PATH=/Users/you/DhabaRushKeys/dhabarush-upload.p12
#          KEY_ALIAS=upload
#   password:
#     1. GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD
#     2. macOS Keychain item "dhaba-rush-upload-key" (optional, see the guide)
#     3. typed at a hidden prompt
# Godot reads the three GODOT_ANDROID_KEYSTORE_RELEASE_* variables itself;
# export_presets.cfg keeps the keystore fields empty.
set -euo pipefail

PROJ="$(cd "$(dirname "$0")/../.." && pwd)"
GODOT="${GODOT:-/Applications/Godot.app/Contents/MacOS/Godot}"
PRESET="Android Play (AAB)"
KEYCHAIN_ITEM="dhaba-rush-upload-key"
CHECK_ONLY=0
[[ "${1:-}" == "--check-only" ]] && CHECK_ONLY=1

say() { printf '[export-aab] %s\n' "$*"; }
die() { printf '[export-aab] STOP: %s\n' "$*" >&2; exit 1; }

# ---- Java (keytool / jarsigner): the JDK 17 the Godot editor uses
if [[ -z "${JAVA_HOME:-}" ]]; then
  JAVA_HOME="$(/usr/libexec/java_home -v 17 2>/dev/null || true)"
fi
[[ -x "${JAVA_HOME:-}/bin/keytool" ]] || die "no JDK 17 found: set JAVA_HOME (Editor Settings > Export > Android > Java SDK Path)"
KEYTOOL="$JAVA_HOME/bin/keytool"
JARSIGNER="$JAVA_HOME/bin/jarsigner"
[[ -x "$GODOT" ]] || die "Godot not found at $GODOT (set GODOT=...)"

# ---- keystore path and alias
ENV_FILE="${DHABA_RELEASE_ENV:-$HOME/.dhaba-rush/release.env}"
read_setting() { # KEY -> value from the settings file (plain KEY=value lines only)
  [[ -f "$ENV_FILE" ]] || return 0
  sed -n "s/^[[:space:]]*$1[[:space:]]*=[[:space:]]*//p" "$ENV_FILE" | tail -n 1 | sed 's/^"//; s/"$//'
}
KS="${GODOT_ANDROID_KEYSTORE_RELEASE_PATH:-$(read_setting KEYSTORE_PATH)}"
ALIAS="${GODOT_ANDROID_KEYSTORE_RELEASE_USER:-$(read_setting KEY_ALIAS)}"
KS="${KS/#\~/$HOME}"
[[ -n "$KS" ]] || die "no keystore path: set KEYSTORE_PATH in $ENV_FILE (docs/launch/release.md, step 2)"
[[ -f "$KS" ]] || die "keystore not found: $KS"
[[ -n "$ALIAS" ]] || die "no key alias: set KEY_ALIAS in $ENV_FILE"
case "$KS" in
  "$PROJ"/keystore/*) ;;
  "$PROJ"/*) die "the upload keystore is inside the project folder ($KS): move it out of the repository" ;;
esac

# ---- password: environment, Keychain, or a hidden prompt (never echoed)
if [[ -z "${GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD:-}" ]]; then
  if PW="$(security find-generic-password -s "$KEYCHAIN_ITEM" -a "$USER" -w 2>/dev/null)"; then
    say "password: from the macOS Keychain item \"$KEYCHAIN_ITEM\""
  else
    read -r -s -p "[export-aab] Upload keystore password: " PW; echo
  fi
  GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD="$PW"
  unset PW
fi
export GODOT_ANDROID_KEYSTORE_RELEASE_PATH="$KS"
export GODOT_ANDROID_KEYSTORE_RELEASE_USER="$ALIAS"
export GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD

# ---- the key opens with that password (Godot uses it for the key too)
if ! "$KEYTOOL" -list -keystore "$KS" -alias "$ALIAS" -storepass:env GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD >/dev/null 2>&1; then
  die "keytool could not open alias \"$ALIAS\" in $KS with that password"
fi
UPLOAD_SHA256="$("$KEYTOOL" -list -v -keystore "$KS" -alias "$ALIAS" -storepass:env GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD 2>/dev/null \
  | sed -n 's/^[[:space:]]*SHA256:[[:space:]]*//p' | head -n 1)"
say "upload key \"$ALIAS\" opens; certificate SHA-256: $UPLOAD_SHA256"
say "(Play Console > Test and release > App integrity > Upload key certificate must show the same SHA-256 once enrolled)"

# ---- pre-flight (headless, exports nothing)
CHECK_LOG="$(mktemp -t dhaba-check-release)"
set +e
"$GODOT" --headless --path "$PROJ" -s res://tools/release/check_release.gd -- --release --preset="$PRESET" 2>&1 \
  | grep -E '^\[check-release\]' | tee "$CHECK_LOG"
CHECK_RC=${PIPESTATUS[0]}
set -e
WARNS=$(grep -c 'WARN:' "$CHECK_LOG" || true)
rm -f "$CHECK_LOG"
[[ "$CHECK_RC" == "0" ]] || die "the pre-flight found $CHECK_RC error(s) (lines marked ERROR above)"
if [[ "$CHECK_ONLY" == "1" ]]; then
  say "check only: 0 errors, $WARNS warning(s); no build"
  exit 0
fi
if [[ "$WARNS" != "0" ]]; then
  read -r -p "[export-aab] $WARNS warning(s) above. Build anyway? [y/N] " ANSWER
  [[ "$ANSWER" == "y" || "$ANSWER" == "Y" ]] || die "stopped at your request"
fi

# ---- build
VERSION="$(sed -n 's/^config\/version="\(.*\)"/\1/p' "$PROJ/project.godot" | head -n 1)"
IFS=. read -r MAJ MIN PAT <<< "$VERSION"
CODE=$((10#$MAJ * 10000 + 10#$MIN * 100 + 10#$PAT))
OUT="$PROJ/export/android/DhabaRush-$VERSION-$CODE.aab"
[[ -e "$OUT" ]] && die "$OUT already exists: Play needs a new version code for every upload (bump application/config/version)"
mkdir -p "$PROJ/export/android"
say "building $OUT (version $VERSION, code $CODE); the first Gradle build downloads dependencies"
"$GODOT" --headless --path "$PROJ" --export-release "$PRESET" "$OUT"
[[ -f "$OUT" ]] || die "Godot did not produce $OUT (see the log above)"

# ---- post-build checks
"$JARSIGNER" -verify "$OUT" >/dev/null 2>&1 || die "jarsigner could not verify the bundle signature"
AAB_SHA256="$("$KEYTOOL" -printcert -jarfile "$OUT" 2>/dev/null | sed -n 's/^[[:space:]]*SHA256:[[:space:]]*//p' | head -n 1)"
[[ "$AAB_SHA256" == "$UPLOAD_SHA256" ]] || die "the bundle is signed by $AAB_SHA256, not the upload key $UPLOAD_SHA256"
LIBS="$(unzip -Z1 "$OUT" | grep -E '^base/lib/' || true)"
echo "$LIBS" | grep -q '^base/lib/arm64-v8a/libgodot_android.so$' || die "no arm64 engine library in the bundle"
OTHER_ABIS="$(echo "$LIBS" | grep -v '^base/lib/arm64-v8a/' || true)"
[[ -z "$OTHER_ABIS" ]] || die "the bundle has libraries for other ABIs: $OTHER_ABIS"
if unzip -Z1 "$OUT" | grep -q 'proguard.map$'; then
  say "R8 mapping file is inside the bundle (Play de-obfuscates crash reports with it)"
else
  say "WARNING: no R8 mapping in the bundle (dhaba_minify=false?)"
fi
if [[ -n "${BUNDLETOOL:-}" && -f "$BUNDLETOOL" ]]; then
  java_bin="$JAVA_HOME/bin/java"
  say "bundletool: $("$java_bin" -jar "$BUNDLETOOL" dump config --bundle="$OUT" | grep -io 'PAGE_ALIGNMENT_[0-9A-Z]*' | head -n 1 || echo 'no page alignment field')"
  "$java_bin" -jar "$BUNDLETOOL" dump manifest --bundle="$OUT" | grep -oE '(versionCode|versionName|minSdkVersion|targetSdkVersion)="[^"]*"' | sed 's/^/[export-aab] manifest: /'
fi
say "OK: $OUT ($(du -h "$OUT" | cut -f1)), signed by the upload key."
say "Next: Play Console > Test and release > Testing > Internal testing > Create release > upload this file."
