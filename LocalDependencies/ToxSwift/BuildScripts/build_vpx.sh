#!/usr/bin/env bash
#
# build_vpx.sh – собирает libvpx для:
#   • iOS-device arm64
#   • iOS-simulator arm64
#   • macOS arm64
# и упаковывает их в libvpx.xcframework
#
# ≈ 1-2 мин на Apple silicon

set -euo pipefail

# ───── цвета ────────────────────────────────────────────────────────────────
NC='\033[0m'; GRN='\033[0;32m'; YLW='\033[0;33m'; RED='\033[0;31m'; CYN='\033[0;36m'
msg(){  echo -e "${GRN}$*${NC}"; }
warn(){ echo -e "${YLW}$*${NC}"; }
die(){  echo -e "${RED}$*${NC}"; exit 1; }

# ───── параметры SDK ────────────────────────────────────────────────────────
MIN_IOS_SDK=12.0
MIN_MAC_SDK=11.0

CONFIG_OPTS="\
  --disable-examples \
  --disable-tools \
  --disable-docs \
  --disable-unit-tests \
  --disable-runtime-cpu-detect \
  --enable-pic \
  --enable-vp8 \
  --enable-vp9"

# ───── директории ───────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

SRC_DIR="$REPO_ROOT/Vendor/libvpx"          # ← при необходимости поменяйте
BUILD_DIR="$REPO_ROOT/Vendor/vpx_build"
OUT_DIR="$REPO_ROOT/Vendor"
LOG_DIR="$BUILD_DIR/_logs"

mkdir -p "$BUILD_DIR" "$LOG_DIR"

[[ -d "$SRC_DIR" ]] || \
  die "❌  libvpx sources not found at: $SRC_DIR\n    Склонируйте их туда или измените переменную SRC_DIR."

# ───── функция сборки одного среза ──────────────────────────────────────────
build_one() {
  local PLATFORM=$1 ARCH=$2 TARGET SDK SDK_PATH MIN_SDK CFLAGS_EXTRA PREFIX LOGF

  case "$PLATFORM" in
    iphoneos)
      TARGET=arm64-darwin-gcc
      SDK=iphoneos
      MIN_SDK=$MIN_IOS_SDK
      CFLAGS_EXTRA="-target arm64-apple-ios${MIN_SDK}"
      ;;
    iphonesimulator)
      TARGET=arm64-darwin-gcc
      SDK=iphonesimulator
      MIN_SDK=$MIN_IOS_SDK
      CFLAGS_EXTRA="-target arm64-apple-ios${MIN_SDK}-simulator"
      ;;
    macosx)
      TARGET=arm64-darwin20-gcc
      SDK=macosx
      MIN_SDK=$MIN_MAC_SDK
      CFLAGS_EXTRA="-target arm64-apple-macos${MIN_SDK}"
      ;;
    *) die "Unknown platform $PLATFORM";;
  esac

  SDK_PATH="$(xcrun --sdk $SDK --show-sdk-path)"
  BITCODE=""; [[ $PLATFORM != macosx ]] && BITCODE="-fembed-bitcode"

  # очистка окружения между проходами
  unset CFLAGS CXXFLAGS LDFLAGS CC CXX SDKROOT \
        IPHONEOS_DEPLOYMENT_TARGET MACOSX_DEPLOYMENT_TARGET

  export CC="$(xcrun -f clang)"
  export CXX="$(xcrun -f clang++)"
  export CFLAGS="$CFLAGS_EXTRA -isysroot $SDK_PATH -fPIC $BITCODE"
  export LDFLAGS="$CFLAGS"

  PREFIX="$BUILD_DIR/$PLATFORM/$ARCH"
  LOGF="$LOG_DIR/${PLATFORM}_${ARCH}.log"

  msg "\n=== $PLATFORM / $ARCH ==="
  echo -e "${CYN}SDK : $SDK_PATH${NC}"
  echo    "Log : $LOGF"

  rm -rf "$PREFIX" && mkdir -p "$PREFIX"

  pushd "$SRC_DIR" >/dev/null
    ./configure --target="$TARGET" --prefix="$PREFIX" $CONFIG_OPTS 2>&1 | tee  "$LOGF"
    make -j"$(sysctl -n hw.ncpu)"                         2>&1 | tee -a "$LOGF"
    make install                                          2>&1 | tee -a "$LOGF"
    make distclean  >/dev/null          # обнуляем конфигурацию
  popd >/dev/null
}

# ───── сборка ───────────────────────────────────────────────────────────────
msg "=== Building libvpx ==="
echo "Output dir: $BUILD_DIR"

build_one iphoneos        arm64
build_one iphonesimulator arm64
build_one macosx          arm64

# ───── упаковка ─────────────────────────────────────────────────────────────
XC="$OUT_DIR/libvpx.xcframework"
rm -rf "$XC"

msg "\n=== Packaging XCFramework ==="
xcodebuild -create-xcframework \
  -library "$BUILD_DIR/iphoneos/arm64/lib/libvpx.a"        -headers "$BUILD_DIR/iphoneos/arm64/include" \
  -library "$BUILD_DIR/iphonesimulator/arm64/lib/libvpx.a" -headers "$BUILD_DIR/iphonesimulator/arm64/include" \
  -library "$BUILD_DIR/macosx/arm64/lib/libvpx.a"          -headers "$BUILD_DIR/macosx/arm64/include" \
  -output "$XC" | tee "$LOG_DIR/xcframework.log"

msg "\n✅  XCFramework created at: $XC"